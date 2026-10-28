package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.PostDTO;
import util.DBmanager;

/**
 * 관리자용 1:1 문의 DAO — 회원 구별 없이 "전체 회원"의 문의를 다룬다.
 * (회원 본인용 PostDAO 는 건드리지 않고, 관리자 기능은 이 클래스에 따로 둔다)
 *
 * 작성자 표시(writerName)는 "이름 (로그인아이디)" 모양으로 채운다. 회원이 삭제되어 없으면 null.
 */
public class AdminQnaDAO {

	private static final String FROM_JOIN =
			" FROM COMMUNITY_POST p LEFT JOIN KURO_MEMBER m ON p.WRITER_ID = m.ID";

	private static final String WRITER_TEXT = "m.NAME || ' (' || m.LOGIN_ID || ')'";

	/**
	 * WHERE 절 + ? 에 넣을 값 만들기
	 * status     : "wait"(답변 대기) / "done"(답변 완료) / 그 외 전체
	 * searchType : "title" / "content" / "writer"(이름 또는 아이디) / 그 외 제목+내용
	 */
	private String where(String status, String searchType, String keyword, List<Object> params) {
		StringBuilder sb = new StringBuilder(" WHERE p.BOARD_TYPE = 'QNA'");

		if ("wait".equals(status)) {
			sb.append(" AND p.ANSWER_YN = 'N'");
		} else if ("done".equals(status)) {
			sb.append(" AND p.ANSWER_YN = 'Y'");
		}

		if (keyword != null && !keyword.trim().isEmpty()) {
			String like = DaoUtil.likePattern(keyword.trim());
			if ("title".equals(searchType)) {
				sb.append(" AND p.TITLE LIKE ? ESCAPE '\\'");
				params.add(like);
			} else if ("content".equals(searchType)) {
				sb.append(" AND p.CONTENT LIKE ? ESCAPE '\\'");
				params.add(like);
			} else if ("writer".equals(searchType)) {
				sb.append(" AND (m.NAME LIKE ? ESCAPE '\\' OR m.LOGIN_ID LIKE ? ESCAPE '\\')");
				params.add(like);
				params.add(like);
			} else {
				sb.append(" AND (p.TITLE LIKE ? ESCAPE '\\' OR p.CONTENT LIKE ? ESCAPE '\\')");
				params.add(like);
				params.add(like);
			}
		}
		return sb.toString();
	}

