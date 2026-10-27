package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.model.BuyOrderItemDTO;
import util.DBmanager;

/** BUY_ORDER(주문서) + BUY_ORDER_ITEM(상품) 전용 DAO */
public class BuyOrderDAO {

	// ------------------------------------------------------------------ 번호 만들기

	/** 다음 주문 번호(BUY_ORDER_SEQ). 실패하면 -1 */
	public long nextOrderId() {

		String sql = "SELECT BUY_ORDER_SEQ.NEXTVAL FROM DUAL";

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

	// ------------------------------------------------------------------ 저장 · 수정 · 삭제

	/**
	 * 주문서 1건 + 상품 여러 개를 저장한다. 성공하면 true.
	 * 주문과 상품은 "둘 다 저장되거나, 둘 다 저장 안 되거나" 해야 하므로
	 * 한 Connection 으로 묶어서(트랜잭션) 처리하고, 하나라도 실패하면 rollback 한다.
	 */
	public boolean insert(BuyOrderDTO order) {

		String orderSql = "INSERT INTO BUY_ORDER "
				+ "(ORDER_ID, ORDER_NO, MEMBER_ID, STATUS, CENTER, RECV_NAME_KO, RECV_NAME_EN, POSTCODE, "
				+ "ADDR1, ADDR2, BIZ_NO, MOBILE, DELIVER_NOTE, TOTAL_QTY, TOTAL_YEN, ADDON_OPTIONS, "
				+ "LOGISTICS_NOTE, AUTO_PAY) "
				+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

		Connection conn = null;

		try {
			conn = DBmanager.getInstance();
			conn.setAutoCommit(false);   // 직접 commit / rollback 하겠다

			try (PreparedStatement pstmt = conn.prepareStatement(orderSql)) {
				pstmt.setLong(1, order.getOrderId());
				pstmt.setString(2, order.getOrderNo());
				pstmt.setLong(3, order.getMemberId());
				pstmt.setString(4, order.getStatus());
				pstmt.setString(5, order.getCenter());
				pstmt.setString(6, order.getRecvNameKo());
				pstmt.setString(7, order.getRecvNameEn());
				pstmt.setString(8, order.getPostcode());
				pstmt.setString(9, order.getAddr1());
				pstmt.setString(10, order.getAddr2());
				pstmt.setString(11, order.getBizNo());
				pstmt.setString(12, order.getMobile());
				pstmt.setString(13, order.getDeliverNote());
				pstmt.setInt(14, order.getTotalQty());
				pstmt.setBigDecimal(15, order.getTotalYen());
				pstmt.setString(16, order.getAddonOptions());
				pstmt.setString(17, order.getLogisticsNote());
				pstmt.setString(18, order.isAutoPay() ? "Y" : "N");
				pstmt.executeUpdate();
			}

			insertItems(conn, order);

			conn.commit();   // 둘 다 성공했을 때만 확정
			return true;

		} catch (Exception e) {
			e.printStackTrace();
			rollbackQuietly(conn);
			return false;
		} finally {
			closeQuietly(conn);
		}
	}

	/**
	 * 접수대기(WAIT) 주문서를 수정한다. 성공하면 true.
	 * 주문 정보를 UPDATE 하고, 상품은 "전부 지우고 다시 넣는" 방식으로 바꾼다.
	 * 내 주문이 아니거나 이미 접수신청(SUBMIT)된 주문이면 UPDATE 가 0건이라 false 를 돌려준다.
	 */
	public boolean update(BuyOrderDTO order) {

		String sql = "UPDATE BUY_ORDER SET STATUS = ?, RECV_NAME_KO = ?, RECV_NAME_EN = ?, POSTCODE = ?, "
				+ "ADDR1 = ?, ADDR2 = ?, BIZ_NO = ?, MOBILE = ?, DELIVER_NOTE = ?, TOTAL_QTY = ?, TOTAL_YEN = ?, "
				+ "ADDON_OPTIONS = ?, LOGISTICS_NOTE = ?, AUTO_PAY = ? "
				+ "WHERE ORDER_ID = ? AND MEMBER_ID = ? AND STATUS = 'WAIT'";

		Connection conn = null;

		try {
			conn = DBmanager.getInstance();
			conn.setAutoCommit(false);

			try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
				pstmt.setString(1, order.getStatus());
				pstmt.setString(2, order.getRecvNameKo());
				pstmt.setString(3, order.getRecvNameEn());
				pstmt.setString(4, order.getPostcode());
				pstmt.setString(5, order.getAddr1());
				pstmt.setString(6, order.getAddr2());
				pstmt.setString(7, order.getBizNo());
				pstmt.setString(8, order.getMobile());
				pstmt.setString(9, order.getDeliverNote());
				pstmt.setInt(10, order.getTotalQty());
				pstmt.setBigDecimal(11, order.getTotalYen());
				pstmt.setString(12, order.getAddonOptions());
				pstmt.setString(13, order.getLogisticsNote());
				pstmt.setString(14, order.isAutoPay() ? "Y" : "N");
				pstmt.setLong(15, order.getOrderId());
				pstmt.setLong(16, order.getMemberId());
				if (pstmt.executeUpdate() != 1) {
					conn.rollback();
					return false;
				}
			}

			try (PreparedStatement pstmt = conn.prepareStatement("DELETE FROM BUY_ORDER_ITEM WHERE ORDER_ID = ?")) {
				pstmt.setLong(1, order.getOrderId());
				pstmt.executeUpdate();
			}

			insertItems(conn, order);

			conn.commit();
			return true;

		} catch (Exception e) {
			e.printStackTrace();
			rollbackQuietly(conn);
			return false;
		} finally {
			closeQuietly(conn);
		}
	}

