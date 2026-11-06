package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.Waybill;

/**
 * [시험용] 운송장 조회 전용 DAO. PAYMENT 테이블의 운송장 컬럼에서 결제가 끝난 건만 찾는다.
 * 누구나(로그인하지 않아도) 운송장번호만 알면 조회할 수 있으므로, 회원 정보나 주문 내용은 돌려주지 않는다.
 */
public class TrackingDAO {

	/** 조회 결과 : 화면에 보여 줄 값만 담는다 */
	public record TrackingInfo(String typeLabel, String number, String status, String paidAt) { }

	/** 한국 운송장 조회. method = AIR / SEA. 없으면 null */
	public TrackingInfo findKorean(String method, String number) {
		String sql = "SELECT TO_CHAR(PAID_AT, 'YYYY-MM-DD HH24:MI') AS PAID_TXT FROM PAYMENT "
				+ "WHERE KR_WAYBILL_NO = ? AND KR_METHOD = ? AND STATUS = 'PAID'";
		String paidAt = findOne(sql, number, method);
		return paidAt == null ? null : new TrackingInfo(Waybill.krLabel(method), number, "결제 완료 · 출고 준비중 (시험용)", paidAt);
	}

	/** 일본 운송장 조회. carrier = YAMATO ... MEITETSU. 없으면 null */
	public TrackingInfo findJapanese(String carrier, String number) {
		String sql = "SELECT TO_CHAR(PAID_AT, 'YYYY-MM-DD HH24:MI') AS PAID_TXT FROM PAYMENT "
				+ "WHERE JP_WAYBILL_NO = ? AND JP_CARRIER = ? AND STATUS = 'PAID'";
		String paidAt = findOne(sql, number, carrier);
		return paidAt == null ? null : new TrackingInfo(Waybill.jpLabel(carrier), number, "결제 완료 · 일본 현지 집하 대기 (시험용)", paidAt);
	}

	/** 첫 번째 행의 PAID_TXT 를 돌려준다 (없으면 null, DB 오류는 예외로 알린다) */
	private String findOne(String sql, String number, String type) {
		try (Connection conn = MemberDAO.conn(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, number);
			ps.setString(2, type);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					String t = rs.getString("PAID_TXT");
					return t == null ? "-" : t;
				}
			}
		} catch (Exception e) {
			throw new IllegalStateException("운송장을 조회하지 못했습니다.", e);
		}
		return null;
	}

	/** 관리자 주문 관리의 배송 추적용 : 주문 1건의 진행 상태와, 그 주문의 결제에 배정된 일본 / 한국 운송장 */
	public record OrderTrackData(String orderNo, String status, String createdAt, String statusUpdatedAt,
			String krMethod, String krWaybillNo, String jpCarrier, String jpWaybillNo, String paidAt,
			List<String> shopTrackingNos) { }

	/**
	 * 주문(ORDER_ID) 1건의 배송 추적 자료를 읽는다. 주문이 없으면 null.
	 * 운송장은 주문 -> 청구(CHARGE.ORDER_NO) -> 결제(PAYMENT.ID)로 이어서 찾는다. 결제가 끝나기 전이면 운송장은 null.
	 */
	public OrderTrackData findOrderTrack(long orderId) {
		String sql = "SELECT o.ORDER_NO, o.STATUS, TO_CHAR(o.CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_TXT, "
				+ "TO_CHAR(o.STATUS_UPDATED_AT, 'YYYY-MM-DD HH24:MI') AS UPDATED_TXT, "
				+ "p.KR_METHOD, p.KR_WAYBILL_NO, p.JP_CARRIER, p.JP_WAYBILL_NO, "
				+ "TO_CHAR(p.PAID_AT, 'YYYY-MM-DD HH24:MI') AS PAID_TXT "
				+ "FROM BUY_ORDER o "
				+ "LEFT JOIN CHARGE c ON c.ORDER_NO = o.ORDER_NO "
				+ "LEFT JOIN PAYMENT p ON p.ID = c.PAYMENT_ID AND p.STATUS = 'PAID' "
				+ "WHERE o.ORDER_ID = ? ORDER BY p.PAID_AT DESC NULLS LAST";
		String itemSql = "SELECT TRACKING_NO FROM BUY_ORDER_ITEM "
				+ "WHERE ORDER_ID = ? AND TRACKING_NO IS NOT NULL ORDER BY ITEM_NO";

		try (Connection conn = MemberDAO.conn()) {
			List<String> shopNos = new ArrayList<>();
			try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
				ps.setLong(1, orderId);
				try (ResultSet rs = ps.executeQuery()) {
					while (rs.next()) {
						String t = rs.getString(1);
						if (t != null && !t.trim().isEmpty()) {
							shopNos.add(t.trim());
						}
					}
				}
			}
			try (PreparedStatement ps = conn.prepareStatement(sql)) {
				ps.setLong(1, orderId);
				try (ResultSet rs = ps.executeQuery()) {
					if (rs.next()) {   // 결제 시각이 가장 최근인 행 하나
						return new OrderTrackData(rs.getString("ORDER_NO"), rs.getString("STATUS"),
								rs.getString("CREATED_TXT"), rs.getString("UPDATED_TXT"),
								rs.getString("KR_METHOD"), rs.getString("KR_WAYBILL_NO"),
								rs.getString("JP_CARRIER"), rs.getString("JP_WAYBILL_NO"),
								rs.getString("PAID_TXT"), shopNos);
					}
				}
			}
		} catch (Exception e) {
			throw new IllegalStateException("주문의 운송장을 읽지 못했습니다.", e);
		}
		return null;
	}
}