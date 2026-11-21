package jp.kurologi.model;

import java.time.LocalDateTime;

import jp.kurologi.web.Formats;

public class Member {

    private long id;
    private String loginId;
    private String mailboxNo;        // 사서함번호 (KR0000000) — 가입 시 자동 발급
    private String memberNo;         // 회원번호
    private String name;
    private String englishName;
    private String passwordHash;
    private String phone;
    private String email;
    private boolean smsRefuse;       // 배송비용 통지 수신 거부
    private MemberType memberType = MemberType.PERSONAL;
    private Grade grade = Grade.BASIC;
    private long points;
    private long referralPointsPending;
    private String referralCode;
    private long deposit;            // 예치금
    private int coupons;
    private LocalDateTime lastLoginAt;
    private boolean withdrawn;

    public String getLastLoginAtText() { return Formats.dateTime(lastLoginAt); }

    /** 사서함 주소의 수취인 칸 — 영문 이름이 없으면 안내 문구. */
    public String getRecipientName() {
        return englishName == null || englishName.isBlank()
                ? "회원님 영문 성함 (또는 회원사명)"
                : englishName;
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public String getLoginId() { return loginId; }
    public void setLoginId(String loginId) { this.loginId = loginId; }
    public String getMailboxNo() { return mailboxNo; }
    public void setMailboxNo(String mailboxNo) { this.mailboxNo = mailboxNo; }
    public String getMemberNo() { return memberNo; }
    public void setMemberNo(String memberNo) { this.memberNo = memberNo; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEnglishName() { return englishName; }
    public void setEnglishName(String englishName) { this.englishName = englishName; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public boolean isSmsRefuse() { return smsRefuse; }
    public void setSmsRefuse(boolean smsRefuse) { this.smsRefuse = smsRefuse; }
    public MemberType getMemberType() { return memberType; }
    public void setMemberType(MemberType memberType) { this.memberType = memberType; }
    public Grade getGrade() { return grade; }
    public void setGrade(Grade grade) { this.grade = grade; }
    public long getPoints() { return points; }
    public void setPoints(long points) { this.points = points; }
    public long getReferralPointsPending() { return referralPointsPending; }
    public void setReferralPointsPending(long v) { this.referralPointsPending = v; }
    public String getReferralCode() { return referralCode; }
    public void setReferralCode(String referralCode) { this.referralCode = referralCode; }
    public long getDeposit() { return deposit; }
    public void setDeposit(long deposit) { this.deposit = deposit; }
    public int getCoupons() { return coupons; }
    public void setCoupons(int coupons) { this.coupons = coupons; }
    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }
    public boolean isWithdrawn() { return withdrawn; }
    public void setWithdrawn(boolean withdrawn) { this.withdrawn = withdrawn; }
}