	/** 접수대기(WAIT) 주문서를 삭제한다. 상품은 ON DELETE CASCADE 로 같이 지워진다. */
	public boolean delete(long orderId, long memberId) {

		String sql = "DELETE FROM BUY_ORDER WHERE ORDER_ID = ? AND MEMBER_ID = ? AND STATUS = 'WAIT'";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, orderId);
			pstmt.setLong(2, memberId);
			return pstmt.executeUpdate() == 1;   // autoCommit 이라 바로 확정된다
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	// ------------------------------------------------------------------ 조회

	/** 내 주문 개수 */
	public int countByMember(long memberId) {

		String sql = "SELECT COUNT(*) FROM BUY_ORDER WHERE MEMBER_ID = ?";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, memberId);
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

	/**
	 * 내 주문 목록 (최신순, 한 페이지에 size 건).
	 * 오라클은 LIMIT 이 없어서 ROWNUM 을 바깥 SELECT 로 한 번 더 감싸는 방식으로 페이지를 나눈다.
	 */
	public List<BuyOrderDTO> listByMember(long memberId, int page, int size) {

		String sql = "SELECT * FROM ("
				+ " SELECT a.*, ROWNUM RN FROM ("
				+ "  SELECT o.ORDER_ID, o.ORDER_NO, o.STATUS, o.RECV_NAME_KO, o.TOTAL_QTY, o.TOTAL_YEN, "
				+ "   TO_CHAR(o.CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_TXT, "
				+ "   (SELECT COUNT(*) FROM BUY_ORDER_ITEM i WHERE i.ORDER_ID = o.ORDER_ID) AS ITEM_CNT, "
				+ "   (SELECT i.ITEM_NAME_EN FROM BUY_ORDER_ITEM i WHERE i.ORDER_ID = o.ORDER_ID AND i.ITEM_NO = 1) AS FIRST_ITEM "
				+ "  FROM BUY_ORDER o WHERE o.MEMBER_ID = ? ORDER BY o.ORDER_ID DESC"
				+ " ) a WHERE ROWNUM <= ?"
				+ ") WHERE RN > ?";

		List<BuyOrderDTO> list = new ArrayList<>();

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, memberId);
			pstmt.setInt(2, page * size);
			pstmt.setInt(3, (page - 1) * size);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					BuyOrderDTO dto = new BuyOrderDTO();
					dto.setOrderId(rs.getLong("ORDER_ID"));
					dto.setOrderNo(rs.getString("ORDER_NO"));
					dto.setStatus(rs.getString("STATUS"));
					dto.setRecvNameKo(rs.getString("RECV_NAME_KO"));
					dto.setTotalQty(rs.getInt("TOTAL_QTY"));
					dto.setTotalYen(rs.getBigDecimal("TOTAL_YEN"));
					dto.setCreatedAt(rs.getString("CREATED_TXT"));
					dto.setItemCount(rs.getInt("ITEM_CNT"));
					dto.setFirstItemName(rs.getString("FIRST_ITEM"));
					list.add(dto);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 주문 1건 + 상품 목록. 없으면 null (내 주문인지는 호출하는 쪽에서 memberId 로 확인한다) */
	public BuyOrderDTO findById(long orderId) {

		String orderSql = "SELECT ORDER_ID, ORDER_NO, MEMBER_ID, STATUS, CENTER, RECV_NAME_KO, RECV_NAME_EN, "
				+ "POSTCODE, ADDR1, ADDR2, BIZ_NO, MOBILE, DELIVER_NOTE, TOTAL_QTY, TOTAL_YEN, ADDON_OPTIONS, "
				+ "LOGISTICS_NOTE, AUTO_PAY, TO_CHAR(CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_TXT "
				+ "FROM BUY_ORDER WHERE ORDER_ID = ?";

		String itemSql = "SELECT ITEM_ID, ITEM_NO, SHOP_SITE, BRAND, SHOP_ORDER_NO, TRACKING_NO, ITEM_NAME_EN, "
				+ "NAME_EN_DIRECT, QTY, UNIT_PRICE, COLOR, ITEM_SIZE, PRODUCT_URL, IMAGE_URL, MARKET_NAME, "
				+ "MARKET_ORDER_NO, MARKET_PRICE, HS_CODE, MARKET_PAY "
				+ "FROM BUY_ORDER_ITEM WHERE ORDER_ID = ? ORDER BY ITEM_NO";

		try (Connection conn = DBmanager.getInstance()) {

			BuyOrderDTO order = null;

			try (PreparedStatement pstmt = conn.prepareStatement(orderSql)) {
				pstmt.setLong(1, orderId);
				try (ResultSet rs = pstmt.executeQuery()) {
					if (rs.next()) {
						order = new BuyOrderDTO();
						order.setOrderId(rs.getLong("ORDER_ID"));
						order.setOrderNo(rs.getString("ORDER_NO"));
						order.setMemberId(rs.getLong("MEMBER_ID"));
						order.setStatus(rs.getString("STATUS"));
						order.setCenter(rs.getString("CENTER"));
						order.setRecvNameKo(rs.getString("RECV_NAME_KO"));
						order.setRecvNameEn(rs.getString("RECV_NAME_EN"));
						order.setPostcode(rs.getString("POSTCODE"));
						order.setAddr1(rs.getString("ADDR1"));
						order.setAddr2(rs.getString("ADDR2"));
						order.setBizNo(rs.getString("BIZ_NO"));
						order.setMobile(rs.getString("MOBILE"));
						order.setDeliverNote(rs.getString("DELIVER_NOTE"));
						order.setTotalQty(rs.getInt("TOTAL_QTY"));
						order.setTotalYen(rs.getBigDecimal("TOTAL_YEN"));
						order.setAddonOptions(rs.getString("ADDON_OPTIONS"));
						order.setLogisticsNote(rs.getString("LOGISTICS_NOTE"));
						order.setAutoPay("Y".equals(rs.getString("AUTO_PAY")));
						order.setCreatedAt(rs.getString("CREATED_TXT"));
					}
				}
			}
			if (order == null) {
				return null;
			}

			try (PreparedStatement pstmt = conn.prepareStatement(itemSql)) {
				pstmt.setLong(1, orderId);
				try (ResultSet rs = pstmt.executeQuery()) {
					while (rs.next()) {
						BuyOrderItemDTO item = new BuyOrderItemDTO();
						item.setItemId(rs.getLong("ITEM_ID"));
						item.setOrderId(orderId);
						item.setItemNo(rs.getInt("ITEM_NO"));
						item.setShopSite(rs.getString("SHOP_SITE"));
						item.setBrand(rs.getString("BRAND"));
						item.setShopOrderNo(rs.getString("SHOP_ORDER_NO"));
						item.setTrackingNo(rs.getString("TRACKING_NO"));
						item.setItemNameEn(rs.getString("ITEM_NAME_EN"));
						item.setNameEnDirect("Y".equals(rs.getString("NAME_EN_DIRECT")));
						item.setQty(rs.getInt("QTY"));
						item.setUnitPrice(rs.getBigDecimal("UNIT_PRICE"));
						item.setColor(rs.getString("COLOR"));
						item.setItemSize(rs.getString("ITEM_SIZE"));
						item.setProductUrl(rs.getString("PRODUCT_URL"));
						item.setImageUrl(rs.getString("IMAGE_URL"));
						item.setMarketName(rs.getString("MARKET_NAME"));
						item.setMarketOrderNo(rs.getString("MARKET_ORDER_NO"));
						item.setMarketPrice(rs.getLong("MARKET_PRICE"));
						item.setHsCode(rs.getString("HS_CODE"));
						item.setMarketPay(rs.getString("MARKET_PAY"));
						order.getItems().add(item);
					}
				}
			}
			return order;

		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	// ------------------------------------------------------------------ 공통 도우미

	/** 주문에 담긴 상품을 batch 로 한 번에 저장한다 (insert, update 가 같이 쓴다) */
	private void insertItems(Connection conn, BuyOrderDTO order) throws Exception {

		String itemSql = "INSERT INTO BUY_ORDER_ITEM "
				+ "(ITEM_ID, ORDER_ID, ITEM_NO, SHOP_SITE, BRAND, SHOP_ORDER_NO, TRACKING_NO, ITEM_NAME_EN, "
				+ "NAME_EN_DIRECT, QTY, UNIT_PRICE, COLOR, ITEM_SIZE, PRODUCT_URL, IMAGE_URL, MARKET_NAME, "
				+ "MARKET_ORDER_NO, MARKET_PRICE, HS_CODE, MARKET_PAY) "
				+ "VALUES (BUY_ORDER_ITEM_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

		try (PreparedStatement pstmt = conn.prepareStatement(itemSql)) {
			for (BuyOrderItemDTO item : order.getItems()) {
				pstmt.setLong(1, order.getOrderId());
				pstmt.setInt(2, item.getItemNo());
				pstmt.setString(3, item.getShopSite());
				pstmt.setString(4, item.getBrand());
				pstmt.setString(5, item.getShopOrderNo());
				pstmt.setString(6, item.getTrackingNo());
				pstmt.setString(7, item.getItemNameEn());
				pstmt.setString(8, item.isNameEnDirect() ? "Y" : "N");
				pstmt.setInt(9, item.getQty());
				pstmt.setBigDecimal(10, item.getUnitPrice());
				pstmt.setString(11, item.getColor());
				pstmt.setString(12, item.getItemSize());
				pstmt.setString(13, item.getProductUrl());
				pstmt.setString(14, item.getImageUrl());
				pstmt.setString(15, item.getMarketName());
				pstmt.setString(16, item.getMarketOrderNo());
				pstmt.setLong(17, item.getMarketPrice());
				pstmt.setString(18, item.getHsCode());
				pstmt.setString(19, item.getMarketPay());
				pstmt.addBatch();
			}
			pstmt.executeBatch();
		}
	}

	private void rollbackQuietly(Connection conn) {
		try {
			if (conn != null) conn.rollback();   // 하나라도 실패하면 모두 취소
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void closeQuietly(Connection conn) {
		try {
			if (conn != null) conn.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
