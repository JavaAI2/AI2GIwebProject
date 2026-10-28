package jp.kurologi.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import jp.kurologi.model.Charge;
import jp.kurologi.model.Member;
import jp.kurologi.model.Payment;
import jp.kurologi.repository.MemberRepository;
import jp.kurologi.repository.PaymentRepository;

/**
 * 결제 관리 — 결제 대기건을 골라 무통장입금 / 신용카드(토스) / 예치금으로 결제합니다.
 *
 * 금액은 화면에서 넘어온 값을 믿지 않고 항상 서버에서 대기건 합계로 다시 계산합니다.
 * 예치금 차감 · 대기건 상태 변경 · 결제 기록은 한 단위로 처리해야 하므로
 * 회원별 락으로 묶었습니다. DB 로 옮길 때는 이 메서드 전체를 한 트랜잭션으로
 * 감싸고, 회원 행을 SELECT … FOR UPDATE 로 잠그세요.
 */
public class PaymentService {

    public record PayRequest(List<Long> chargeIds, Payment.Method method,
                             long depositToUse, String depositorName) {}

    private final MemberRepository members;
    private final PaymentRepository payments;
    private final Map<Long, Object> memberLocks = new ConcurrentHashMap<>();

    public PaymentService(MemberRepository members, PaymentRepository payments) {
        this.members = members;
        this.payments = payments;
    }

    public List<Charge> pendingCharges(long memberId) {
        return payments.findPendingCharges(memberId);
    }

    /**
     * 결제 대기건을 하나 만든다. 구매대행 · 배송대행 주문이 "접수신청" 될 때 상품대금(원화)을 비용결제 목록에 올리는 데 쓴다.
     * 금액(amount)은 호출하는 쪽이 접수 시점의 고시환율로 계산해서 넘긴다.
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

    public Payment pay(long memberId, PayRequest req) {
        if (req.chargeIds() == null || req.chargeIds().isEmpty()) {
            throw new ValidationException("결제할 항목을 선택해 주세요.");
        }
        synchronized (lockFor(memberId)) {
            Member member = members.findById(memberId)
                    .orElseThrow(() -> new ValidationException("회원 정보를 찾을 수 없습니다."));

            List<Long> ids = req.chargeIds().stream().distinct().toList();
            List<Charge> charges = payments.findCharges(memberId, ids);
            if (charges.size() != ids.size()
                    || charges.stream().anyMatch(c -> c.getStatus() != Charge.Status.PENDING)) {
                throw new ValidationException("이미 처리되었거나 존재하지 않는 결제건이 포함되어 있습니다. 새로고침 후 다시 시도해 주세요.");
            }

            long total = charges.stream().mapToLong(Charge::getAmount).sum();
            long coupon = 0;   // TODO 쿠폰 선택 UI + 쿠폰 테이블 연결
            long payable = total - coupon;
            long depositUsed = Math.max(0, Math.min(req.depositToUse(), Math.min(member.getDeposit(), payable)));
            long remaining = payable - depositUsed;

            Payment payment = new Payment();
            payment.setMemberId(memberId);
            payment.setChargeIds(ids);
            payment.setSummary(charges.get(0).getTitle() + (charges.size() > 1 ? " 외 " + (charges.size() - 1) + "건" : ""));
            payment.setTotalAmount(total);
            payment.setCouponDiscount(coupon);
            payment.setDepositUsed(depositUsed);
            payment.setPayAmount(remaining);
            payment.setCreatedAt(LocalDateTime.now());

            if (remaining == 0) {
                payment.setMethod(Payment.Method.DEPOSIT);
                payment.setStatus(Payment.Status.PAID);
                payment.setPaidAt(LocalDateTime.now());
            } else if (req.method() == Payment.Method.CARD) {
                payment.setMethod(Payment.Method.CARD);
                payment.setStatus(Payment.Status.AWAITING_CARD);
            } else {
                String depositor = AccountService.trim(req.depositorName());
                if (depositor.isEmpty()) throw new ValidationException("입금자명을 입력해 주세요.");
                payment.setMethod(Payment.Method.BANK);
                payment.setDepositorName(depositor);
                payment.setStatus(Payment.Status.AWAITING_DEPOSIT);
            }

            payments.savePayment(payment);
            Charge.Status chargeStatus = payment.getStatus() == Payment.Status.PAID
                    ? Charge.Status.PAID : Charge.Status.IN_PAYMENT;
            for (Charge c : charges) {
                c.setStatus(chargeStatus);
                c.setPaymentId(payment.getId());
                payments.saveCharge(c);
            }
            member.setDeposit(member.getDeposit() - depositUsed);
            members.save(member);
            return payment;
        }
    }

    /** 입금 확인(관리자) 또는 토스 결제 승인 콜백에서 호출. */
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

    /** 입금 기한 초과 · 카드 결제 실패 시 — 대기건을 되돌리고 사용한 예치금을 돌려줍니다. */
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
