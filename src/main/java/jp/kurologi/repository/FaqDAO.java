package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.FaqDTO;
import util.DBmanager;

/** COMMUNITY_FAQ 테이블 전용 DAO (자주묻는 질문). 화면 노출(VISIBLE_YN = 'Y')인 것만 다룬다 */
public class FaqDAO {

	/**
	 * 노출 중인 FAQ 전체 (SORT_ORDER 가 작은 것부터, 같으면 번호순).
	 * 분류(CATEGORY)별로 묶는 일은 Service 가 한다. 분류가 보이는 순서 = 그 분류에서 가장 작은 SORT_ORDER 순서.
	 */
	public List<FaqDTO> selectAll() {

		String sql = "SELECT FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER, VISIBLE_YN, "
				+ "TO_CHAR(CREATED_AT, 'YYYY-MM-DD') AS CREATED_AT "
				+ "FROM COMMUNITY_FAQ WHERE VISIBLE_YN = 'Y' ORDER BY SORT_ORDER, FAQ_ID";

		List<FaqDTO> list = new ArrayList<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql);
				ResultSet rs = pstmt.executeQuery()) {
			while (rs.next()) {
				FaqDTO dto = new FaqDTO();
				dto.setFaqId(rs.getLong("FAQ_ID"));
				dto.setCategory(rs.getString("CATEGORY"));
				dto.setQuestion(rs.getString("QUESTION"));
				dto.setAnswer(rs.getString("ANSWER"));
				dto.setSortOrder(rs.getInt("SORT_ORDER"));
				dto.setVisible("Y".equals(rs.getString("VISIBLE_YN")));
				dto.setCreatedAt(rs.getString("CREATED_AT"));
				list.add(dto);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
}