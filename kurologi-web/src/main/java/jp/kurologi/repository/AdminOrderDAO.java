package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.model.BuyOrderItemDTO;
import util.DBmanager;

/**
 * 관리자용 주문 관리 DAO (구매대행 + 배송대행 주문 전체)
 * 접수대기(WAIT, 고객이 아직 신청 전인 임시 저장)는 관리자가 처리할 대상이 아니라서 모두 제외한다.
 */
public class AdminOrderDAO {

	public static final int PAGE_SIZE = 15;

	/**
	 * 상태 필터(st)를 WHERE 조건으로 바꾼다.
	 * 사용자가 보낸 글자를 SQL 에 이어 붙이지 않고, 아래 정해진 값 중 하나만 고르게 한다. (SQL Injection 방지)
	 */
	private String stCondition(String st) {
		switch (st) {
		case "submit":   return "o.STATUS = 'SUBMIT'";
		case "received": return "o.STATUS = 'RECEIVED'";
		case "billed":     return "o.STATUS = 'BILLED'";
		case "shipped":  return "o.STATUS = 'SHIPPED'";
		case "delivering": return "o.STATUS = 'DELIVERING'";
		case "delivered":  return "o.STATUS = 'DELIVERED'";
		case "unpaid":   return "o.STATUS <> 'WAIT' AND o.PAY_STATUS = 'UNPAID'";
		default:         return "o.STATUS <> 'WAIT'";
		}
	}

	/** 탭에 보여 줄 건수 : all, submit, received, billed, shipped, delivering, delivered, unpaid (svc 가 BUY / SHIP 이면 그 서비스만) */
	public Map<String, Integer> counts(String svc) {

		boolean bySvc = "BUY".equals(svc) || "SHIP".equals(svc);

		String sql = "SELECT COUNT(*) AS ALL_CNT, "
				+ "NVL(SUM(CASE WHEN o.STATUS = 'SUBMIT' THEN 1 ELSE 0 END), 0) AS SUBMIT_CNT, "
				+ "NVL(SUM(CASE WHEN o.STATUS = 'RECEIVED' THEN 1 ELSE 0 END), 0) AS RECEIVED_CNT, "
				+ "NVL(SUM(CASE WHEN o.STATUS = 'BILLED' THEN 1 ELSE 0 END), 0) AS BILLED_CNT, "
				+ "NVL(SUM(CASE WHEN o.STATUS = 'SHIPPED' THEN 1 ELSE 0 END), 0) AS SHIPPED_CNT, "
				+ "NVL(SUM(CASE WHEN o.STATUS = 'DELIVERING' THEN 1 ELSE 0 END), 0) AS DELIVERING_CNT, "
				+ "NVL(SUM(CASE WHEN o.STATUS = 'DELIVERED' THEN 1 ELSE 0 END), 0) AS DELIVERED_CNT, "
				+ "NVL(SUM(CASE WHEN o.PAY_STATUS = 'UNPAID' THEN 1 ELSE 0 END), 0) AS UNPAID_CNT "
				+ "FROM BUY_ORDER o WHERE o.STATUS <> 'WAIT'" + (bySvc ? " AND o.SERVICE_TYPE = ?" : "");

		Map<String, Integer> map = new LinkedHashMap<>();
		for (String k : new String[] { "all", "submit", "received", "billed", "shipped", "delivering", "delivered", "unpaid" }) {
			map.put(k, 0);
		}

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			if (bySvc) {
				pstmt.setString(1, svc);
			}
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					map.put("all", rs.getInt("ALL_CNT"));
					map.put("submit", rs.getInt("SUBMIT_CNT"));
					map.put("received", rs.getInt("RECEIVED_CNT"));
					map.put("billed", rs.getInt("BILLED_CNT"));
					map.put("shipped", rs.getInt("SHIPPED_CNT"));
					map.put("delivering", rs.getInt("DELIVERING_CNT"));
					map.put("delivered", rs.getInt("DELIVERED_CNT"));
					map.put("unpaid", rs.getInt("UNPAID_CNT"));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return map;
	}

