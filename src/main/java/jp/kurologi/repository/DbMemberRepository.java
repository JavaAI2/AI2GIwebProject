package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Optional;

import jp.kurologi.model.Grade;
import jp.kurologi.model.Member;
import jp.kurologi.model.MemberType;
import jp.kurologi.model.UsageStats;

/**
 * KURO_MEMBER 테이블을 읽고 쓰는 회원 저장소 (InMemoryMemberRepository 를 대신한다).
 * 계정관리(수정/탈퇴), 로그인, 마이페이지가 모두 이 저장소를 거치므로 바뀐 내용이 DB 에 남는다.
 * DB 연결은 MemberDAO.conn() 을 함께 쓴다.
 */
public class DbMemberRepository implements MemberRepository {

	private static final String COLUMNS =
			"ID, LOGIN_ID, PASSWORD_HASH, NAME, ENGLISH_NAME, MAILBOX_NO, MEMBER_NO, PHONE, EMAIL, "
			+ "SMS_REFUSE, MEMBER_TYPE, GRADE, POINTS, REFERRAL_POINTS_PENDING, REFERRAL_CODE, "
			+ "DEPOSIT, COUPONS, LAST_LOGIN_AT, WITHDRAWN";

	/** PreparedStatement 에 ? 값을 채워 주는 작은 도우미 */
	private interface Binder {
		void bind(PreparedStatement ps) throws SQLException;
	}

	@Override
	public Optional<Member> findById(long id) {
		return findOne("WHERE ID = ? AND NVL(WITHDRAWN, 'N') = 'N'", ps -> ps.setLong(1, id));
	}

	@Override
	public Optional<Member> findByLoginId(String loginId) {
		return findOne("WHERE LOGIN_ID = ? AND NVL(WITHDRAWN, 'N') = 'N'", ps -> ps.setString(1, loginId));
	}

	/**
	 * 회원 저장. 이미 있는 회원(ID)이면 수정, 없으면 새로 등록한다.
	 * 아이디(LOGIN_ID)와 비밀번호 퀴즈 답(PW_QUIZ_ANSWER)은 여기서 바꾸지 않는다.
	 * 실패하면 예외를 던진다 -> "수정되었습니다"라고 나오는데 DB 는 그대로인 일이 없도록
	 */
	@Override
	public void save(Member m) {

		String update = "UPDATE KURO_MEMBER SET PASSWORD_HASH = ?, NAME = ?, ENGLISH_NAME = ?, MAILBOX_NO = ?, "
				+ "MEMBER_NO = ?, PHONE = ?, EMAIL = ?, SMS_REFUSE = ?, MEMBER_TYPE = ?, GRADE = ?, POINTS = ?, "
				+ "REFERRAL_POINTS_PENDING = ?, REFERRAL_CODE = ?, DEPOSIT = ?, COUPONS = ?, LAST_LOGIN_AT = ?, "
				+ "WITHDRAWN = ? WHERE ID = ?";

		try (Connection conn = MemberDAO.conn()) {

			int rows;
			try (PreparedStatement ps = conn.prepareStatement(update)) {
				int i = 1;
				ps.setString(i++, m.getPasswordHash());
				ps.setString(i++, m.getName());
				ps.setString(i++, m.getEnglishName());
				ps.setString(i++, m.getMailboxNo());
				ps.setString(i++, m.getMemberNo());
				ps.setString(i++, m.getPhone());
				ps.setString(i++, m.getEmail());
				ps.setString(i++, m.isSmsRefuse() ? "Y" : "N");
				ps.setString(i++, m.getMemberType() == null ? "PERSONAL" : m.getMemberType().name());
				ps.setString(i++, m.getGrade() == null ? "BASIC" : m.getGrade().name());
				ps.setLong(i++, m.getPoints());
				ps.setLong(i++, m.getReferralPointsPending());
				ps.setString(i++, m.getReferralCode());
				ps.setLong(i++, m.getDeposit());
				ps.setInt(i++, m.getCoupons());
				ps.setTimestamp(i++, m.getLastLoginAt() == null ? null : Timestamp.valueOf(m.getLastLoginAt()));
				ps.setString(i++, m.isWithdrawn() ? "Y" : "N");
				ps.setLong(i, m.getId());
				rows = ps.executeUpdate();
			}

			if (rows == 0) {
				insert(conn, m);
			}

		} catch (Exception e) {
			throw new IllegalStateException("회원 정보를 저장하지 못했습니다.", e);
		}
	}

