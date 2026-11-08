package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jp.kurologi.model.MemberDTO;
import util.DBmanager;

// KURO_MEMBER 테이블 전용 DAO (DB 에 SQL 을 보내는 일만 한다)
// blogProject2 의 MemberDAO 와 같은 역할 : 회원가입 · 로그인 · 아이디 중복확인 + 마이페이지(회원정보 수정 · 탈퇴 · 예치금)
// DAO 는 "메서드 모음", 화면 흐름은 Command(service) 가 맡는다.

public class MemberDAO {

	// DB 연결을 얻는 곳은 이 메서드 한 군데뿐이다 (같은 패키지의 DbMemberRepository, MemberFindDAO 도 이걸 쓴다)
	static Connection conn() throws Exception {
		return DBmanager.getInstance();
	}

	// SELECT 할 컬럼 목록 (날짜는 to_char 로 문자열 변환)
	private static final String COLUMNS =
			"ID, LOGIN_ID, PASSWORD_HASH, NAME, ENGLISH_NAME, MAILBOX_NO, MEMBER_NO, PHONE, EMAIL, "
			+ "SMS_REFUSE, MEMBER_TYPE, GRADE, POINTS, REFERRAL_POINTS_PENDING, REFERRAL_CODE, "
			+ "DEPOSIT, COUPONS, TO_CHAR(LAST_LOGIN_AT, 'YYYY-MM-DD HH24:MI:SS') AS LAST_LOGIN_AT, WITHDRAWN";

	// ---------------------------------------------------------------- 회원가입 / 로그인

