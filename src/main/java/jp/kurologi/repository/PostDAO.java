package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.PostDTO;
import util.DBmanager;

/**
 * COMMUNITY_POST 테이블 전용 DAO (공지사항 + 1:1게시판 공용, BOARD_TYPE 으로 구분)
 *
 *   공지사항   : writerId 를 null 로 넘기면 모든 글, 작성자는 NULL(관리자)
 *   1:1게시판  : writerId 에 로그인한 회원 번호를 넘겨서 "내 글"만 조회/수정/삭제
 *
 * 페이징은 Oracle 버전에 상관없이 되는 ROWNUM 방식 (startRow ~ endRow 번째 줄).
 */
public class PostDAO {

	public static final String TYPE_NOTICE = "NOTICE";
	public static final String TYPE_QNA = "QNA";

	/** 목록에 필요한 컬럼 (내용 CONTENT 는 뺀다). IS_NEW : 3일 안에 등록한 글이면 Y */
	private static final String LIST_COLUMNS =
			"p.POST_ID, p.BOARD_TYPE, p.TITLE, p.WRITER_ID, m.NAME AS WRITER_NAME, "
			+ "p.VIEW_COUNT, p.LIKE_COUNT, p.ANSWER_YN, "
			+ "TO_CHAR(p.CREATED_AT, 'YYYY-MM-DD') AS CREATED_AT, "
			+ "CASE WHEN p.CREATED_AT >= SYSDATE - 3 THEN 'Y' ELSE 'N' END AS IS_NEW";

	/**
	 * WHERE 절을 만들면서 ? 에 넣을 값을 params 에 차례로 담는다.
	 * searchType : "title"(제목) / "content"(내용) / 그 외(제목+내용). keyword 가 비어 있으면 검색 안 함.
	 * writerId   : null 이면 작성자 조건 없음
	 */
	private String where(String boardType, String searchType, String keyword, Long writerId, List<Object> params) {
		StringBuilder sb = new StringBuilder(" WHERE p.BOARD_TYPE = ?");
		params.add(boardType);

		if (writerId != null) {
			sb.append(" AND p.WRITER_ID = ?");
			params.add(writerId);
		}

		if (keyword != null && !keyword.trim().isEmpty()) {
			String like = DaoUtil.likePattern(keyword.trim());
			if ("title".equals(searchType)) {
				sb.append(" AND p.TITLE LIKE ? ESCAPE '\\'");
				params.add(like);
			} else if ("content".equals(searchType)) {
				sb.append(" AND p.CONTENT LIKE ? ESCAPE '\\'");
				params.add(like);
			} else {
				sb.append(" AND (p.TITLE LIKE ? ESCAPE '\\' OR p.CONTENT LIKE ? ESCAPE '\\')");
				params.add(like);
				params.add(like);
			}
		}
		return sb.toString();
	}

