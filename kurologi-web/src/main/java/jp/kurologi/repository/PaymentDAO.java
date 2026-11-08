package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.Charge;
import jp.kurologi.model.Payment;

// 결제 관련 테이블(CHARGE: 결제 대기건 / PAYMENT: 결제 1건) 전용 DAO
// 마이페이지의 "결제방법" 화면과 운송품 현황이 쓴다. DAO 는 SQL 만 보내고, 결제 순서는 PaymentCommand 가 정한다.
//
// - CHARGE  : 배송비 · 관부가세 등 "내야 할 돈" 한 줄 (상태 PENDING 이면 결제 대기)
// - PAYMENT : 대기건 여러 개를 묶어 결제한 기록 한 줄 (묶인 청구번호는 CHARGE.PAYMENT_ID 로 찾는다)

public class PaymentDAO {

	private static final String CHARGE_COLS = "ID, MEMBER_ID, PAYMENT_ID, TITLE, ORDER_NO, AMOUNT, STATUS, CREATED_AT";
	private static final String PAYMENT_COLS = "ID, MEMBER_ID, SUMMARY, TOTAL_AMOUNT, COUPON_DISCOUNT, DEPOSIT_USED, "
			+ "PAY_AMOUNT, METHOD, STATUS, DEPOSITOR_NAME, CREATED_AT, PAID_AT, "
			+ "KR_METHOD, KR_WAYBILL_NO, JP_CARRIER, JP_WAYBILL_NO";

	// ---------------------------------------------------------------- 결제 대기건(CHARGE)

