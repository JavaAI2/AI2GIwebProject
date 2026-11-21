package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import util.DBmanager;

/**
 * 현지 반품신청(배송 취소 · 환불) 전용 DAO.
 *
 * 배송 중(출고완료 · 국내 배송 중)인 주문을 취소하면, 한 번의 트랜잭션으로 아래를 처리한다.
 *   1) 그 주문의 결제완료 청구건(CHARGE)을 환불됨(REFUNDED)으로 바꾼다
 *   2) 청구건이 모두 환불된 결제(PAYMENT)는 환불완료(REFUNDED)로 바꾼다
 *   3) 환불 금액을 회원의 예치금(KURO_MEMBER.DEPOSIT)에 더한다
 *   4) 주문(BUY_ORDER)을 취소(CANCELED)로 바꾼다
 * 하나라도 실패하면 전부 되돌린다(rollback).
 *
 * 먼저 sql/08_order_cancel.sql 로 BUY_ORDER.STATUS 에 'CANCELED' 를 허용해 두어야 한다.
 */
public class RefundDAO {

	/** 현지 반품신청(환불) 허용 여부. 출고 이후에는 환불할 수 없으므로 false — 다시 열려면 true 로 바꾸고 listShipping 의 return 도 지운다 */
	private static final boolean REFUND_OPEN = false;

	/** 취소할 수 있는 배송 중 주문 한 건 (화면 목록용) */
	public record ShippingOrder(long orderId, String orderNo, String serviceType, String status,
			String firstItem, int itemCount, long paidAmount) { }

	/** 취소 결과 */
	public record RefundResult(boolean ok, String message, long refunded, String orderNo) { }

