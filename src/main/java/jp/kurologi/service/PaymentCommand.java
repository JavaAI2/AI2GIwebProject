package jp.kurologi.service;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.Charge;
import jp.kurologi.model.MemberDTO;
import jp.kurologi.model.Payment;
import jp.kurologi.model.Waybill;
import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.repository.MemberDAO;
import jp.kurologi.repository.PaymentDAO;
import jp.kurologi.web.Session;

/**
 * 결제 관리 서비스 (마이페이지 > 결제방법) — [시험용]
 *
 *   GET  : 비용결제 탭(결제 대기건) / ?tab=history 이면 결제내역 탭 (true -> payment.jsp)
 *   POST : 선택한 대기건을 예치금으로 결제 -> 결제내역 탭으로 redirect (false)
 *
 * 결제 순서 (POST)
 *   1) 선택한 대기건이 내 것이고 모두 결제 대기 상태인지 확인
 *   2) 금액은 화면 값을 믿지 않고 서버에서 대기건 합계로 다시 계산
 *   3) 예치금 차감 (모자라면 결제하지 않고 안내만)
 *   4) 결제 기록(PAYMENT) 저장 + 한국/일본 운송장 배정
 *   5) 대기건을 결제완료로 바꾸고, 그 청구의 주문(BUY_ORDER)도 결제완료로 바꾼다
 */
public class PaymentCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		MemberDTO member = (MemberDTO) request.getAttribute("member");   // 컨트롤러가 담아 준 최신 회원정보
		PaymentDAO paymentDao = new PaymentDAO();
		String ctx = request.getContextPath();

		// ---- GET : 화면에 보여줄 값 담기 ----
		if ("GET".equalsIgnoreCase(request.getMethod())) {
			String tab = "history".equals(request.getParameter("tab")) ? "history" : "pending";

			List<Payment> payments = paymentDao.findPayments(member.getId());

			// 운송장 기능을 넣기 전에 결제한 건은 운송장이 비어 있으니 이때 채워 준다
			for (Payment p : payments) {
				if (p.getStatus() == Payment.Status.PAID
						&& (p.getKrWaybillNo() == null || p.getJpWaybillNo() == null)) {
					Waybill.assign(p);
					paymentDao.updateWaybill(p);
				}
			}

			request.setAttribute("tab", tab);                                              // 열려 있을 탭
			request.setAttribute("charges", paymentDao.findPendingCharges(member.getId())); // 비용결제 탭 : 결제 대기건
			request.setAttribute("payments", payments);                                    // 결제내역 탭
			return true;
		}

		// ---- POST : 선택한 대기건 결제 ----
		List<Long> ids = new ArrayList<>();
		String[] raw = request.getParameterValues("chargeId");   // 체크한 항목들
		if (raw != null) {
			for (String s : raw) {
				long id = parseLong(s);
				if (id > 0 && !ids.contains(id)) {   // 같은 번호가 두 번 오면 한 번만
					ids.add(id);
				}
			}
		}

		if (ids.isEmpty()) {
			return fail(request, response, "결제할 항목을 선택해 주세요.");
		}

		// 1) 선택한 건이 모두 내 결제 대기건인지 확인
		List<Charge> charges = paymentDao.findCharges(member.getId(), ids);
		boolean allPending = charges.size() == ids.size();
		for (Charge c : charges) {
			if (c.getStatus() != Charge.Status.PENDING) {
				allPending = false;
			}
		}
		if (!allPending) {
			return fail(request, response, "이미 처리되었거나 존재하지 않는 결제건이 포함되어 있습니다. 새로고침 후 다시 시도해 주세요.");
		}

		// 2) 금액 계산 (쿠폰은 아직 연결 전이라 0)
		long total = 0;
		for (Charge c : charges) {
			total += c.getAmount();
		}
		long coupon = 0;
		long payable = total - coupon;

		// 3) 예치금 차감 : 잔액이 모자라면 0건이 바뀌므로 결제하지 않는다
		MemberDAO memberDao = new MemberDAO();
		if (memberDao.useDeposit(member.getId(), payable) == 0) {
			return fail(request, response, String.format(
					"예치금이 부족합니다. (결제금액 ₩%,d / 보유 예치금 ₩%,d) '예치금 충전하기'로 충전한 뒤 다시 결제해 주세요.",
					payable, member.getDeposit()));
		}

		// 4) 결제 기록 만들기 (결제수단을 무엇으로 골랐든 예치금으로 결제한다 - 시험용)
		Payment payment = new Payment();
		payment.setMemberId(member.getId());
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
		Waybill.assign(payment);   // 결제 완료 -> 한국 / 일본 운송장을 무작위로 배정

		if (!paymentDao.insertPayment(payment)) {
			memberDao.addDeposit(member.getId(), payable);   // 저장에 실패했으니 차감했던 예치금을 되돌린다
			return fail(request, response, "결제 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
		}

		// 5) 대기건 -> 결제완료, 주문내역의 "결제" 칸도 결제완료로
		paymentDao.updateChargesPaid(member.getId(), ids, payment.getId());
		BuyOrderDAO orderDao = new BuyOrderDAO();
		for (Charge c : charges) {
			long orderId = orderIdOf(c.getOrderNo());
			if (orderId > 0) {
				orderDao.markPaid(orderId);
			}
		}

		Session.flash(request, "info", String.format("₩%,d 결제가 완료되었습니다. (예치금 사용) 남은 예치금: ₩%,d",
				total, member.getDeposit() - payable));
		response.sendRedirect(ctx + "/mypage/payment?tab=history");
		return false;
	}

	// 안내 메시지를 담고 결제 화면으로 redirect
	private boolean fail(HttpServletRequest request, HttpServletResponse response, String message) throws IOException {
		Session.flash(request, "error", message);
		response.sendRedirect(request.getContextPath() + "/mypage/payment");
		return false;
	}

	// 주문번호(B20261029-00012 / D...)의 뒷부분이 주문 번호(ORDER_ID)와 같다. 모르는 형태면 0
	private static long orderIdOf(String orderNo) {
		if (orderNo == null) return 0;
		int dash = orderNo.indexOf('-');
		if (dash < 0) return 0;
		try {
			return Long.parseLong(orderNo.substring(dash + 1));
		} catch (NumberFormatException e) {
			return 0;
		}
	}

	// 숫자가 아니면 -1
	private static long parseLong(String s) {
		try {
			return s == null ? -1 : Long.parseLong(s.trim());
		} catch (NumberFormatException e) {
			return -1;
		}
	}
}
