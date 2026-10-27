package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

import util.DBmanager;

/**
 * 관리자 기능 전용 DAO (커뮤니티 관리 화면용)
 * 회원 테이블(KURO_MEMBER)은 읽기만 하고, 회원 쪽 DAO/DTO 는 건드리지 않는다.
 */
public class AdminDAO {

	/**
	 * 관리자인지 확인. ROLE 이 'ADMIN' 이고 탈퇴하지 않은 회원만 true.
	 * ROLE 컬럼이 아직 없거나 DB 오류가 나면 false (= 관리자 화면은 열리지 않는다. 일반 화면에는 영향 없음)
	 */
	public boolean isAdmin(long memberId) {

		String sql = "SELECT 1 FROM KURO_MEMBER WHERE ID = ? AND ROLE = 'ADMIN' AND NVL(WITHDRAWN, 'N') = 'N'";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, memberId);
			try (ResultSet rs = pstmt.executeQuery()) {
				return rs.next();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * 관리자 첫 화면의 현황 숫자 (한 번의 조회로 모두 가져온다). 실패하면 빈 Map
	 *   QNA_WAIT 답변 대기 문의 / QNA_ALL 전체 문의 / NOTICE_CNT 공지 / FAQ_CNT FAQ / DEAL_CNT 특가 / MSG_CNT 알림 발송 누적
	 */
	public Map<String, Integer> summary() {

		String sql = "SELECT "
				+ "(SELECT COUNT(*) FROM COMMUNITY_POST WHERE BOARD_TYPE = 'QNA' AND ANSWER_YN = 'N') AS QNA_WAIT, "
				+ "(SELECT COUNT(*) FROM COMMUNITY_POST WHERE BOARD_TYPE = 'QNA') AS QNA_ALL, "
				+ "(SELECT COUNT(*) FROM COMMUNITY_POST WHERE BOARD_TYPE = 'NOTICE') AS NOTICE_CNT, "
				+ "(SELECT COUNT(*) FROM COMMUNITY_FAQ) AS FAQ_CNT, "
				+ "(SELECT COUNT(*) FROM COMMUNITY_DEAL) AS DEAL_CNT, "
				+ "(SELECT COUNT(*) FROM COMMUNITY_MESSAGE) AS MSG_CNT "
				+ "FROM DUAL";

		Map<String, Integer> stats = new LinkedHashMap<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql);
				ResultSet rs = pstmt.executeQuery()) {
			if (rs.next()) {
				for (String key : new String[] { "QNA_WAIT", "QNA_ALL", "NOTICE_CNT", "FAQ_CNT", "DEAL_CNT", "MSG_CNT" }) {
					stats.put(key, rs.getInt(key));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return stats;
	}
}