package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import jp.kurologi.model.AdminMessageDTO;
import util.DBmanager;

/**
 * 관리자용 알림메세지 DAO — 전체 회원에게 나간 알림 이력 조회와 알림 발송.
 * (회원 본인용 MessageDAO 는 "내 알림"만 다루므로 그대로 두고, 관리자 기능은 이 클래스에 따로 둔다)
 */
public class AdminMessageDAO {

	private static final String FROM_JOIN =
			" FROM COMMUNITY_MESSAGE c LEFT JOIN KURO_MEMBER m ON c.MEMBER_ID = m.ID";

	/**
	 * WHERE 절 + ? 에 넣을 값 만들기
	 * searchType : "member"(받는 회원 이름·아이디) / "type"(구분) / "content"(내용) / 그 외 구분+내용
	 */
	private String where(String searchType, String keyword, List<Object> params) {
		StringBuilder sb = new StringBuilder(" WHERE 1 = 1");

		if (keyword != null && !keyword.trim().isEmpty()) {
			String like = DaoUtil.likePattern(keyword.trim());
			if ("member".equals(searchType)) {
				sb.append(" AND (m.NAME LIKE ? ESCAPE '\\' OR m.LOGIN_ID LIKE ? ESCAPE '\\')");
				params.add(like);
				params.add(like);
			} else if ("type".equals(searchType)) {
				sb.append(" AND c.MSG_TYPE LIKE ? ESCAPE '\\'");
				params.add(like);
			} else if ("content".equals(searchType)) {
				sb.append(" AND c.CONTENT LIKE ? ESCAPE '\\'");
				params.add(like);
			} else {
				sb.append(" AND (c.MSG_TYPE LIKE ? ESCAPE '\\' OR c.CONTENT LIKE ? ESCAPE '\\')");
				params.add(like);
				params.add(like);
			}
		}
		return sb.toString();
	}

	/** 조건에 맞는 알림 개수 (페이지 수 계산용). 실패하면 0 */
	public int selectCount(String searchType, String keyword) {

		List<Object> params = new ArrayList<>();
		String sql = "SELECT COUNT(*)" + FROM_JOIN + where(searchType, keyword, params);

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			DaoUtil.bind(pstmt, params);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return rs.getInt(1);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 발송 이력 한 페이지 (최신이 위). startRow ~ endRow 는 1부터 시작하는 줄 번호 */
	public List<AdminMessageDTO> selectList(String searchType, String keyword, int startRow, int endRow) {

		List<Object> params = new ArrayList<>();
		String sql = "SELECT * FROM ("
				+ " SELECT ROWNUM RN, T.* FROM ("
				+ "  SELECT c.MESSAGE_ID, c.MEMBER_ID, m.NAME || ' (' || m.LOGIN_ID || ')' AS MEMBER_TEXT, "
				+ "         c.MSG_TYPE, c.CONTENT, TO_CHAR(c.SENT_AT, 'YYYY-MM-DD HH24:MI') AS SENT_AT, c.READ_YN"
				+ FROM_JOIN
				+ where(searchType, keyword, params)
				+ "  ORDER BY c.MESSAGE_ID DESC"
				+ " ) T WHERE ROWNUM <= ?"
				+ ") WHERE RN >= ?";
		params.add(endRow);
		params.add(startRow);

		List<AdminMessageDTO> list = new ArrayList<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			DaoUtil.bind(pstmt, params);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					AdminMessageDTO dto = new AdminMessageDTO();
					dto.setMessageId(rs.getLong("MESSAGE_ID"));
					dto.setMemberId(rs.getLong("MEMBER_ID"));
					dto.setMemberText(rs.getString("MEMBER_TEXT"));
					dto.setMsgType(rs.getString("MSG_TYPE"));
					dto.setContent(rs.getString("CONTENT"));
					dto.setSentAt(rs.getString("SENT_AT"));
					dto.setRead("Y".equals(rs.getString("READ_YN")));
					list.add(dto);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** "전체 회원" 발송 대상 수 (탈퇴하지 않은 회원). 실패하면 0 */
	public int countActiveMembers() {

		String sql = "SELECT COUNT(*) FROM KURO_MEMBER WHERE NVL(WITHDRAWN, 'N') = 'N'";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql);
				ResultSet rs = pstmt.executeQuery()) {
			if (rs.next()) {
				return rs.getInt(1);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/**
	 * 로그인 아이디 목록 -> (로그인 아이디 -> 회원 번호). 존재하고 탈퇴하지 않은 회원만 담긴다.
	 * 목록에 있는데 결과에 없는 아이디 = 없는 회원 (Service 가 오류로 알려 준다)
	 */
	public Map<String, Long> findActiveMemberIds(List<String> loginIds) {

		Map<String, Long> found = new LinkedHashMap<>();
		if (loginIds == null || loginIds.isEmpty()) {
			return found;
		}

		String sql = "SELECT LOGIN_ID, ID FROM KURO_MEMBER WHERE NVL(WITHDRAWN, 'N') = 'N' AND LOGIN_ID IN ("
				+ String.join(",", Collections.nCopies(loginIds.size(), "?")) + ")";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			for (int i = 0; i < loginIds.size(); i++) {
				pstmt.setString(i + 1, loginIds.get(i));
			}
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					found.put(rs.getString(1), rs.getLong(2));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return found;
	}

	/**
	 * 선택한 회원들에게 알림 발송 — 한 묶음으로 처리한다 (중간에 실패하면 전부 취소 = 롤백)
	 * 성공하면 발송한 건수, 실패하면 -1
	 */
	public int sendToMembers(List<Long> memberIds, String msgType, String content) {

		String sql = "INSERT INTO COMMUNITY_MESSAGE (MESSAGE_ID, MEMBER_ID, MSG_TYPE, CONTENT) "
				+ "VALUES (SEQ_COMMUNITY_MESSAGE.NEXTVAL, ?, ?, ?)";

		try (Connection conn = DBmanager.getInstance()) {
			conn.setAutoCommit(false);
			try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
				for (Long memberId : memberIds) {
					pstmt.setLong(1, memberId);
					pstmt.setString(2, msgType);
					pstmt.setString(3, content);
					pstmt.addBatch();
				}
				pstmt.executeBatch();
				conn.commit();
				return memberIds.size();
			} catch (Exception e) {
				try {
					conn.rollback();
				} catch (Exception ignore) {
					// 롤백 실패는 원래 오류를 보는 게 더 중요해서 무시
				}
				throw e;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return -1;
	}

	/**
	 * 전체 회원(탈퇴하지 않은 회원)에게 알림 발송 — SQL 한 문장이라 전부 들어가거나 전부 안 들어간다
	 * 성공하면 발송한 건수, 실패하면 -1
	 */
	public int sendToAll(String msgType, String content) {

		String sql = "INSERT INTO COMMUNITY_MESSAGE (MESSAGE_ID, MEMBER_ID, MSG_TYPE, CONTENT) "
				+ "SELECT SEQ_COMMUNITY_MESSAGE.NEXTVAL, ID, ?, ? FROM KURO_MEMBER WHERE NVL(WITHDRAWN, 'N') = 'N'";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, msgType);
			pstmt.setString(2, content);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return -1;
	}
}