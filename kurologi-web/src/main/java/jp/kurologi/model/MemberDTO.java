package jp.kurologi.model;

// KURO_MEMBER 테이블의 한 행(회원 1명)을 담는 바구니(DTO)
// blogProject2 의 MemberDTO 와 같은 역할이고, 컬럼이 많아진 것만 다르다.
// 컬럼명 SNAKE_CASE -> 필드명 camelCase 로 1:1 대응시켰다 (예: LOGIN_ID -> loginId)
// 날짜(LAST_LOGIN_AT)는 형변환이 귀찮으니 DAO 에서 to_char 로 바꿔 String 으로 받는다

public class MemberDTO {

	private long id;                  // ID — 회원 고유 번호(MEMBER_SEQ)
	private String loginId;           // LOGIN_ID — 로그인용 아이디
	private String passwordHash;      // PASSWORD_HASH — 암호화된 비밀번호
	private String name;              // NAME — 한글 이름
	private String englishName;       // ENGLISH_NAME — 영문 이름 (사서함 수취인)
	private String mailboxNo;         // MAILBOX_NO — 사서함 번호(KR0000000), 가입 시 자동 발급
	private String memberNo;          // MEMBER_NO — 회원번호, 가입 시 자동 발급
	private String phone;             // PHONE — 휴대폰 번호
	private String email;             // EMAIL — 이메일
	private boolean smsRefuse;        // SMS_REFUSE — SMS 수신 거부(Y/N)
	private String memberType;        // MEMBER_TYPE — PERSONAL(개인) / BUSINESS(사업자)
	private String grade;             // GRADE — BASIC / PARTNER / FAMILY / ROYAL_FAMILY
	private long points;              // POINTS — 보유 포인트
	private long referralPointsPending; // REFERRAL_POINTS_PENDING — 추천 대기 포인트
	private String referralCode;      // REFERRAL_CODE — 추천인 코드
	private long deposit;             // DEPOSIT — 예치금
	private int coupons;              // COUPONS — 쿠폰 개수
	private String lastLoginAt;       // LAST_LOGIN_AT — 마지막 로그인(문자열로 변환해서 받음)
	private boolean withdrawn;        // WITHDRAWN — 탈퇴 여부(Y/N)
	private String pwQuizAnswerHash;  // PW_QUIZ_ANSWER — 비밀번호 찾기 퀴즈 답(암호화). 비밀번호 찾기에서만 쓴다

	// ---- 화면(JSP)에서 쓰기 편하게 만든 보조 메서드 (DB 컬럼은 아니다) ----

	/** 등급 이름 전체. 예) ROYAL_FAMILY -> 로얄패밀리(Royal Family) */
	public String getGradeLabel() {
		return gradeEnum().getLabel();
	}

	/** 등급 이름 중 한글만. 예) 로얄패밀리 */
	public String getGradeLabelShort() {
		return gradeEnum().getLabelShort();
	}

	/** 회원 구분 한글 이름. 예) PERSONAL -> 개인 */
	public String getMemberTypeLabel() {
		try {
			return MemberType.valueOf(memberType).getLabel();
		} catch (Exception e) {
			return MemberType.PERSONAL.getLabel();   // 모르는 값이면 기본값
		}
	}

	/** 사서함 주소의 수취인 칸 — 영문 이름이 없으면 안내 문구 */
	public String getRecipientName() {
		return englishName == null || englishName.isBlank()
				? "회원님 영문 성함 (또는 회원사명)"
				: englishName;
	}

	// DB 에는 문자열로 저장되어 있으므로 enum 으로 바꿔서 라벨을 얻는다. 모르는 값이면 BASIC
	private Grade gradeEnum() {
		try {
			return Grade.valueOf(grade);
		} catch (Exception e) {
			return Grade.BASIC;
		}
	}

	// ---- getter / setter ----
	public long getId() { return id; }
	public void setId(long id) { this.id = id; }
	public String getLoginId() { return loginId; }
	public void setLoginId(String loginId) { this.loginId = loginId; }
	public String getPasswordHash() { return passwordHash; }
	public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
	public String getName() { return name; }
	public void setName(String name) { this.name = name; }
	public String getEnglishName() { return englishName; }
	public void setEnglishName(String englishName) { this.englishName = englishName; }
	public String getMailboxNo() { return mailboxNo; }
	public void setMailboxNo(String mailboxNo) { this.mailboxNo = mailboxNo; }
	public String getMemberNo() { return memberNo; }
	public void setMemberNo(String memberNo) { this.memberNo = memberNo; }
	public String getPhone() { return phone; }
	public void setPhone(String phone) { this.phone = phone; }
	public String getEmail() { return email; }
	public void setEmail(String email) { this.email = email; }
	public boolean isSmsRefuse() { return smsRefuse; }
	public void setSmsRefuse(boolean smsRefuse) { this.smsRefuse = smsRefuse; }
	public String getMemberType() { return memberType; }
	public void setMemberType(String memberType) { this.memberType = memberType; }
	public String getGrade() { return grade; }
	public void setGrade(String grade) { this.grade = grade; }
	public long getPoints() { return points; }
	public void setPoints(long points) { this.points = points; }
	public long getReferralPointsPending() { return referralPointsPending; }
	public void setReferralPointsPending(long referralPointsPending) { this.referralPointsPending = referralPointsPending; }
	public String getReferralCode() { return referralCode; }
	public void setReferralCode(String referralCode) { this.referralCode = referralCode; }
	public long getDeposit() { return deposit; }
	public void setDeposit(long deposit) { this.deposit = deposit; }
	public int getCoupons() { return coupons; }
	public void setCoupons(int coupons) { this.coupons = coupons; }
	public String getLastLoginAt() { return lastLoginAt; }
	public void setLastLoginAt(String lastLoginAt) { this.lastLoginAt = lastLoginAt; }
	public boolean isWithdrawn() { return withdrawn; }
	public void setWithdrawn(boolean withdrawn) { this.withdrawn = withdrawn; }
	public String getPwQuizAnswerHash() { return pwQuizAnswerHash; }
	public void setPwQuizAnswerHash(String pwQuizAnswerHash) { this.pwQuizAnswerHash = pwQuizAnswerHash; }
}
