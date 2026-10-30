package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import jp.kurologi.model.Charge;
import jp.kurologi.model.Payment;

/**
 * CHARGE · PAYMENT 테이블을 읽고 쓰는 결제 저장소 (InMemoryPaymentRepository 를 대신한다).
 * 결제에 묶인 청구 번호 목록은 PAYMENT 에 따로 저장하지 않고, CHARGE.PAYMENT_ID 로 찾는다.
 * 먼저 CHARGE, PAYMENT 테이블과 CHARGE_SEQ, PAYMENT_SEQ 시퀀스가 만들어져 있어야 한다.
 */
public class DbPaymentRepository implements PaymentRepository {

	private static final String CHARGE_COLS = "ID, MEMBER_ID, PAYMENT_ID, TITLE, ORDER_NO, AMOUNT, STATUS, CREATED_AT";
	private static final String PAYMENT_COLS = "ID, MEMBER_ID, SUMMARY, TOTAL_AMOUNT, COUPON_DISCOUNT, DEPOSIT_USED, "
			+ "PAY_AMOUNT, METHOD, STATUS, DEPOSITOR_NAME, CREATED_AT, PAID_AT";

	// ------------------------------------------------------------------ 청구

	@Override
	public List<Charge> findPendingCharges(long memberId) {
		String sql = "SELECT " + CHARGE_COLS + " FROM CHARGE WHERE MEMBER_ID = ? AND STATUS = 'PENDING' ORDER BY CREATED_AT, ID";
		List<Charge> list = new ArrayList<>();
		try (Connection conn = MemberDAO.conn(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, memberId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) list.add(mapCharge(rs));
			}
		} catch (Exception e) {
			throw new IllegalStateException("결제 대기건을 읽지 못했습니다.", e);
		}
		return list;
	}

	@Override
	public List<Charge> findCharges(long memberId, List<Long> ids) {
		List<Charge> list = new ArrayList<>();
		if (ids == null || ids.isEmpty()) return list;

		StringBuilder in = new StringBuilder();
		for (int i = 0; i < ids.size(); i++) in.append(i == 0 ? "?" : ",?");
		String sql = "SELECT " + CHARGE_COLS + " FROM CHARGE WHERE MEMBER_ID = ? AND ID IN (" + in + ") ORDER BY CREATED_AT, ID";

		try (Connection conn = MemberDAO.conn(); PreparedStatement ps = conn.prepareStatement(sql)) {
			int i = 1;
			ps.setLong(i++, memberId);
			for (Long id : ids) ps.setLong(i++, id);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) list.add(mapCharge(rs));
			}
		} catch (Exception e) {
			throw new IllegalStateException("청구건을 읽지 못했습니다.", e);
		}
		return list;
	}

	@Override
	public void saveCharge(Charge c) {
		try (Connection conn = MemberDAO.conn()) {
			if (c.getId() == 0) {
				c.setId(nextVal(conn, "CHARGE_SEQ"));
				String sql = "INSERT INTO CHARGE (ID, MEMBER_ID, PAYMENT_ID, TITLE, ORDER_NO, AMOUNT, STATUS, CREATED_AT) "
						+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
				try (PreparedStatement ps = conn.prepareStatement(sql)) {
					ps.setLong(1, c.getId());
					ps.setLong(2, c.getMemberId());
					setLongOrNull(ps, 3, c.getPaymentId());
					ps.setString(4, cut(c.getTitle(), 60));
					ps.setString(5, c.getOrderNo());
					ps.setLong(6, c.getAmount());
					ps.setString(7, c.getStatus().name());
					ps.setTimestamp(8, Timestamp.valueOf(c.getCreatedAt()));
					ps.executeUpdate();
				}
			} else {
				String sql = "UPDATE CHARGE SET PAYMENT_ID = ?, TITLE = ?, ORDER_NO = ?, AMOUNT = ?, STATUS = ? WHERE ID = ?";
				try (PreparedStatement ps = conn.prepareStatement(sql)) {
					setLongOrNull(ps, 1, c.getPaymentId());
					ps.setString(2, cut(c.getTitle(), 60));
					ps.setString(3, c.getOrderNo());
					ps.setLong(4, c.getAmount());
					ps.setString(5, c.getStatus().name());
					ps.setLong(6, c.getId());
					ps.executeUpdate();
				}
			}
		} catch (Exception e) {
			throw new IllegalStateException("청구건을 저장하지 못했습니다.", e);
		}
	}

	// ------------------------------------------------------------------ 결제

	@Override
	public List<Payment> findPayments(long memberId) {
		String sql = "SELECT " + PAYMENT_COLS + " FROM PAYMENT WHERE MEMBER_ID = ? ORDER BY CREATED_AT DESC, ID DESC";
		List<Payment> list = new ArrayList<>();
		try (Connection conn = MemberDAO.conn(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, memberId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) list.add(mapPayment(rs));
			}
			for (Payment p : list) p.setChargeIds(chargeIdsOf(conn, p.getId()));
		} catch (Exception e) {
			throw new IllegalStateException("결제내역을 읽지 못했습니다.", e);
		}
		return list;
	}

	@Override
	public Optional<Payment> findPayment(long id) {
		String sql = "SELECT " + PAYMENT_COLS + " FROM PAYMENT WHERE ID = ?";
		try (Connection conn = MemberDAO.conn(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, id);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					Payment p = mapPayment(rs);
					p.setChargeIds(chargeIdsOf(conn, p.getId()));
					return Optional.of(p);
				}
			}
		} catch (Exception e) {
			throw new IllegalStateException("결제 정보를 읽지 못했습니다.", e);
		}
		return Optional.empty();
	}

	@Override
	public Payment savePayment(Payment p) {
		try (Connection conn = MemberDAO.conn()) {
			if (p.getId() == 0) {
				p.setId(nextVal(conn, "PAYMENT_SEQ"));
				String sql = "INSERT INTO PAYMENT (ID, MEMBER_ID, SUMMARY, TOTAL_AMOUNT, COUPON_DISCOUNT, DEPOSIT_USED, "
						+ "PAY_AMOUNT, METHOD, STATUS, DEPOSITOR_NAME, CREATED_AT, PAID_AT) "
						+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
				try (PreparedStatement ps = conn.prepareStatement(sql)) {
					ps.setLong(1, p.getId());
					ps.setLong(2, p.getMemberId());
					ps.setString(3, cut(p.getSummary(), 90));
					ps.setLong(4, p.getTotalAmount());
					ps.setLong(5, p.getCouponDiscount());
					ps.setLong(6, p.getDepositUsed());
					ps.setLong(7, p.getPayAmount());
					ps.setString(8, p.getMethod().name());
					ps.setString(9, p.getStatus().name());
					ps.setString(10, p.getDepositorName());
					ps.setTimestamp(11, Timestamp.valueOf(p.getCreatedAt()));
					ps.setTimestamp(12, p.getPaidAt() == null ? null : Timestamp.valueOf(p.getPaidAt()));
					ps.executeUpdate();
				}
			} else {
				String sql = "UPDATE PAYMENT SET STATUS = ?, DEPOSITOR_NAME = ?, PAID_AT = ? WHERE ID = ?";
				try (PreparedStatement ps = conn.prepareStatement(sql)) {
					ps.setString(1, p.getStatus().name());
					ps.setString(2, p.getDepositorName());
					ps.setTimestamp(3, p.getPaidAt() == null ? null : Timestamp.valueOf(p.getPaidAt()));
					ps.setLong(4, p.getId());
					ps.executeUpdate();
				}
			}
		} catch (Exception e) {
			throw new IllegalStateException("결제 정보를 저장하지 못했습니다.", e);
		}
		return p;
	}

	// ------------------------------------------------------------------ 도우미

	private static long nextVal(Connection conn, String seq) throws SQLException {
		try (PreparedStatement ps = conn.prepareStatement("SELECT " + seq + ".NEXTVAL FROM DUAL");
				ResultSet rs = ps.executeQuery()) {
			rs.next();
			return rs.getLong(1);
		}
	}

	private static List<Long> chargeIdsOf(Connection conn, long paymentId) throws SQLException {
		List<Long> ids = new ArrayList<>();
		try (PreparedStatement ps = conn.prepareStatement("SELECT ID FROM CHARGE WHERE PAYMENT_ID = ? ORDER BY ID")) {
			ps.setLong(1, paymentId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) ids.add(rs.getLong(1));
			}
		}
		return ids;
	}

	private static void setLongOrNull(PreparedStatement ps, int idx, Long v) throws SQLException {
		if (v == null) ps.setNull(idx, java.sql.Types.NUMERIC);
		else ps.setLong(idx, v);
	}

	/** 컬럼 길이(바이트)를 넘지 않도록 글자 수로 자른다 (한글 3바이트 기준 여유) */
	private static String cut(String s, int max) {
		if (s == null) return "";
		return s.length() > max ? s.substring(0, max) : s;
	}

	private static Charge mapCharge(ResultSet rs) throws SQLException {
		Charge c = new Charge();
		c.setId(rs.getLong("ID"));
		c.setMemberId(rs.getLong("MEMBER_ID"));
		long pid = rs.getLong("PAYMENT_ID");
		c.setPaymentId(rs.wasNull() ? null : pid);
		c.setTitle(rs.getString("TITLE"));
		c.setOrderNo(rs.getString("ORDER_NO"));
		c.setAmount(rs.getLong("AMOUNT"));
		c.setStatus(Charge.Status.valueOf(rs.getString("STATUS")));
		c.setCreatedAt(rs.getTimestamp("CREATED_AT").toLocalDateTime());
		return c;
	}

	private static Payment mapPayment(ResultSet rs) throws SQLException {
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
		p.setChargeIds(new ArrayList<>());
		return p;
	}
}