	/** 조건에 맞는 문의 개수. 실패하면 0 */
	public int selectCount(String status, String searchType, String keyword) {

		List<Object> params = new ArrayList<>();
		String sql = "SELECT COUNT(*)" + FROM_JOIN + where(status, searchType, keyword, params);

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

	/** 목록 한 페이지 (최신 문의가 위). startRow ~ endRow 는 1부터 시작하는 줄 번호 */
	public List<PostDTO> selectList(String status, String searchType, String keyword, int startRow, int endRow) {

		List<Object> params = new ArrayList<>();
		String sql = "SELECT * FROM ("
				+ " SELECT ROWNUM RN, T.* FROM ("
				+ "  SELECT p.POST_ID, p.TITLE, p.WRITER_ID, " + WRITER_TEXT + " AS WRITER_NAME, "
				+ "         p.VIEW_COUNT, p.ANSWER_YN, TO_CHAR(p.CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_AT"
				+ FROM_JOIN
				+ where(status, searchType, keyword, params)
				+ "  ORDER BY p.POST_ID DESC"
				+ " ) T WHERE ROWNUM <= ?"
				+ ") WHERE RN >= ?";
		params.add(endRow);
		params.add(startRow);

		List<PostDTO> list = new ArrayList<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			DaoUtil.bind(pstmt, params);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					list.add(map(rs, false));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 문의 1건 상세 (내용 포함). 없거나 1:1 문의가 아니면 null */
	public PostDTO selectOne(long postId) {

		String sql = "SELECT p.POST_ID, p.TITLE, p.CONTENT, p.WRITER_ID, " + WRITER_TEXT + " AS WRITER_NAME, "
				+ "p.VIEW_COUNT, p.ANSWER_YN, "
				+ "TO_CHAR(p.CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_AT, "
				+ "TO_CHAR(p.UPDATED_AT, 'YYYY-MM-DD HH24:MI') AS UPDATED_AT"
				+ FROM_JOIN
				+ " WHERE p.POST_ID = ? AND p.BOARD_TYPE = 'QNA'";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, postId);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return map(rs, true);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 답변 등록 — 아래 3가지를 "한 묶음"으로 처리한다 (하나라도 실패하면 전부 취소 = 롤백)
	 *   1) 답변을 COMMUNITY_COMMENT 에 저장 (WRITER_ID 는 NULL = 관리자)
	 *   2) 문의 상태를 답변 완료(ANSWER_YN = 'Y')로 변경
	 *   3) 문의한 회원에게 알림메세지 1건 발송
	 * 성공하면 true. 문의가 없거나 오류가 나면 false.
	 */
	public boolean answer(long postId, String content) {

		try (Connection conn = DBmanager.getInstance()) {
			conn.setAutoCommit(false);     // 여기서부터 commit() 을 부르기 전까지는 DB 에 확정되지 않는다
			try {
				// 문의를 잠그고 제목/작성 회원을 읽는다 (동시에 다른 관리자가 처리하는 것 방지)
				String title = null;
				Long writerId = null;
				String sqlPost = "SELECT TITLE, WRITER_ID FROM COMMUNITY_POST WHERE POST_ID = ? AND BOARD_TYPE = 'QNA' FOR UPDATE";
				try (PreparedStatement pstmt = conn.prepareStatement(sqlPost)) {
					pstmt.setLong(1, postId);
					try (ResultSet rs = pstmt.executeQuery()) {
						if (!rs.next()) {
							conn.rollback();
							return false;
						}
						title = rs.getString(1);
						long w = rs.getLong(2);
						if (!rs.wasNull()) {
							writerId = w;
						}
					}
				}

				// 1) 답변 저장
				long commentId = nextVal(conn, "SEQ_COMMUNITY_COMMENT");
				try (PreparedStatement pstmt = conn.prepareStatement(
						"INSERT INTO COMMUNITY_COMMENT (COMMENT_ID, POST_ID, CONTENT) VALUES (?, ?, ?)")) {
					pstmt.setLong(1, commentId);
					pstmt.setLong(2, postId);
					pstmt.setString(3, content);
					pstmt.executeUpdate();
				}

				// 2) 답변 완료로 변경
				try (PreparedStatement pstmt = conn.prepareStatement(
						"UPDATE COMMUNITY_POST SET ANSWER_YN = 'Y' WHERE POST_ID = ?")) {
					pstmt.setLong(1, postId);
					pstmt.executeUpdate();
				}

				// 3) 문의한 회원에게 알림 (회원이 이미 없으면 건너뜀)
				if (writerId != null) {
					long messageId = nextVal(conn, "SEQ_COMMUNITY_MESSAGE");
					try (PreparedStatement pstmt = conn.prepareStatement(
							"INSERT INTO COMMUNITY_MESSAGE (MESSAGE_ID, MEMBER_ID, MSG_TYPE, CONTENT) VALUES (?, ?, ?, ?)")) {
						pstmt.setLong(1, messageId);
						pstmt.setLong(2, writerId);
						pstmt.setString(3, "1:1문의");
						pstmt.setString(4, "[" + title + "] 문의에 답변이 등록되었습니다. 1:1게시판에서 확인해 주세요.");
						pstmt.executeUpdate();
					}
				}

				conn.commit();
				return true;

			} catch (Exception e) {
				try {
					conn.rollback();       // 하나라도 실패하면 전부 취소
				} catch (Exception ignore) {
					// 롤백 실패는 원래 오류를 보는 게 더 중요해서 무시
				}
				throw e;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	/** 시퀀스 다음 번호 (시퀀스 이름은 이 클래스 안의 고정 문자열만 넘긴다) */
	private long nextVal(Connection conn, String sequenceName) throws SQLException {
		try (PreparedStatement pstmt = conn.prepareStatement("SELECT " + sequenceName + ".NEXTVAL FROM DUAL");
				ResultSet rs = pstmt.executeQuery()) {
			rs.next();
			return rs.getLong(1);
		}
	}

	/** ResultSet 한 줄 -> PostDTO. detail 이 true 면 내용/수정일까지 채운다 */
	private PostDTO map(ResultSet rs, boolean detail) throws SQLException {
		PostDTO dto = new PostDTO();
		dto.setPostId(rs.getLong("POST_ID"));
		dto.setBoardType(PostDAO.TYPE_QNA);
		dto.setTitle(rs.getString("TITLE"));

		long writerId = rs.getLong("WRITER_ID");
		if (!rs.wasNull()) {
			dto.setWriterId(writerId);
		}
		dto.setWriterName(rs.getString("WRITER_NAME"));
		dto.setViewCount(rs.getInt("VIEW_COUNT"));
		dto.setAnswered("Y".equals(rs.getString("ANSWER_YN")));
		dto.setCreatedAt(rs.getString("CREATED_AT"));

		if (detail) {
			dto.setContent(rs.getString("CONTENT"));
			dto.setUpdatedAt(rs.getString("UPDATED_AT"));
		}
		return dto;
	}
}