	/**
	 * 취소(환불)할 수 있는 내 주문 목록. 출고 이후(출고완료 · 국내 배송 중 · 배송 완료)에는 환불할 수 없으므로
	 * 현재는 항상 빈 목록이다. (환불 가능 단계를 다시 열 때는 아래 SQL 의 STATUS 조건을 바꾸고 이 return 을 지운다)
	 */
	public List<ShippingOrder> listShipping(long memberId) {

		if (!REFUND_OPEN) {
			return new ArrayList<>();
		}

		String sql = "SELECT o.ORDER_ID, o.ORDER_NO, o.SERVICE_TYPE, o.STATUS, "
				+ "(SELECT COUNT(*) FROM BUY_ORDER_ITEM i WHERE i.ORDER_ID = o.ORDER_ID) AS ITEM_CNT, "
				+ "(SELECT i.ITEM_NAME_EN FROM BUY_ORDER_ITEM i WHERE i.ORDER_ID = o.ORDER_ID AND i.ITEM_NO = 1) AS FIRST_ITEM, "
				+ "(SELECT NVL(SUM(c.AMOUNT), 0) FROM CHARGE c "
				+ "   WHERE c.ORDER_NO = o.ORDER_NO AND c.MEMBER_ID = o.MEMBER_ID AND c.STATUS = 'PAID') AS PAID_AMT "
				+ "FROM BUY_ORDER o "
				+ "WHERE o.MEMBER_ID = ? AND o.STATUS IN ('SHIPPED', 'DELIVERING') "
				+ "ORDER BY o.ORDER_ID DESC";

		List<ShippingOrder> list = new ArrayList<>();

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, memberId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(new ShippingOrder(
							rs.getLong("ORDER_ID"),
							rs.getString("ORDER_NO"),
							rs.getString("SERVICE_TYPE"),
							rs.getString("STATUS"),
							rs.getString("FIRST_ITEM"),
							rs.getInt("ITEM_CNT"),
							rs.getLong("PAID_AMT")));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 주문 1건을 취소하고 결제한 금액을 예치금으로 환불한다. (호출하는 쪽에서 회원별 락을 잡는다) */
	public RefundResult refund(long memberId, long orderId) {

		Connection conn = null;

		try {
			conn = DBmanager.getInstance();
			conn.setAutoCommit(false);

			// 1) 내 주문이고 배송 중인지 확인 (행을 잠가서 같은 주문이 두 번 취소되지 않게 한다)
			String orderNo = null;
			String status = null;
			try (PreparedStatement ps = conn.prepareStatement(
					"SELECT ORDER_NO, STATUS FROM BUY_ORDER WHERE ORDER_ID = ? AND MEMBER_ID = ? FOR UPDATE")) {
				ps.setLong(1, orderId);
				ps.setLong(2, memberId);
				try (ResultSet rs = ps.executeQuery()) {
					if (rs.next()) {
						orderNo = rs.getString("ORDER_NO");
						status = rs.getString("STATUS");
					}
				}
			}
			if (orderNo == null) {
				conn.rollback();
				return new RefundResult(false, "존재하지 않는 주문입니다.", 0, null);
			}
			if ("SHIPPED".equals(status) || "DELIVERING".equals(status) || "DELIVERED".equals(status)) {
				conn.rollback();
				return new RefundResult(false, orderNo + " : 출고 이후에는 환불할 수 없습니다.", 0, orderNo);
			}
			if (!REFUND_OPEN) {
				conn.rollback();
				return new RefundResult(false, orderNo + " : 환불할 수 없는 주문입니다.", 0, orderNo);
			}

			// 2) 이 주문으로 결제한 청구건 (결제완료인 것만 환불 대상)
			List<Long> chargeIds = new ArrayList<>();
			Set<Long> paymentIds = new LinkedHashSet<>();
			long refund = 0;
			try (PreparedStatement ps = conn.prepareStatement(
					"SELECT ID, PAYMENT_ID, AMOUNT FROM CHARGE "
							+ "WHERE ORDER_NO = ? AND MEMBER_ID = ? AND STATUS = 'PAID' FOR UPDATE")) {
				ps.setString(1, orderNo);
				ps.setLong(2, memberId);
				try (ResultSet rs = ps.executeQuery()) {
					while (rs.next()) {
						chargeIds.add(rs.getLong("ID"));
						long pid = rs.getLong("PAYMENT_ID");
						if (!rs.wasNull()) {
							paymentIds.add(pid);
						}
						refund += rs.getLong("AMOUNT");
					}
				}
			}

			// 3) 청구건을 환불됨으로
			try (PreparedStatement ps = conn.prepareStatement("UPDATE CHARGE SET STATUS = 'REFUNDED' WHERE ID = ?")) {
				for (Long id : chargeIds) {
					ps.setLong(1, id);
					ps.addBatch();
				}
				if (!chargeIds.isEmpty()) {
					ps.executeBatch();
				}
			}

			// 4) 묶여 있던 결제가 전부 환불되었으면 결제도 환불완료로
			for (Long pid : paymentIds) {
				int stillPaid = 0;
				try (PreparedStatement ps = conn.prepareStatement(
						"SELECT COUNT(*) FROM CHARGE WHERE PAYMENT_ID = ? AND STATUS = 'PAID'")) {
					ps.setLong(1, pid);
					try (ResultSet rs = ps.executeQuery()) {
						if (rs.next()) {
							stillPaid = rs.getInt(1);
						}
					}
				}
				if (stillPaid == 0) {
					try (PreparedStatement ps = conn.prepareStatement(
							"UPDATE PAYMENT SET STATUS = 'REFUNDED' WHERE ID = ?")) {
						ps.setLong(1, pid);
						ps.executeUpdate();
					}
				}
			}

			// 5) 환불 금액을 예치금으로
			if (refund > 0) {
				try (PreparedStatement ps = conn.prepareStatement(
						"UPDATE KURO_MEMBER SET DEPOSIT = NVL(DEPOSIT, 0) + ? WHERE ID = ?")) {
					ps.setLong(1, refund);
					ps.setLong(2, memberId);
					if (ps.executeUpdate() != 1) {
						conn.rollback();
						return new RefundResult(false, "회원 정보를 찾지 못해 환불하지 못했습니다.", 0, orderNo);
					}
				}
			}

			// 6) 주문을 취소로
			try (PreparedStatement ps = conn.prepareStatement(
					"UPDATE BUY_ORDER SET STATUS = 'CANCELED', STATUS_UPDATED_AT = SYSTIMESTAMP WHERE ORDER_ID = ?")) {
				ps.setLong(1, orderId);
				ps.executeUpdate();
			}

			conn.commit();
			return new RefundResult(true, "취소되었습니다.", refund, orderNo);

		} catch (Exception e) {
			e.printStackTrace();
			try {
				if (conn != null) conn.rollback();
			} catch (Exception ignore) {
				// 되돌리기 실패는 무시한다
			}
			return new RefundResult(false,
					"취소 처리 중 오류가 발생했습니다. (sql/08_order_cancel.sql 을 실행했는지 확인하세요)", 0, null);
		} finally {
			try {
				if (conn != null) conn.close();
			} catch (Exception ignore) {
				// 닫기 실패는 무시한다
			}
		}
	}
}
