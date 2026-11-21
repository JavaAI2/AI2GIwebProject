package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.FaqDTO;
import util.DBmanager;

/**
 * 관리자용 FAQ DAO — 숨김(VISIBLE_YN = 'N') 항목까지 모두 다룬다.
 * (사용자 화면용 FaqDAO 는 노출 중인 것만 조회하므로 그대로 두고, 관리 기능은 이 클래스에 따로 둔다)
 */
public class AdminFaqDAO {

	/**
	 * WHERE 절 + ? 에 넣을 값 만들기
	 * searchType : "category"(분류) / "question"(질문) / 그 외 분류+질문
	 */
	private String where(String searchType, String keyword, List<Object> params) {
		StringBuilder sb = new StringBuilder(" WHERE 1 = 1");

		if (keyword != null && !keyword.trim().isEmpty()) {
			String like = DaoUtil.likePattern(keyword.trim());
			if ("category".equals(searchType)) {
				sb.append(" AND CATEGORY LIKE ? ESCAPE '\\'");
				params.add(like);
			} else if ("question".equals(searchType)) {
				sb.append(" AND QUESTION LIKE ? ESCAPE '\\'");
				params.add(like);
			} else {
				sb.append(" AND (CATEGORY LIKE ? ESCAPE '\\' OR QUESTION LIKE ? ESCAPE '\\')");
				params.add(like);
				params.add(like);
			}
		}
		return sb.toString();
	}

	/** 조건에 맞는 FAQ 개수. 실패하면 0 */
	public int selectCount(String searchType, String keyword) {

		List<Object> params = new ArrayList<>();
		String sql = "SELECT COUNT(*) FROM COMMUNITY_FAQ" + where(searchType, keyword, params);

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

	/** 목록 한 페이지 (사이트 화면과 같은 순서: 표시 순서 -> 번호). 답변(ANSWER)은 목록에 필요 없어서 비워 둔다 */
	public List<FaqDTO> selectList(String searchType, String keyword, int startRow, int endRow) {

		List<Object> params = new ArrayList<>();
		String sql = "SELECT * FROM ("
				+ " SELECT ROWNUM RN, T.* FROM ("
				+ "  SELECT FAQ_ID, CATEGORY, QUESTION, SORT_ORDER, VISIBLE_YN, "
				+ "         TO_CHAR(CREATED_AT, 'YYYY-MM-DD') AS CREATED_AT"
				+ "  FROM COMMUNITY_FAQ"
				+ where(searchType, keyword, params)
				+ "  ORDER BY SORT_ORDER, FAQ_ID"
				+ " ) T WHERE ROWNUM <= ?"
				+ ") WHERE RN >= ?";
		params.add(endRow);
		params.add(startRow);

		List<FaqDTO> list = new ArrayList<>();
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

	/** FAQ 1건 (답변 포함). 없으면 null */
	public FaqDTO selectOne(long faqId) {

		String sql = "SELECT FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER, VISIBLE_YN, "
				+ "TO_CHAR(CREATED_AT, 'YYYY-MM-DD') AS CREATED_AT FROM COMMUNITY_FAQ WHERE FAQ_ID = ?";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, faqId);
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

	/** 지금 등록된 분류 이름들 (입력창 자동완성용, 가나다순) */
	public List<String> selectCategories() {

		String sql = "SELECT DISTINCT CATEGORY FROM COMMUNITY_FAQ ORDER BY CATEGORY";

		List<String> list = new ArrayList<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql);
				ResultSet rs = pstmt.executeQuery()) {
			while (rs.next()) {
				list.add(rs.getString(1));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 현재 가장 큰 표시 순서 (없으면 0). 새 FAQ 의 기본 순서를 "맨 뒤"로 잡을 때 쓴다 */
	public int maxSortOrder() {

		String sql = "SELECT NVL(MAX(SORT_ORDER), 0) FROM COMMUNITY_FAQ";

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

	/** 다음 FAQ 번호(SEQ_COMMUNITY_FAQ). 실패하면 -1 */
	public long nextId() {

		String sql = "SELECT SEQ_COMMUNITY_FAQ.NEXTVAL FROM DUAL";

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

	/** FAQ 등록. 성공하면 1, 실패하면 0 (faqId 는 nextId() 로 받은 값을 dto 에 넣어서 넘긴다) */
	public int insert(FaqDTO dto) {

		String sql = "INSERT INTO COMMUNITY_FAQ (FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER, VISIBLE_YN) "
				+ "VALUES (?, ?, ?, ?, ?, ?)";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, dto.getFaqId());
			pstmt.setString(2, dto.getCategory());
			pstmt.setString(3, dto.getQuestion());
			pstmt.setString(4, dto.getAnswer());
			pstmt.setInt(5, dto.getSortOrder());
			pstmt.setString(6, dto.isVisible() ? "Y" : "N");
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** FAQ 수정. 성공하면 1, 없는 FAQ 면 0 */
	public int update(FaqDTO dto) {

		String sql = "UPDATE COMMUNITY_FAQ SET CATEGORY = ?, QUESTION = ?, ANSWER = ?, SORT_ORDER = ?, VISIBLE_YN = ? "
				+ "WHERE FAQ_ID = ?";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, dto.getCategory());
			pstmt.setString(2, dto.getQuestion());
			pstmt.setString(3, dto.getAnswer());
			pstmt.setInt(4, dto.getSortOrder());
			pstmt.setString(5, dto.isVisible() ? "Y" : "N");
			pstmt.setLong(6, dto.getFaqId());
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 노출 / 숨김만 바꾼다. 성공하면 1 */
	public int setVisible(long faqId, boolean visible) {

		String sql = "UPDATE COMMUNITY_FAQ SET VISIBLE_YN = ? WHERE FAQ_ID = ?";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, visible ? "Y" : "N");
			pstmt.setLong(2, faqId);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** FAQ 삭제. 성공하면 1, 없는 FAQ 면 0 */
	public int delete(long faqId) {

		String sql = "DELETE FROM COMMUNITY_FAQ WHERE FAQ_ID = ?";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, faqId);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** ResultSet 한 줄 -> FaqDTO. detail 이 true 면 답변까지 채운다 */
	private FaqDTO map(ResultSet rs, boolean detail) throws SQLException {
		FaqDTO dto = new FaqDTO();
		dto.setFaqId(rs.getLong("FAQ_ID"));
		dto.setCategory(rs.getString("CATEGORY"));
		dto.setQuestion(rs.getString("QUESTION"));
		dto.setSortOrder(rs.getInt("SORT_ORDER"));
		dto.setVisible("Y".equals(rs.getString("VISIBLE_YN")));
		dto.setCreatedAt(rs.getString("CREATED_AT"));
		if (detail) {
			dto.setAnswer(rs.getString("ANSWER"));
		}
		return dto;
	}
}