	/** 아이디 중복 여부. true = 이미 있는 아이디(중복) */
	public boolean idCheck(String loginId) {

		String sql = "SELECT ID FROM KURO_MEMBER WHERE LOGIN_ID = ?";
		boolean isDuplicate = false;   // 우선 중복이 아니라고 가정

		// try-with-resources : 괄호 안에서 연 자원은 끝나면 자동으로 close 된다
		try (Connection conn = conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, loginId);
			try (ResultSet rs = pstmt.executeQuery()) {
				isDuplicate = rs.next();   // 한 줄이라도 나오면 이미 있는 아이디
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return isDuplicate;
	}

	/** 다음 회원 번호(MEMBER_SEQ). 실패하면 -1 */
	public long nextId() {

		String sql = "SELECT MEMBER_SEQ.NEXTVAL FROM DUAL";

		try (Connection conn = conn();
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
	 * 회원 등록. 성공하면 1, 실패하면 0.
	 * MEMBER_TYPE, GRADE, POINTS, DEPOSIT, COUPONS, WITHDRAWN 등은 테이블 DEFAULT 값에 맡긴다.
	 * 비밀번호 퀴즈 답(PW_QUIZ_ANSWER)도 함께 저장한다.
	 */
	public int memberInsert(MemberDTO dto) {

		String sql = "INSERT INTO KURO_MEMBER "
				+ "(ID, LOGIN_ID, PASSWORD_HASH, NAME, ENGLISH_NAME, MAILBOX_NO, MEMBER_NO, PHONE, EMAIL, SMS_REFUSE, PW_QUIZ_ANSWER) "
				+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

		try (Connection conn = conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setLong(1, dto.getId());
			pstmt.setString(2, dto.getLoginId());
			pstmt.setString(3, dto.getPasswordHash());
			pstmt.setString(4, dto.getName());
			pstmt.setString(5, dto.getEnglishName());
			pstmt.setString(6, dto.getMailboxNo());
			pstmt.setString(7, dto.getMemberNo());
			pstmt.setString(8, dto.getPhone());
			pstmt.setString(9, dto.getEmail());
			pstmt.setString(10, dto.isSmsRefuse() ? "Y" : "N");
			pstmt.setString(11, dto.getPwQuizAnswerHash());

			return pstmt.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 로그인용 조회. 아이디로 한 명을 찾아 DTO 로 돌려준다(없으면 null). 비밀번호 비교는 Command 에서 한다 */
	public MemberDTO login(String loginId) {

		String sql = "SELECT " + COLUMNS + " FROM KURO_MEMBER WHERE LOGIN_ID = ?";
		MemberDTO dto = null;

		try (Connection conn = conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, loginId);

			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {   // 딱 한 명만 찾으니 while 이 아니라 if
					dto = toDto(rs);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dto;
	}

	/** 로그인 성공 시 마지막 로그인 시각 갱신 */
	public void updateLastLogin(long id) {

		String sql = "UPDATE KURO_MEMBER SET LAST_LOGIN_AT = SYSTIMESTAMP WHERE ID = ?";

		try (Connection conn = conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, id);
			pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// ---------------------------------------------------------------- 마이페이지

	/** 회원 번호(ID)로 조회. 탈퇴한 회원이거나 없으면 null. 마이페이지가 열릴 때마다 최신 값을 읽는 데 쓴다 */
	public MemberDTO findById(long id) {

		String sql = "SELECT " + COLUMNS + " FROM KURO_MEMBER WHERE ID = ? AND NVL(WITHDRAWN, 'N') = 'N'";
		MemberDTO dto = null;

		try (Connection conn = conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, id);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					dto = toDto(rs);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dto;
	}

	/** 계정관리 — 영문이름 · 휴대폰 · SMS 수신거부 · 회원구분 수정. 성공하면 1 */
	public int updateInfo(long id, String englishName, String phone, boolean smsRefuse, String memberType) {

		String sql = "UPDATE KURO_MEMBER SET ENGLISH_NAME = ?, PHONE = ?, SMS_REFUSE = ?, MEMBER_TYPE = ? WHERE ID = ?";

		try (Connection conn = conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, englishName);
			pstmt.setString(2, phone);
			pstmt.setString(3, smsRefuse ? "Y" : "N");
			pstmt.setString(4, memberType);
			pstmt.setLong(5, id);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 계정관리 — 비밀번호 변경 (이미 암호화된 값을 받는다). 성공하면 1 */
	public int updatePassword(long id, String passwordHash) {

		String sql = "UPDATE KURO_MEMBER SET PASSWORD_HASH = ? WHERE ID = ?";

		try (Connection conn = conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, passwordHash);
			pstmt.setLong(2, id);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 탈퇴 처리. 행을 지우지 않고 WITHDRAWN = 'Y' 로만 표시한다(주문 · 결제 기록을 남기기 위해). 성공하면 1 */
	public int withdraw(long id) {

		String sql = "UPDATE KURO_MEMBER SET WITHDRAWN = 'Y' WHERE ID = ?";

		try (Connection conn = conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, id);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 예치금 충전. 현재 값에 금액을 더한다 (DEPOSIT = DEPOSIT + ?). 성공하면 1 */
	public int addDeposit(long id, long amount) {

		String sql = "UPDATE KURO_MEMBER SET DEPOSIT = DEPOSIT + ? WHERE ID = ?";

		try (Connection conn = conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, amount);
			pstmt.setLong(2, id);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	/** 예치금 사용(결제). 잔액이 모자라면 아무것도 바꾸지 않고 0 을 돌려준다 (DEPOSIT >= ? 조건). 성공하면 1 */
	public int useDeposit(long id, long amount) {

		String sql = "UPDATE KURO_MEMBER SET DEPOSIT = DEPOSIT - ? WHERE ID = ? AND DEPOSIT >= ?";

		try (Connection conn = conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setLong(1, amount);
			pstmt.setLong(2, id);
			pstmt.setLong(3, amount);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	// ---------------------------------------------------------------- 내부 도우미

	// ResultSet 한 줄 -> MemberDTO (login, findById 가 같이 쓴다)
	private MemberDTO toDto(ResultSet rs) throws Exception {
		MemberDTO dto = new MemberDTO();
		dto.setId(rs.getLong("ID"));
		dto.setLoginId(rs.getString("LOGIN_ID"));
		dto.setPasswordHash(rs.getString("PASSWORD_HASH"));
		dto.setName(rs.getString("NAME"));
		dto.setEnglishName(rs.getString("ENGLISH_NAME"));
		dto.setMailboxNo(rs.getString("MAILBOX_NO"));
		dto.setMemberNo(rs.getString("MEMBER_NO"));
		dto.setPhone(rs.getString("PHONE"));
		dto.setEmail(rs.getString("EMAIL"));
		dto.setSmsRefuse("Y".equals(rs.getString("SMS_REFUSE")));
		dto.setMemberType(rs.getString("MEMBER_TYPE"));
		dto.setGrade(rs.getString("GRADE"));
		dto.setPoints(rs.getLong("POINTS"));
		dto.setReferralPointsPending(rs.getLong("REFERRAL_POINTS_PENDING"));
		dto.setReferralCode(rs.getString("REFERRAL_CODE"));
		dto.setDeposit(rs.getLong("DEPOSIT"));
		dto.setCoupons(rs.getInt("COUPONS"));
		dto.setLastLoginAt(rs.getString("LAST_LOGIN_AT"));
		dto.setWithdrawn("Y".equals(rs.getString("WITHDRAWN")));
		return dto;
	}
}