	/** 주문 목록 (최신순, 한 페이지 PAGE_SIZE 건). 주문한 회원의 아이디 · 이름을 ANSI 조인으로 함께 가져온다. */
	public List<BuyOrderDTO> list(String svc, String st, int page) {

		boolean bySvc = "BUY".equals(svc) || "SHIP".equals(svc);

		String sql = "SELECT * FROM ("
				+ " SELECT a.*, ROWNUM RN FROM ("
				+ "  SELECT o.ORDER_ID, o.ORDER_NO, o.SERVICE_TYPE, o.STATUS, o.PAY_STATUS, o.RECV_NAME_KO, "
				+ "   o.TOTAL_QTY, o.TOTAL_YEN, o.APPLIED_RATE, o.TOTAL_KRW, "
				+ "   TO_CHAR(o.CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_TXT, m.LOGIN_ID, m.NAME AS MEMBER_NAME "
				+ "  FROM BUY_ORDER o JOIN KURO_MEMBER m ON m.ID = o.MEMBER_ID "
				+ "  WHERE " + stCondition(st) + (bySvc ? " AND o.SERVICE_TYPE = ?" : "")
				+ "  ORDER BY o.ORDER_ID DESC"
				+ " ) a WHERE ROWNUM <= ?"
				+ ") WHERE RN > ?";

		List<BuyOrderDTO> list = new ArrayList<>();

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			int idx = 1;
			if (bySvc) {
				pstmt.setString(idx++, svc);
			}
			pstmt.setInt(idx++, page * PAGE_SIZE);
			pstmt.setInt(idx, (page - 1) * PAGE_SIZE);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					BuyOrderDTO o = new BuyOrderDTO();
					o.setOrderId(rs.getLong("ORDER_ID"));
					o.setOrderNo(rs.getString("ORDER_NO"));
					o.setServiceType(rs.getString("SERVICE_TYPE"));
					o.setStatus(rs.getString("STATUS"));
					o.setPayStatus(rs.getString("PAY_STATUS"));
					o.setRecvNameKo(rs.getString("RECV_NAME_KO"));
					o.setTotalQty(rs.getInt("TOTAL_QTY"));
					o.setTotalYen(rs.getBigDecimal("TOTAL_YEN"));
					o.setAppliedRate(rs.getBigDecimal("APPLIED_RATE"));
					o.setTotalKrw(rs.getLong("TOTAL_KRW"));
					o.setCreatedAt(rs.getString("CREATED_TXT"));
					o.setMemberLoginId(rs.getString("LOGIN_ID"));
					o.setMemberName(rs.getString("MEMBER_NAME"));
					list.add(o);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 목록에 보이는 주문들의 상품을 한 번에 가져온다 (주문마다 쿼리하지 않고 IN 으로 한 번에) */
	public Map<Long, List<BuyOrderItemDTO>> itemsOf(List<BuyOrderDTO> orders) {

		Map<Long, List<BuyOrderItemDTO>> map = new LinkedHashMap<>();
		if (orders.isEmpty()) {
			return map;
		}

		StringBuilder in = new StringBuilder();
		for (int i = 0; i < orders.size(); i++) {
			in.append(i == 0 ? "?" : ", ?");
			map.put(orders.get(i).getOrderId(), new ArrayList<BuyOrderItemDTO>());
		}

		String sql = "SELECT ORDER_ID, ITEM_NO, ITEM_NAME_EN, QTY, TRACKING_NO, SHOP_SITE "
				+ "FROM BUY_ORDER_ITEM WHERE ORDER_ID IN (" + in + ") ORDER BY ORDER_ID, ITEM_NO";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			for (int i = 0; i < orders.size(); i++) {
				pstmt.setLong(i + 1, orders.get(i).getOrderId());
			}
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					BuyOrderItemDTO it = new BuyOrderItemDTO();
					it.setOrderId(rs.getLong("ORDER_ID"));
					it.setItemNo(rs.getInt("ITEM_NO"));
					it.setItemNameEn(rs.getString("ITEM_NAME_EN"));
					it.setQty(rs.getInt("QTY"));
					it.setTrackingNo(rs.getString("TRACKING_NO"));
					it.setShopSite(rs.getString("SHOP_SITE"));
					map.get(it.getOrderId()).add(it);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return map;
	}

	/** 삭제 결과 : 지운 주문 수와, 회원들에게 예치금으로 환불한 금액 합계(원) */
	public record DeleteResult(int deleted, long refunded) { }

	/**
	 * 선택한 주문을 완전히 지우고, 결제한 금액은 회원의 예치금으로 환불한다.
	 * 하나라도 실패하면 전부 되돌리고 null 을 돌려준다.
	 *   0) 주문의 결제완료(PAID) 청구 금액 합계를 그 주문을 한 회원의 예치금(KURO_MEMBER.DEPOSIT)에 더한다
	 *   1) 주문의 청구(CHARGE : 비용결제 · 결제내역에 보이는 줄)를 지운다
	 *   2) 주문을 지운다 (상품 BUY_ORDER_ITEM 은 ON DELETE CASCADE 로 같이 지워진다)
	 *   3) 그 청구가 묶여 있던 결제(PAYMENT)에 다른 청구가 하나도 남지 않았으면 결제도 지운다
	 *      (여러 주문을 한 번에 결제한 경우, 다른 주문이 남아 있으면 결제는 그대로 둔다)
		 */
	public DeleteResult deleteOrders(List<Long> orderIds) {

		if (orderIds == null || orderIds.isEmpty()) {
			return new DeleteResult(0, 0);
		}

		Connection conn = null;
		try {
			conn = DBmanager.getInstance();
			conn.setAutoCommit(false);

			Set<Long> paymentIds = new LinkedHashSet<>();
			int deleted = 0;
			long refundedTotal = 0;

			for (Long orderId : orderIds) {
				String orderNo = null;
				long memberId = 0;
				try (PreparedStatement ps = conn.prepareStatement("SELECT ORDER_NO, MEMBER_ID FROM BUY_ORDER WHERE ORDER_ID = ? FOR UPDATE")) {
					ps.setLong(1, orderId);
					try (ResultSet rs = ps.executeQuery()) {
						if (rs.next()) {
							orderNo = rs.getString(1);
							memberId = rs.getLong(2);
						}
					}
				}
				if (orderNo == null) {
					continue;   // 이미 지워진 주문
				}

				// 결제가 끝난 청구 금액은 예치금으로 환불한다 (이미 환불된 청구는 STATUS 가 달라 더하지 않는다)
				long refund = 0;
				try (PreparedStatement ps = conn.prepareStatement(
						"SELECT NVL(SUM(AMOUNT), 0) FROM CHARGE WHERE ORDER_NO = ? AND MEMBER_ID = ? AND STATUS = 'PAID'")) {
					ps.setString(1, orderNo);
					ps.setLong(2, memberId);
					try (ResultSet rs = ps.executeQuery()) {
						if (rs.next()) {
							refund = rs.getLong(1);
						}
					}
				}
				if (refund > 0) {
					try (PreparedStatement ps = conn.prepareStatement("UPDATE KURO_MEMBER SET DEPOSIT = NVL(DEPOSIT, 0) + ? WHERE ID = ?")) {
						ps.setLong(1, refund);
						ps.setLong(2, memberId);
						if (ps.executeUpdate() != 1) {
							throw new IllegalStateException("환불할 회원을 찾지 못했습니다. (회원 번호 " + memberId + ")");
						}
					}
					refundedTotal += refund;
				}

				try (PreparedStatement ps = conn.prepareStatement("SELECT DISTINCT PAYMENT_ID FROM CHARGE WHERE ORDER_NO = ? AND PAYMENT_ID IS NOT NULL")) {
					ps.setString(1, orderNo);
					try (ResultSet rs = ps.executeQuery()) {
						while (rs.next()) {
							paymentIds.add(rs.getLong(1));
						}
					}
				}
				try (PreparedStatement ps = conn.prepareStatement("DELETE FROM CHARGE WHERE ORDER_NO = ?")) {
					ps.setString(1, orderNo);
					ps.executeUpdate();
				}
				try (PreparedStatement ps = conn.prepareStatement("DELETE FROM BUY_ORDER WHERE ORDER_ID = ?")) {
					ps.setLong(1, orderId);
					deleted += ps.executeUpdate();
				}
			}

			for (Long pid : paymentIds) {
				int left = 0;
				try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM CHARGE WHERE PAYMENT_ID = ?")) {
					ps.setLong(1, pid);
					try (ResultSet rs = ps.executeQuery()) {
						if (rs.next()) {
							left = rs.getInt(1);
						}
					}
				}
				if (left == 0) {
					try (PreparedStatement ps = conn.prepareStatement("DELETE FROM PAYMENT WHERE ID = ?")) {
						ps.setLong(1, pid);
						ps.executeUpdate();
					}
				}
			}

			conn.commit();
			return new DeleteResult(deleted, refundedTotal);

		} catch (Exception e) {
			e.printStackTrace();
			try {
				if (conn != null) conn.rollback();
			} catch (Exception ignore) {
				// 되돌리기 실패는 무시한다
			}
			return null;
		} finally {
			try {
				if (conn != null) conn.close();
			} catch (Exception ignore) {
				// 닫기 실패는 무시한다
			}
		}
	}

