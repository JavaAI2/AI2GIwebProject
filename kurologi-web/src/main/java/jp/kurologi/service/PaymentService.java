package jp.kurologi.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import jp.kurologi.model.Charge;
import jp.kurologi.model.Member;
import jp.kurologi.model.Payment;
import jp.kurologi.repository.MemberRepository;
import jp.kurologi.repository.PaymentRepository;

/**
 * 결제 관리 — [시험용] 결제 대기건을 골라 "예치금"으로 결제합니다.
 *
 *  - 결제수단(무통장입금 / 신용카드)을 무엇으로 고르든 똑같이 예치금으로 결제됩니다. (결제 프로그램 연동 없음)
 *  - 예치금이 모자라면 결제하지 않고 안내만 합니다. 대기건은 그대로 비용결제 목록에 남습니다.
 *  - 예치금이 충분하면 바로 결제완료(PAID)가 되어 결제내역으로 옮겨집니다.
 *  - 예치금 충전은 chargeTestDeposit() 으로 임의의 금액을 더합니다. (시험용)
 *
 * 금액은 화면에서 넘어온 값을 믿지 않고 항상 서버에서 대기건 합계로 다시 계산합니다.
 * 예치금 차감 · 대기건 상태 변경 · 결제 기록은 회원별 락으로 묶었습니다.
 */
public class PaymentService {

    /** method, depositToUse, depositorName 은 이전 화면과의 호환을 위해 남겨 두었고 지금은 쓰지 않습니다. */
    public record PayRequest(List<Long> chargeIds, Payment.Method method,
                             long depositToUse, String depositorName) {}

    private final MemberRepository members;
    private final PaymentRepository payments;
    private final Map<Long, Object> memberLocks = new ConcurrentHashMap<>();

    public PaymentService(MemberRepository members, PaymentRepository payments) {
        this.members = members;
        this.payments = payments;
    }

    /** 비용결제 목록 = 결제 대기건 + (예전 방식으로 만들어진) 입금확인중인 건 */
    public List<Charge> pendingCharges(long memberId) {
        List<Charge> list = new ArrayList<>(payments.findPendingCharges(memberId));
        for (Payment p : payments.findPayments(memberId)) {
            if (isAwaiting(p) && p.getChargeIds() != null && !p.getChargeIds().isEmpty()) {
                for (Charge c : payments.findCharges(memberId, p.getChargeIds())) {
                    if (c.getStatus() == Charge.Status.IN_PAYMENT) list.add(c);
                }
            }
        }
        list.sort(Comparator.comparing(Charge::getCreatedAt));
        return list;
    }

    private static boolean isAwaiting(Payment p) {
        return p.getStatus() == Payment.Status.AWAITING_DEPOSIT
                || p.getStatus() == Payment.Status.AWAITING_CARD;
    }

    /**
     * 결제 대기건을 하나 만든다. 구매대행 · 배송대행 주문이 "접수신청" 될 때 비용결제 목록에 올리는 데 쓴다.
     */
    public Charge addCharge(long memberId, String title, String orderNo, long amount) {
        Charge c = new Charge();
        c.setMemberId(memberId);
        c.setTitle(title);
        c.setOrderNo(orderNo);
        c.setAmount(amount);
        c.setCreatedAt(LocalDateTime.now());
        payments.saveCharge(c);
        return c;
    }

    public long pendingTotal(long memberId) {
        return pendingCharges(memberId).stream().mapToLong(Charge::getAmount).sum();
    }

    public List<Payment> history(long memberId) {
        return payments.findPayments(memberId);
    }

    /** [시험용] 예치금을 임의로 충전한다. 충전 뒤 예치금을 돌려준다. */
    public long chargeTestDeposit(long memberId, long amount) {
        if (amount <= 0) throw new ValidationException("충전 금액이 올바르지 않습니다.");
        synchronized (lockFor(memberId)) {
            Member m = members.findById(memberId)
                    .orElseThrow(() -> new ValidationException("회원 정보를 찾을 수 없습니다."));
            m.setDeposit(m.getDeposit() + amount);
            members.save(m);
            return m.getDeposit();
        }
    }

