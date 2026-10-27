package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.MessageDTO;
import util.DBmanager;

/**
 * COMMUNITY_MESSAGE 테이블 전용 DAO (알림메세지)
 * 모든 조회/수정/삭제는 memberId(로그인한 회원 번호)를 함께 받아서 "내 알림"만 다룬다.
 */
public class MessageDAO {

	/**
	 * WHERE 절 + ? 에 넣을 값 만들기
	 * searchType : "type"(구분) / "content"(내용) / 그 외(구분+내용)
	 */
	private String where(long memberId, String searchType, String keyword, List<Object> params) {
		StringBuilder sb = new StringBuilder(" WHERE MEMBER_ID = ?");
		params.add(memberId);

		if (keyword != null && !keyword.trim().isEmpty()) {
			String like = DaoUtil.likePattern(keyword.trim());
			if ("type".equals(searchType)) {
				sb.append(" AND MSG_TYPE LIKE ? ESCAPE '\\'");
				params.add(like);
			} else if ("content".equals(searchType)) {
				sb.append(" AND CONTENT LIKE ? ESCAPE '\\'");
				params.add(like);
			} else {
				sb.append(" AND (MSG_TYPE LIKE ? ESCAPE '\\' OR CONTENT LIKE ? ESCAPE '\\')");
				params.add(like);
				params.add(like);
			}
		}
		return sb.toString();
	}

	/** 내 알림 개수 (검색 조건 포함). 실패하면 0 */
	public int selectCount(long memberId, String searchType, String keyword) {

		List<Object> params = new ArrayList<>();
		String sql = "SELECT COUNT(*) FROM COMMUNITY_MESSAGE" + where(memberId, searchType, keyword, params);

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

	/** 내 알림 한 페이지 (최신이 위). startRow ~ endRow 는 1부터 시작하는 줄 번호 */
	public List<MessageDTO> selectList(long memberId, String searchType, String keyword, int startRow, int endRow) {

		List<Object> params = new ArrayList<>();
		String sql = "SELECT * FROM ("
				+ " SELECT ROWNUM RN, T.* FROM ("
				+ "  SELECT MESSAGE_ID, MEMBER_ID, MSG_TYPE, CONTENT, "
				+ "         TO_CHAR(SENT_AT, 'YYYY-MM-DD HH24:MI') AS SENT_AT, READ_YN "
				+ "  FROM COMMUNITY_MESSAGE"
				+ where(memberId, searchType, keyword, params)
				+ "  ORDER BY MESSAGE_ID DESC"
				+ " ) T WHERE ROWNUM <= ?"
				+ ") WHERE RN >= ?";
		params.add(endRow);
		params.add(startRow);

		List<MessageDTO> list = new ArrayList<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			DaoUtil.bind(pstmt, params);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					MessageDTO dto = new MessageDTO();
					dto.setMessageId(rs.getLong("MESSAGE_ID"));
					dto.setMemberId(rs.getLong("MEMBER_ID"));
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

	/** 내 알림을 "확인함"으로 바꾼다. 성공하면 1, 내 알림이 아니면 0 */
	public int markRead(long messageId, long memberId) {

		String sql = "UPDATE COMMUNITY_MESSAGE SET READ_YN = 'Y' WHERE MESSAGE_ID = ? AND MEMBER_ID = ?";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, messageId);
			pstmt.setLong(2, memberId);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 내 알림 삭제. 성공하면 1, 내 알림이 아니면 0 */
	public int delete(long messageId, long memberId) {

		String sql = "DELETE FROM COMMUNITY_MESSAGE WHERE MESSAGE_ID = ? AND MEMBER_ID = ?";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, messageId);
			pstmt.setLong(2, memberId);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 다음 알림 번호(SEQ_COMMUNITY_MESSAGE). 실패하면 -1 */
	public long nextId() {

		String sql = "SELECT SEQ_COMMUNITY_MESSAGE.NEXTVAL FROM DUAL";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql);
				ResultSet rs = pstmt.executeQuery()) {
			if (rs.next()) {
				return rs.getLong(1);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return -1;
	}

	/**
	 * 알림 등록 (입고/출고/배송 상태가 바뀔 때 다른 기능에서 호출할 수 있다). 성공하면 1, 실패하면 0.
	 * messageId 는 nextId() 로 받은 값을 dto 에 넣어서 넘긴다. 발송일시/읽음 여부는 DEFAULT 에 맡긴다.
	 */
	public int insert(MessageDTO dto) {

		String sql = "INSERT INTO COMMUNITY_MESSAGE (MESSAGE_ID, MEMBER_ID, MSG_TYPE, CONTENT) VALUES (?, ?, ?, ?)";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, dto.getMessageId());
			pstmt.setLong(2, dto.getMemberId());
			pstmt.setString(3, dto.getMsgType());
			pstmt.setString(4, dto.getContent());
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}
}