	/** 결제 대기건 개수 (상단 요약 바의 "미결제", 탈퇴 가능 여부 확인에 쓴다) */
	public int countPending(long memberId) {

		String sql = "SELECT COUNT(*) FROM CHARGE WHERE MEMBER_ID = ? AND STATUS = 'PENDING'";

		try (Connection conn = MemberDAO.conn();
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

	/** 비용결제 탭에 보일 결제 대기건 (오래된 순) */
	public List<Charge> findPendingCharges(long memberId) {

		String sql = "SELECT " + CHARGE_COLS + " FROM CHARGE WHERE MEMBER_ID = ? AND STATUS = 'PENDING' ORDER BY CREATED_AT, ID";
		List<Charge> list = new ArrayList<>();

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, memberId);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					list.add(toCharge(rs));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 번호(ids)로 청구건 조회. 남의 청구건을 못 찾도록 memberId 도 같이 조건에 넣는다 */
	public List<Charge> findCharges(long memberId, List<Long> ids) {

		List<Charge> list = new ArrayList<>();
		if (ids == null || ids.isEmpty()) {
			return list;
		}

		// IN (?,?,?) 의 물음표를 번호 개수만큼 만든다
		StringBuilder in = new StringBuilder();
		for (int i = 0; i < ids.size(); i++) {
			in.append(i == 0 ? "?" : ",?");
		}
		String sql = "SELECT " + CHARGE_COLS + " FROM CHARGE WHERE MEMBER_ID = ? AND ID IN (" + in + ") ORDER BY CREATED_AT, ID";

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			int i = 1;
			pstmt.setLong(i++, memberId);
			for (Long id : ids) {
				pstmt.setLong(i++, id);
			}
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					list.add(toCharge(rs));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 결제가 끝난 청구건들을 PAID 로 바꾸고 어느 결제(paymentId)에 묶였는지 기록한다. 바뀐 건수를 돌려준다 */
	public int updateChargesPaid(long memberId, List<Long> ids, long paymentId) {

		StringBuilder in = new StringBuilder();
		for (int i = 0; i < ids.size(); i++) {
			in.append(i == 0 ? "?" : ",?");
		}
		String sql = "UPDATE CHARGE SET STATUS = 'PAID', PAYMENT_ID = ? WHERE MEMBER_ID = ? AND STATUS = 'PENDING' AND ID IN (" + in + ")";

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			int i = 1;
			pstmt.setLong(i++, paymentId);
			pstmt.setLong(i++, memberId);
			for (Long id : ids) {
				pstmt.setLong(i++, id);
			}
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	// ---------------------------------------------------------------- 결제(PAYMENT)

	/** 결제내역 (최근 결제가 위로). 각 결제에 묶인 청구번호 목록도 함께 담는다 */
	public List<Payment> findPayments(long memberId) {

		String sql = "SELECT " + PAYMENT_COLS + " FROM PAYMENT WHERE MEMBER_ID = ? ORDER BY CREATED_AT DESC, ID DESC";
		List<Payment> list = new ArrayList<>();

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, memberId);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					list.add(toPayment(rs));
				}
			}
			for (Payment p : list) {
				p.setChargeIds(chargeIdsOf(conn, p.getId()));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 결제 1건 저장. 성공하면 새 결제 번호(PAYMENT_SEQ)를 p 에 넣고 true */
	public boolean insertPayment(Payment p) {

		String sql = "INSERT INTO PAYMENT (ID, MEMBER_ID, SUMMARY, TOTAL_AMOUNT, COUPON_DISCOUNT, DEPOSIT_USED, "
				+ "PAY_AMOUNT, METHOD, STATUS, DEPOSITOR_NAME, CREATED_AT, PAID_AT, "
				+ "KR_METHOD, KR_WAYBILL_NO, JP_CARRIER, JP_WAYBILL_NO) "
				+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

		try (Connection conn = MemberDAO.conn()) {

			long id = nextVal(conn, "PAYMENT_SEQ");

			try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
				pstmt.setLong(1, id);
				pstmt.setLong(2, p.getMemberId());
				pstmt.setString(3, cut(p.getSummary(), 90));
				pstmt.setLong(4, p.getTotalAmount());
				pstmt.setLong(5, p.getCouponDiscount());
				pstmt.setLong(6, p.getDepositUsed());
				pstmt.setLong(7, p.getPayAmount());
				pstmt.setString(8, p.getMethod().name());
				pstmt.setString(9, p.getStatus().name());
				pstmt.setString(10, p.getDepositorName());
				pstmt.setTimestamp(11, Timestamp.valueOf(p.getCreatedAt()));
				pstmt.setTimestamp(12, p.getPaidAt() == null ? null : Timestamp.valueOf(p.getPaidAt()));
				pstmt.setString(13, p.getKrMethod());
				pstmt.setString(14, p.getKrWaybillNo());
				pstmt.setString(15, p.getJpCarrier());
				pstmt.setString(16, p.getJpWaybillNo());
				pstmt.executeUpdate();
			}
			p.setId(id);
			return true;

		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	/** 운송장 정보만 수정 (운송장 기능을 넣기 전에 결제한 건에 뒤늦게 운송장을 채울 때 쓴다) */
	public int updateWaybill(Payment p) {

		String sql = "UPDATE PAYMENT SET KR_METHOD = ?, KR_WAYBILL_NO = ?, JP_CARRIER = ?, JP_WAYBILL_NO = ? WHERE ID = ?";

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, p.getKrMethod());
			pstmt.setString(2, p.getKrWaybillNo());
			pstmt.setString(3, p.getJpCarrier());
			pstmt.setString(4, p.getJpWaybillNo());
			pstmt.setLong(5, p.getId());
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	// ---------------------------------------------------------------- 내부 도우미

	// 시퀀스의 다음 번호
	private static long nextVal(Connection conn, String seq) throws SQLException {
		try (PreparedStatement pstmt = conn.prepareStatement("SELECT " + seq + ".NEXTVAL FROM DUAL");
				ResultSet rs = pstmt.executeQuery()) {
			rs.next();
			return rs.getLong(1);
		}
	}

	// 결제에 묶인 청구번호들
	private static List<Long> chargeIdsOf(Connection conn, long paymentId) throws SQLException {
		List<Long> ids = new ArrayList<>();
		try (PreparedStatement pstmt = conn.prepareStatement("SELECT ID FROM CHARGE WHERE PAYMENT_ID = ? ORDER BY ID")) {
			pstmt.setLong(1, paymentId);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					ids.add(rs.getLong(1));
				}
			}
		}
		return ids;
	}

	// 컬럼 길이를 넘지 않도록 글자 수로 자른다
	private static String cut(String s, int max) {
		if (s == null) return "";
		return s.length() > max ? s.substring(0, max) : s;
	}

	// ResultSet 한 줄 -> Charge
	private static Charge toCharge(ResultSet rs) throws SQLException {
		Charge c = new Charge();
		c.setId(rs.getLong("ID"));
		c.setMemberId(rs.getLong("MEMBER_ID"));
		long pid = rs.getLong("PAYMENT_ID");
		c.setPaymentId(rs.wasNull() ? null : pid);   // NULL 이면 아직 결제 전
		c.setTitle(rs.getString("TITLE"));
		c.setOrderNo(rs.getString("ORDER_NO"));
		c.setAmount(rs.getLong("AMOUNT"));
		c.setStatus(Charge.Status.valueOf(rs.getString("STATUS")));
		c.setCreatedAt(rs.getTimestamp("CREATED_AT").toLocalDateTime());
		return c;
	}

	// ResultSet 한 줄 -> Payment
	private static Payment toPayment(ResultSet rs) throws SQLException {
		Payment p = new Payment();
		p.setId(rs.getLong("ID"));
		p.setMemberId(rs.getLong("MEMBER_ID"));
		p.setSummary(rs.getString("SUMMARY"));
		p.setTotalAmount(rs.getLong("TOTAL_AMOUNT"));
		p.setCouponDiscount(rs.getLong("COUPON_DISCOUNT"));
		p.setDepositUsed(rs.getLong("DEPOSIT_USED"));
		p.setPayAmount(rs.getLong("PAY_AMOUNT"));
		p.setMethod(Payment.Method.valueOf(rs.getString("METHOD")));
		p.setStatus(Payment.Status.valueOf(rs.getString("STATUS")));
		p.setDepositorName(rs.getString("DEPOSITOR_NAME"));
		p.setCreatedAt(rs.getTimestamp("CREATED_AT").toLocalDateTime());
		Timestamp paid = rs.getTimestamp("PAID_AT");
		p.setPaidAt(paid == null ? null : paid.toLocalDateTime());
		p.setKrMethod(rs.getString("KR_METHOD"));
		p.setKrWaybillNo(rs.getString("KR_WAYBILL_NO"));
		p.setJpCarrier(rs.getString("JP_CARRIER"));
		p.setJpWaybillNo(rs.getString("JP_WAYBILL_NO"));
		p.setChargeIds(new ArrayList<>());
		return p;
	}
}
