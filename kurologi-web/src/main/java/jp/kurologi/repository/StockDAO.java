package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.StockItemDTO;
import jp.kurologi.model.StockOrderDTO;
import util.DBmanager;

/** STOCK_ITEM(재고) + STOCK_ORDER(재고구매신청) 전용 DAO */
public class StockDAO {

	/** 재고 상품 등록. 재고번호(S000001)는 시퀀스 값으로 SQL 안에서 바로 만든다. */
	public boolean insertItem(StockItemDTO dto) {

		String sql = "INSERT INTO STOCK_ITEM (STOCK_ID, MEMBER_ID, STOCK_NO, ITEM_NAME, OPTION_NAME, QTY, PRICE) "
				+ "VALUES (STOCK_ITEM_SEQ.NEXTVAL, ?, 'S' || LPAD(STOCK_ITEM_SEQ.CURRVAL, 6, '0'), ?, ?, ?, ?)";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, dto.getMemberId());
			pstmt.setString(2, dto.getItemName());
			pstmt.setString(3, dto.getOptionName());
			pstmt.setInt(4, dto.getQty());
			pstmt.setLong(5, dto.getPrice());
			return pstmt.executeUpdate() == 1;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	/** 내 재고 목록 (최신순) */
	public List<StockItemDTO> listItems(long memberId) {

		String sql = "SELECT STOCK_ID, STOCK_NO, ITEM_NAME, OPTION_NAME, QTY, PRICE, "
				+ "TO_CHAR(CREATED_AT, 'YYYY-MM-DD') AS CREATED_TXT "
				+ "FROM STOCK_ITEM WHERE MEMBER_ID = ? ORDER BY STOCK_ID DESC";

		List<StockItemDTO> list = new ArrayList<>();

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, memberId);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					StockItemDTO dto = new StockItemDTO();
					dto.setStockId(rs.getLong("STOCK_ID"));
					dto.setMemberId(memberId);
					dto.setStockNo(rs.getString("STOCK_NO"));
					dto.setItemName(rs.getString("ITEM_NAME"));
					dto.setOptionName(rs.getString("OPTION_NAME"));
					dto.setQty(rs.getInt("QTY"));
					dto.setPrice(rs.getLong("PRICE"));
					dto.setCreatedAt(rs.getString("CREATED_TXT"));
					list.add(dto);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 내 재고신청 내역 (최근 10건). 상품명은 STOCK_ITEM 과 ANSI 조인으로 가져온다. */
	public List<StockOrderDTO> listOrders(long memberId) {

		String sql = "SELECT * FROM ("
				+ " SELECT o.ORDER_NO, i.ITEM_NAME, o.QTY, o.TOTAL_PRICE, o.RECV_NAME, "
				+ "  TO_CHAR(o.CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_TXT "
				+ " FROM STOCK_ORDER o JOIN STOCK_ITEM i ON i.STOCK_ID = o.STOCK_ID "
				+ " WHERE o.MEMBER_ID = ? ORDER BY o.SORDER_ID DESC"
				+ ") WHERE ROWNUM <= 10";

		List<StockOrderDTO> list = new ArrayList<>();

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, memberId);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					StockOrderDTO dto = new StockOrderDTO();
					dto.setOrderNo(rs.getString("ORDER_NO"));
					dto.setItemName(rs.getString("ITEM_NAME"));
					dto.setQty(rs.getInt("QTY"));
					dto.setTotalPrice(rs.getLong("TOTAL_PRICE"));
					dto.setRecvName(rs.getString("RECV_NAME"));
					dto.setCreatedAt(rs.getString("CREATED_TXT"));
					list.add(dto);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/**
	 * 재고구매신청 저장. 성공하면 null, 실패하면 화면에 보여 줄 이유(문자열)를 돌려준다.
	 *
	 * 하는 일(한 트랜잭션) : 재고 행 잠금 -> 수량 확인 -> 재고 차감 -> 신청 내역 저장
	 * 두 사람이 동시에 신청해도 재고가 모자란 채로 두 건이 다 성공하지 않도록
	 * SELECT ... FOR UPDATE 로 그 재고 행을 잠근 뒤 수량을 확인한다.
	 */
	public String apply(StockOrderDTO order) {

		String lockSql = "SELECT QTY, PRICE FROM STOCK_ITEM WHERE STOCK_ID = ? AND MEMBER_ID = ? FOR UPDATE";
		String updateSql = "UPDATE STOCK_ITEM SET QTY = QTY - ? WHERE STOCK_ID = ?";
		String insertSql = "INSERT INTO STOCK_ORDER (SORDER_ID, ORDER_NO, STOCK_ID, MEMBER_ID, RECV_NAME, MOBILE, "
				+ "POSTCODE, ADDR1, ADDR2, DELIVER_NOTE, QTY, TOTAL_PRICE) "
				+ "VALUES (STOCK_ORDER_SEQ.NEXTVAL, "
				+ "'SO' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || LPAD(STOCK_ORDER_SEQ.CURRVAL, 5, '0'), "
				+ "?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

		Connection conn = null;

		try {
			conn = DBmanager.getInstance();
			conn.setAutoCommit(false);

			long price;
			try (PreparedStatement pstmt = conn.prepareStatement(lockSql)) {
				pstmt.setLong(1, order.getStockId());
				pstmt.setLong(2, order.getMemberId());
				try (ResultSet rs = pstmt.executeQuery()) {
					if (!rs.next()) {
						conn.rollback();
						return "선택한 재고를 찾을 수 없습니다.";
					}
					if (rs.getInt("QTY") < order.getQty()) {
						conn.rollback();
						return "재고수량이 부족합니다. (현재 " + rs.getInt("QTY") + "개)";
					}
					price = rs.getLong("PRICE");
				}
			}

			try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
				pstmt.setInt(1, order.getQty());
				pstmt.setLong(2, order.getStockId());
				pstmt.executeUpdate();
			}

			try (PreparedStatement pstmt = conn.prepareStatement(insertSql)) {
				pstmt.setLong(1, order.getStockId());
				pstmt.setLong(2, order.getMemberId());
				pstmt.setString(3, order.getRecvName());
				pstmt.setString(4, order.getMobile());
				pstmt.setString(5, order.getPostcode());
				pstmt.setString(6, order.getAddr1());
				pstmt.setString(7, order.getAddr2());
				pstmt.setString(8, order.getDeliverNote());
				pstmt.setInt(9, order.getQty());
				pstmt.setLong(10, price * order.getQty());   // 금액은 DB 의 판매가로 서버에서 계산 (화면 값은 믿지 않는다)
				pstmt.executeUpdate();
			}

			conn.commit();
			return null;

		} catch (Exception e) {
			e.printStackTrace();
			try {
				if (conn != null) conn.rollback();
			} catch (Exception e2) {
				e2.printStackTrace();
			}
			return "신청 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.";
		} finally {
			try {
				if (conn != null) conn.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}
