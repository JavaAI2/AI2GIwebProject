package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.Address;
import jp.kurologi.model.Page;

// 나의 주소록(KURO_ADDRESS 테이블) 전용 DAO
// 마이페이지 "주소관리"와 구매대행 접수창의 "주소록 불러오기"가 함께 쓴다.
// (먼저 sql/09_kuro_address.sql 을 실행해서 테이블과 시퀀스를 만들어 두어야 한다)
// 다른 회원의 주소를 건드리지 못하도록 모든 SQL 에 MEMBER_ID 조건을 함께 넣는다.

public class AddressDAO {

	private static final String COLS = "ID, MEMBER_ID, NAME, ZIPCODE, ADDRESS1, ADDRESS2, COUNTRY, PHONE, CUSTOMS_CODE";

	/**
	 * 주소 목록 검색 + 쪽 나누기 (최신 등록이 위로)
	 * @param field   "name"(받는 사람 이름) 또는 "address"(주소)
	 * @param keyword 검색어. 비어 있으면 전체
	 * @param page    쪽 번호(1부터)
	 * @param size    한 쪽에 보일 개수
	 */
	public Page<Address> search(long memberId, String field, String keyword, int page, int size) {

		int pageNo = Math.max(1, page);
		String q = keyword == null ? "" : keyword.trim();

		// 검색 조건. 검색어가 있을 때만 LIKE 를 붙인다 (% _ 는 글자 그대로 찾도록 \ 로 막는다)
		String where = " WHERE MEMBER_ID = ?";
		if (!q.isEmpty()) {
			where += "address".equals(field)
					? " AND (ZIPCODE || ' ' || ADDRESS1 || ' ' || ADDRESS2) LIKE ? ESCAPE '\\'"
					: " AND NAME LIKE ? ESCAPE '\\'";
		}
		String like = "%" + q.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";

		List<Address> items = new ArrayList<>();
		long total = 0;

		// 오라클은 LIMIT 이 없어서 ROWNUM 을 바깥 SELECT 로 한 번 더 감싸는 방식으로 쪽을 나눈다
		String listSql = "SELECT * FROM ("
				+ " SELECT a.*, ROWNUM RN FROM ("
				+ "  SELECT " + COLS + " FROM KURO_ADDRESS" + where + " ORDER BY ID DESC"
				+ " ) a WHERE ROWNUM <= ?"
				+ ") WHERE RN > ?";
		String countSql = "SELECT COUNT(*) FROM KURO_ADDRESS" + where;

		try (Connection conn = MemberDAO.conn()) {

			// 전체 개수 (쪽 번호 계산용)
			try (PreparedStatement pstmt = conn.prepareStatement(countSql)) {
				int i = 1;
				pstmt.setLong(i++, memberId);
				if (!q.isEmpty()) pstmt.setString(i++, like);
				try (ResultSet rs = pstmt.executeQuery()) {
					if (rs.next()) total = rs.getLong(1);
				}
			}

			// 이번 쪽 목록
			try (PreparedStatement pstmt = conn.prepareStatement(listSql)) {
				int i = 1;
				pstmt.setLong(i++, memberId);
				if (!q.isEmpty()) pstmt.setString(i++, like);
				pstmt.setInt(i++, pageNo * size);         // 여기까지
				pstmt.setInt(i++, (pageNo - 1) * size);   // 여기부터(이 번호보다 큰 것)
				try (ResultSet rs = pstmt.executeQuery()) {
					while (rs.next()) {
						items.add(toAddress(rs));
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new Page<>(items, pageNo, size, total);
	}

	/** 주소 1건 조회. 내 주소가 아니거나 없으면 null */
	public Address findById(long memberId, long id) {

		String sql = "SELECT " + COLS + " FROM KURO_ADDRESS WHERE ID = ? AND MEMBER_ID = ?";

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, id);
			pstmt.setLong(2, memberId);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return toAddress(rs);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/** 새 주소 추가. 성공하면 1 (새 번호는 ADDRESS_SEQ 로 받는다) */
	public int insert(Address a) {

		String sql = "INSERT INTO KURO_ADDRESS (ID, MEMBER_ID, NAME, ZIPCODE, ADDRESS1, ADDRESS2, COUNTRY, PHONE, CUSTOMS_CODE) "
				+ "VALUES (ADDRESS_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?)";

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, a.getMemberId());
			pstmt.setString(2, a.getName());
			pstmt.setString(3, a.getZipcode());
			pstmt.setString(4, a.getAddress1());
			pstmt.setString(5, a.getAddress2());
			pstmt.setString(6, a.getCountry());
			pstmt.setString(7, a.getPhone());
			pstmt.setString(8, a.getCustomsCode());
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 주소 수정. 내 주소가 아니면 0건이 바뀌므로 0 */
	public int update(Address a) {

		String sql = "UPDATE KURO_ADDRESS SET NAME = ?, ZIPCODE = ?, ADDRESS1 = ?, ADDRESS2 = ?, COUNTRY = ?, PHONE = ?, CUSTOMS_CODE = ? "
				+ "WHERE ID = ? AND MEMBER_ID = ?";

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, a.getName());
			pstmt.setString(2, a.getZipcode());
			pstmt.setString(3, a.getAddress1());
			pstmt.setString(4, a.getAddress2());
			pstmt.setString(5, a.getCountry());
			pstmt.setString(6, a.getPhone());
			pstmt.setString(7, a.getCustomsCode());
			pstmt.setLong(8, a.getId());
			pstmt.setLong(9, a.getMemberId());
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 주소 삭제. 내 주소가 아니면 0건이 지워지므로 0 */
	public int delete(long memberId, long id) {

		String sql = "DELETE FROM KURO_ADDRESS WHERE ID = ? AND MEMBER_ID = ?";

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, id);
			pstmt.setLong(2, memberId);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	// ResultSet 한 줄 -> Address (주소 DTO)
	private Address toAddress(ResultSet rs) throws Exception {
		Address a = new Address();
		a.setId(rs.getLong("ID"));
		a.setMemberId(rs.getLong("MEMBER_ID"));
		a.setName(rs.getString("NAME"));
		a.setZipcode(rs.getString("ZIPCODE"));
		a.setAddress1(rs.getString("ADDRESS1"));
		a.setAddress2(rs.getString("ADDRESS2"));
		a.setCountry(rs.getString("COUNTRY"));
		a.setPhone(rs.getString("PHONE"));
		a.setCustomsCode(rs.getString("CUSTOMS_CODE"));
		return a;
	}
}