	/** 전월 · 당월 · 누적 이용건수는 shipment(배송) 테이블이 생기면 집계한다. 지금은 비어 있는 값 */
	@Override
	public UsageStats usageStats(long memberId) {
		return UsageStats.EMPTY;
	}

	// ------------------------------------------------------------------ 내부 도우미

	private void insert(Connection conn, Member m) throws SQLException {

		long id = m.getId() != 0 ? m.getId() : new MemberDAO().nextId();

		String sql = "INSERT INTO KURO_MEMBER (ID, LOGIN_ID, PASSWORD_HASH, NAME, ENGLISH_NAME, MAILBOX_NO, MEMBER_NO, "
				+ "PHONE, EMAIL, SMS_REFUSE, MEMBER_TYPE, GRADE, POINTS, REFERRAL_POINTS_PENDING, REFERRAL_CODE, "
				+ "DEPOSIT, COUPONS, LAST_LOGIN_AT, WITHDRAWN) "
				+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

		try (PreparedStatement ps = conn.prepareStatement(sql)) {
			int i = 1;
			ps.setLong(i++, id);
			ps.setString(i++, m.getLoginId());
			ps.setString(i++, m.getPasswordHash());
			ps.setString(i++, m.getName());
			ps.setString(i++, m.getEnglishName());
			ps.setString(i++, m.getMailboxNo());
			ps.setString(i++, m.getMemberNo());
			ps.setString(i++, m.getPhone());
			ps.setString(i++, m.getEmail());
			ps.setString(i++, m.isSmsRefuse() ? "Y" : "N");
			ps.setString(i++, m.getMemberType() == null ? "PERSONAL" : m.getMemberType().name());
			ps.setString(i++, m.getGrade() == null ? "BASIC" : m.getGrade().name());
			ps.setLong(i++, m.getPoints());
			ps.setLong(i++, m.getReferralPointsPending());
			ps.setString(i++, m.getReferralCode());
			ps.setLong(i++, m.getDeposit());
			ps.setInt(i++, m.getCoupons());
			ps.setTimestamp(i++, m.getLastLoginAt() == null ? null : Timestamp.valueOf(m.getLastLoginAt()));
			ps.setString(i, m.isWithdrawn() ? "Y" : "N");
			ps.executeUpdate();
			m.setId(id);
		}
	}

	private Optional<Member> findOne(String where, Binder binder) {

		String sql = "SELECT " + COLUMNS + " FROM KURO_MEMBER " + where;

		try (Connection conn = MemberDAO.conn();
				PreparedStatement ps = conn.prepareStatement(sql)) {
			binder.bind(ps);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return Optional.of(map(rs));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return Optional.empty();
	}

	private Member map(ResultSet rs) throws SQLException {
		Member m = new Member();
		m.setId(rs.getLong("ID"));
		m.setLoginId(rs.getString("LOGIN_ID"));
		m.setPasswordHash(rs.getString("PASSWORD_HASH"));
		m.setName(rs.getString("NAME"));
		m.setEnglishName(rs.getString("ENGLISH_NAME"));
		m.setMailboxNo(rs.getString("MAILBOX_NO"));
		m.setMemberNo(rs.getString("MEMBER_NO"));
		m.setPhone(rs.getString("PHONE"));
		m.setEmail(rs.getString("EMAIL"));
		m.setSmsRefuse("Y".equals(rs.getString("SMS_REFUSE")));
		m.setPoints(rs.getLong("POINTS"));
		m.setReferralPointsPending(rs.getLong("REFERRAL_POINTS_PENDING"));
		m.setReferralCode(rs.getString("REFERRAL_CODE"));
		m.setDeposit(rs.getLong("DEPOSIT"));
		m.setCoupons(rs.getInt("COUPONS"));
		m.setWithdrawn("Y".equals(rs.getString("WITHDRAWN")));

		Timestamp last = rs.getTimestamp("LAST_LOGIN_AT");
		m.setLastLoginAt(last == null ? null : last.toLocalDateTime());

		// DB 에는 문자열(PERSONAL, BASIC ...)로 저장되어 있으므로 enum 으로 바꾼다. 모르는 값이면 기본값
		try {
			m.setMemberType(MemberType.valueOf(rs.getString("MEMBER_TYPE")));
		} catch (Exception e) {
			m.setMemberType(MemberType.PERSONAL);
		}
		try {
			m.setGrade(Grade.valueOf(rs.getString("GRADE")));
		} catch (Exception e) {
			m.setGrade(Grade.BASIC);
		}
		return m;
	}
}