    /** 선택한 대기건을 예치금으로 결제한다. 예치금이 모자라면 ValidationException (대기건은 그대로 남는다). */
    public Payment pay(long memberId, PayRequest req) {
        if (req.chargeIds() == null || req.chargeIds().isEmpty()) {
            throw new ValidationException("결제할 항목을 선택해 주세요.");
        }
        synchronized (lockFor(memberId)) {

            List<Long> ids = req.chargeIds().stream().distinct().toList();

            // 예전 방식(입금확인중)으로 묶여 있는 건이 섞여 있으면 먼저 그 결제를 취소해 PENDING 으로 되돌린다.
            // cancel() 이 사용했던 예치금도 돌려주므로, 회원 정보는 이 작업이 끝난 뒤에 읽는다.
            Set<Long> toRevert = new LinkedHashSet<>();
            for (Charge c : payments.findCharges(memberId, ids)) {
                if (c.getStatus() == Charge.Status.IN_PAYMENT && c.getPaymentId() != null) {
                    toRevert.add(c.getPaymentId());
                }
            }
            for (Long pid : toRevert) {
                cancel(pid);   // 같은 락이라 재진입 가능
            }

            Member member = members.findById(memberId)
                    .orElseThrow(() -> new ValidationException("회원 정보를 찾을 수 없습니다."));

            List<Charge> charges = payments.findCharges(memberId, ids);
            if (charges.size() != ids.size()
                    || charges.stream().anyMatch(c -> c.getStatus() != Charge.Status.PENDING)) {
                throw new ValidationException("이미 처리되었거나 존재하지 않는 결제건이 포함되어 있습니다. 새로고침 후 다시 시도해 주세요.");
            }

            long total = charges.stream().mapToLong(Charge::getAmount).sum();
            long coupon = 0;   // TODO 쿠폰 선택 UI + 쿠폰 테이블 연결
            long payable = total - coupon;

            if (member.getDeposit() < payable) {
                throw new ValidationException(String.format(
                        "예치금이 부족합니다. (결제금액 ₩%,d / 보유 예치금 ₩%,d) '예치금 충전하기'로 충전한 뒤 다시 결제해 주세요.",
                        payable, member.getDeposit()));
            }

            Payment payment = new Payment();
            payment.setMemberId(memberId);
            payment.setChargeIds(ids);
            payment.setSummary(charges.get(0).getTitle() + (charges.size() > 1 ? " 외 " + (charges.size() - 1) + "건" : ""));
            payment.setTotalAmount(total);
            payment.setCouponDiscount(coupon);
            payment.setDepositUsed(payable);
            payment.setPayAmount(0);
            payment.setMethod(Payment.Method.DEPOSIT);
            payment.setStatus(Payment.Status.PAID);
            payment.setCreatedAt(LocalDateTime.now());
            payment.setPaidAt(LocalDateTime.now());

            payments.savePayment(payment);
            for (Charge c : charges) {
                c.setStatus(Charge.Status.PAID);
                c.setPaymentId(payment.getId());
                payments.saveCharge(c);
            }
            member.setDeposit(member.getDeposit() - payable);
            members.save(member);
            return payment;
        }
    }

    /** 입금 확인(관리자) 또는 토스 결제 승인 콜백에서 호출. (지금 화면에서는 쓰지 않음) */
    public void markPaid(long paymentId) {
        Payment p = payments.findPayment(paymentId).orElseThrow();
        synchronized (lockFor(p.getMemberId())) {
            if (p.getStatus() == Payment.Status.PAID) return;
            if (p.getStatus() == Payment.Status.CANCELED) throw new IllegalStateException("취소된 결제입니다.");
            p.setStatus(Payment.Status.PAID);
            p.setPaidAt(LocalDateTime.now());
            payments.savePayment(p);
            updateCharges(p, Charge.Status.PAID);
        }
    }

    /** 대기 중인 결제를 취소하고 청구건을 되돌린다. 사용한 예치금은 돌려준다. */
    public void cancel(long paymentId) {
        Payment p = payments.findPayment(paymentId).orElseThrow();
        synchronized (lockFor(p.getMemberId())) {
            if (p.getStatus() == Payment.Status.PAID || p.getStatus() == Payment.Status.CANCELED) {
                throw new IllegalStateException("취소할 수 없는 결제입니다: " + p.getStatus());
            }
            p.setStatus(Payment.Status.CANCELED);
            payments.savePayment(p);
            updateCharges(p, Charge.Status.PENDING);
            members.findById(p.getMemberId()).ifPresent(m -> {
                m.setDeposit(m.getDeposit() + p.getDepositUsed());
                members.save(m);
            });
        }
    }

    private void updateCharges(Payment p, Charge.Status status) {
        for (Charge c : payments.findCharges(p.getMemberId(), p.getChargeIds())) {
            c.setStatus(status);
            if (status == Charge.Status.PENDING) c.setPaymentId(null);
            payments.saveCharge(c);
        }
    }

    private Object lockFor(long memberId) {
        return memberLocks.computeIfAbsent(memberId, id -> new Object());
    }
}
