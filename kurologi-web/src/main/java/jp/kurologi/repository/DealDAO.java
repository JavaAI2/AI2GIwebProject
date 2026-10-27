package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.DealDTO;
import util.DBmanager;

/** COMMUNITY_DEAL 테이블 전용 DAO (특가제품안내). 화면 노출(VISIBLE_YN = 'Y')인 것만 다룬다 */
public class DealDAO {

	/** 노출 중인 특가제품 개수 (페이지 수 계산용). 실패하면 0 */
	public int selectCount() {

		String sql = "SELECT COUNT(*) FROM COMMUNITY_DEAL WHERE VISIBLE_YN = 'Y'";

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

	/** 한 페이지 (최신 등록이 위). startRow ~ endRow 는 1부터 시작하는 줄 번호 */
	public List<DealDTO> selectList(int startRow, int endRow) {

		String sql = "SELECT * FROM ("
				+ " SELECT ROWNUM RN, T.* FROM ("
				+ "  SELECT DEAL_ID, NAME, PRICE_JPY, MIN_QTY, IMAGE_PATH, VISIBLE_YN, "
				+ "         TO_CHAR(CREATED_AT, 'YYYY-MM-DD') AS CREATED_AT "
				+ "  FROM COMMUNITY_DEAL WHERE VISIBLE_YN = 'Y' ORDER BY DEAL_ID DESC"
				+ " ) T WHERE ROWNUM <= ?"
				+ ") WHERE RN >= ?";

		List<DealDTO> list = new ArrayList<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, endRow);
			pstmt.setInt(2, startRow);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					DealDTO dto = new DealDTO();
					dto.setDealId(rs.getLong("DEAL_ID"));
					dto.setName(rs.getString("NAME"));
					dto.setPriceJpy(rs.getLong("PRICE_JPY"));
					dto.setMinQty(rs.getInt("MIN_QTY"));
					dto.setImagePath(rs.getString("IMAGE_PATH"));
					dto.setVisible("Y".equals(rs.getString("VISIBLE_YN")));
					dto.setCreatedAt(rs.getString("CREATED_AT"));
					list.add(dto);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
}