	/**
	 * 주문을 다음 단계로 넘긴다. 성공하면 true.
	 * 현재 상태를 WHERE 에 함께 적어서, 이미 처리된 주문이거나 순서가 안 맞으면 0건이 바뀌고 false 가 된다.
	 * (같은 버튼을 두 번 눌러도, 두 관리자가 동시에 눌러도 단계가 꼬이지 않는다)
	 *   receive : 접수신청 -> 입고완료
	 *   pay     : 미결제 -> 결제완료 (입금 확인)
	 *   ship    : (입고완료 또는 배송비 대기) + 결제완료 -> 출고완료
	 *   customs : 출고완료 -> 국내 배송 중   (한국 입국 · 세관 통관이 끝나 한국 택배사로 넘어감)
	 *   deliver : 국내 배송 중 -> 배송 완료   (한국 택배가 고객에게 전달됨)
	 */
	public boolean advance(long orderId, String action) {

		String sql;
		switch (action) {
		case "receive":
			sql = "UPDATE BUY_ORDER SET STATUS = 'RECEIVED', STATUS_UPDATED_AT = SYSTIMESTAMP "
					+ "WHERE ORDER_ID = ? AND STATUS = 'SUBMIT'";
			break;
		case "pay":
			sql = "UPDATE BUY_ORDER SET PAY_STATUS = 'PAID', STATUS_UPDATED_AT = SYSTIMESTAMP "
					+ "WHERE ORDER_ID = ? AND STATUS <> 'WAIT' AND PAY_STATUS = 'UNPAID'";
			break;
		case "ship":
			sql = "UPDATE BUY_ORDER SET STATUS = 'SHIPPED', STATUS_UPDATED_AT = SYSTIMESTAMP, SHIPPED_AT = SYSTIMESTAMP "
					+ "WHERE ORDER_ID = ? AND STATUS IN ('RECEIVED', 'BILLED') AND PAY_STATUS = 'PAID'";
			break;
		case "customs":
			sql = "UPDATE BUY_ORDER SET STATUS = 'DELIVERING', STATUS_UPDATED_AT = SYSTIMESTAMP, CUSTOMS_AT = SYSTIMESTAMP "
					+ "WHERE ORDER_ID = ? AND STATUS = 'SHIPPED'";
			break;
		case "deliver":
			sql = "UPDATE BUY_ORDER SET STATUS = 'DELIVERED', STATUS_UPDATED_AT = SYSTIMESTAMP, DELIVERED_AT = SYSTIMESTAMP "
					+ "WHERE ORDER_ID = ? AND STATUS = 'DELIVERING'";
			break;
		default:
			return false;
		}

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, orderId);
			return pstmt.executeUpdate() == 1;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}