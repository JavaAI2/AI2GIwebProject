package jp.kurologi.service;

import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.model.Charge;
import jp.kurologi.model.Payment;
import jp.kurologi.model.ShipmentRow;
import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.repository.PaymentDAO;

/**
 * 마이페이지 "결제 완료 운송품 현황" 박스에 보여 줄 목록을 만든다.
 *
 * 결제내역에서 결제가 끝난 건(PAID)을 최근 순으로 모으고, 각 건에 묶인 주문이 있으면
 * 그 주문의 진행 상태(접수신청 · 입고완료 ...)를 함께 담는다.
 * mypage.jsp 가 직접 부르므로, 어느 서블릿이 마이페이지를 열든 목록이 보인다.
 */
public final class ShipmentBoard {

	private ShipmentBoard() { }

	/** 박스에 보여 줄 최근 결제 건수 */
	public static final int LIMIT = 5;

	/** 목록을 만든다. 오류가 나도 마이페이지가 깨지지 않도록 빈 목록을 돌려준다. */
	public static List<ShipmentRow> load(long memberId) {
		List<ShipmentRow> rows = new ArrayList<>();
		if (memberId <= 0) {
			return rows;
		}

		try {
			PaymentDAO paymentDao = new PaymentDAO();
			for (Payment p : paymentDao.findPayments(memberId)) {
				if (p.getStatus() != Payment.Status.PAID) {
					continue;
				}
				if (rows.size() >= LIMIT) {
					break;
				}
				rows.add(toRow(paymentDao, memberId, p));
			}
		} catch (RuntimeException e) {
			e.printStackTrace();
		}
		return rows;
	}

	/** 결제 1건 -> 화면 한 줄. 주문을 못 찾아도 "결제완료" 로 보여 준다. */
	private static ShipmentRow toRow(PaymentDAO paymentDao, long memberId, Payment p) {

		String orderNo = null;
		String orderUrl = null;
		String label = "결제완료";
		String css = "state--submit";

		try {
			List<Charge> charges = paymentDao.findCharges(memberId, p.getChargeIds());
			if (!charges.isEmpty()) {
				orderNo = charges.get(0).getOrderNo();
				long orderId = orderIdOf(orderNo);
				if (orderId > 0) {
					BuyOrderDTO order = new BuyOrderDAO().findById(orderId);
					if (order != null && order.getMemberId() == memberId) {
						label = OrderStatus.label(order.getStatus());
						css = OrderStatus.css(order.getStatus());
						orderUrl = ServiceType.base(ServiceType.normalize(order.getServiceType()))
								+ "/view?id=" + orderId;
					}
				}
			}
		} catch (RuntimeException e) {
			e.printStackTrace();   // 상태를 못 찾아도 결제 정보는 보여 준다
		}

		return new ShipmentRow(p, orderNo, orderUrl, label, css);
	}

	/** 주문번호(B20261029-00012 / D...)의 뒷부분이 주문 번호(ORDER_ID)와 같다. 모르는 형태면 0 */
	private static long orderIdOf(String orderNo) {
		if (orderNo == null) {
			return 0;
		}
		int dash = orderNo.indexOf('-');
		if (dash < 0) {
			return 0;
		}
		try {
			return Long.parseLong(orderNo.substring(dash + 1));
		} catch (NumberFormatException e) {
			return 0;
		}
	}
}
