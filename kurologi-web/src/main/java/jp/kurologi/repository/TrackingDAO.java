package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

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
}