	/** 조건에 맞는 글 개수 (페이지 수 계산용). 실패하면 0 */
	public int selectCount(String boardType, String searchType, String keyword, Long writerId) {

		List<Object> params = new ArrayList<>();
		String sql = "SELECT COUNT(*) FROM COMMUNITY_POST p" + where(boardType, searchType, keyword, writerId, params);

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

	/** 목록 한 페이지 (최신 글이 위). startRow ~ endRow 는 1부터 시작하는 줄 번호 */
	public List<PostDTO> selectList(String boardType, String searchType, String keyword, Long writerId,
			int startRow, int endRow) {

		List<Object> params = new ArrayList<>();
		String sql = "SELECT * FROM ("
				+ " SELECT ROWNUM RN, T.* FROM ("
				+ "  SELECT " + LIST_COLUMNS
				+ "  FROM COMMUNITY_POST p LEFT JOIN KURO_MEMBER m ON p.WRITER_ID = m.ID"
				+ where(boardType, searchType, keyword, writerId, params)
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

	/** 글 1건 상세 (내용 포함). 없거나 종류(boardType)가 다르면 null */
	public PostDTO selectOne(long postId, String boardType) {

		String sql = "SELECT p.POST_ID, p.BOARD_TYPE, p.TITLE, p.CONTENT, p.WRITER_ID, m.NAME AS WRITER_NAME, "
				+ "p.VIEW_COUNT, p.LIKE_COUNT, p.ANSWER_YN, "
				+ "TO_CHAR(p.CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_AT, "
				+ "TO_CHAR(p.UPDATED_AT, 'YYYY-MM-DD HH24:MI') AS UPDATED_AT "
				+ "FROM COMMUNITY_POST p LEFT JOIN KURO_MEMBER m ON p.WRITER_ID = m.ID "
				+ "WHERE p.POST_ID = ? AND p.BOARD_TYPE = ?";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, postId);
			pstmt.setString(2, boardType);
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

	/** 조회수 1 증가. 성공하면 1 */
	public int increaseViewCount(long postId) {

		String sql = "UPDATE COMMUNITY_POST SET VIEW_COUNT = VIEW_COUNT + 1 WHERE POST_ID = ?";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, postId);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 다음 글 번호(SEQ_COMMUNITY_POST). 실패하면 -1 */
	public long nextId() {

		String sql = "SELECT SEQ_COMMUNITY_POST.NEXTVAL FROM DUAL";

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
	 * 글 등록. 성공하면 1, 실패하면 0.
	 * postId 는 nextId() 로 받은 값을 dto 에 넣어서 넘긴다. 조회수/좋아요/등록일/답변여부는 테이블 DEFAULT 에 맡긴다.
	 * writerId 가 null 이면 관리자 글로 저장된다.
	 */
	public int insert(PostDTO dto) {

		String sql = "INSERT INTO COMMUNITY_POST (POST_ID, BOARD_TYPE, TITLE, CONTENT, WRITER_ID) VALUES (?, ?, ?, ?, ?)";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, dto.getPostId());
			pstmt.setString(2, dto.getBoardType());
			pstmt.setString(3, dto.getTitle());
			pstmt.setString(4, dto.getContent());
			if (dto.getWriterId() == null) {
				pstmt.setNull(5, Types.NUMERIC);
			} else {
				pstmt.setLong(5, dto.getWriterId());
			}
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/**
	 * 본인 글 수정. 성공하면 1, 조건에 맞는 글이 없으면 0.
	 * 작성자 본인(WRITER_ID)이고 아직 답변 전(ANSWER_YN = 'N')인 글만 고쳐진다.
	 */
	public int update(PostDTO dto, long loginMemberId) {

		String sql = "UPDATE COMMUNITY_POST SET TITLE = ?, CONTENT = ?, UPDATED_AT = SYSDATE "
				+ "WHERE POST_ID = ? AND BOARD_TYPE = ? AND WRITER_ID = ? AND ANSWER_YN = 'N'";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, dto.getTitle());
			pstmt.setString(2, dto.getContent());
			pstmt.setLong(3, dto.getPostId());
			pstmt.setString(4, dto.getBoardType());
			pstmt.setLong(5, loginMemberId);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/**
	 * 본인 글 삭제. 성공하면 1, 조건에 맞는 글이 없으면 0.
	 * 작성자 본인이고 아직 답변 전인 글만 지워진다 (딸린 댓글/답변은 FK 규칙에 따라 같이 지워진다).
	 */
	public int delete(long postId, String boardType, long loginMemberId) {

		String sql = "DELETE FROM COMMUNITY_POST "
				+ "WHERE POST_ID = ? AND BOARD_TYPE = ? AND WRITER_ID = ? AND ANSWER_YN = 'N'";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, postId);
			pstmt.setString(2, boardType);
			pstmt.setLong(3, loginMemberId);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** ResultSet 한 줄 -> PostDTO. detail 이 true 면 내용/수정일까지, false 면 목록용(N 배지)까지 채운다 */
	private PostDTO map(ResultSet rs, boolean detail) throws SQLException {
		PostDTO dto = new PostDTO();
		dto.setPostId(rs.getLong("POST_ID"));
		dto.setBoardType(rs.getString("BOARD_TYPE"));
		dto.setTitle(rs.getString("TITLE"));

		long writerId = rs.getLong("WRITER_ID");
		if (!rs.wasNull()) {          // NULL 이면 관리자 글이라 writerId 를 비워 둔다
			dto.setWriterId(writerId);
		}
		dto.setWriterName(rs.getString("WRITER_NAME"));
		dto.setViewCount(rs.getInt("VIEW_COUNT"));
		dto.setLikeCount(rs.getInt("LIKE_COUNT"));
		dto.setAnswered("Y".equals(rs.getString("ANSWER_YN")));
		dto.setCreatedAt(rs.getString("CREATED_AT"));

		if (detail) {
			dto.setContent(rs.getString("CONTENT"));
			dto.setUpdatedAt(rs.getString("UPDATED_AT"));
		} else {
			dto.setNewPost("Y".equals(rs.getString("IS_NEW")));
		}
		return dto;
	}
}