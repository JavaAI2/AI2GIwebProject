package jp.kurologi.model;

import java.time.LocalDateTime;
import jp.kurologi.model.Member;
import jp.kurologi.model.MemberType;
import jp.kurologi.model.Grade;
import jp.kurologi.web.Formats;

/**
 * 화면이나 API 응답에 최적화된 DTO 클래스입니다.
 * 패스워드 해시 같은 민감한 데이터는 노출하지 않도록 제외합니다.
 */
public class MemberResponseDto {

    private long id;
    private String loginId;
    private String mailboxNo;
    private String memberNo;
    private String name;
    private String englishName;
    private String phone;
    private String email;
    private boolean smsRefuse;
    private MemberType memberType;
    private Grade grade;
    private long points;
    private long deposit;
    private int coupons;
    private LocalDateTime lastLoginAt;

    // 생성자를 통해 Member 모델을 DTO로 안전하게 변환
    public MemberResponseDto(Member member) {
        this.id = member.getId();
        this.loginId = member.getLoginId();
        this.mailboxNo = member.getMailboxNo();
        this.memberNo = member.getMemberNo();
        this.name = member.getName();
        this.englishName = member.getEnglishName();
        this.phone = member.getPhone();
        this.email = member.getEmail();
        this.smsRefuse = member.isSmsRefuse();
        this.memberType = member.getMemberType();
        this.grade = member.getGrade();
        this.points = member.getPoints();
        this.deposit = member.getDeposit();
        this.coupons = member.getCoupons();
        this.lastLoginAt = member.getLastLoginAt();
    }

    // 화면(UI) 전용 변환 로직은 DTO로 이동
    public String getLastLoginAtText() { 
        return Formats.dateTime(lastLoginAt); 
    }

    /** 사서함 주소의 수취인 칸 — 영문 이름이 없으면 안내 문구. */
    public String getRecipientName() {
        return englishName == null || englishName.isBlank()
                ? "회원님 영문 성함 (또는 회원사명)"
                : englishName;
    }

    // --- Getter들만 생성 (응답 전용이므로 Setter는 불필요) ---
    public long getId() { return id; }
    public String getLoginId() { return loginId; }
    public String getMailboxNo() { return mailboxNo; }
    public String getMemberNo() { return memberNo; }
    public String getName() { return name; }
    public String getEnglishName() { return englishName; }
    public String getPhone() { return phone; }
    public String getEmail() { return email; }
    public boolean isSmsRefuse() { return smsRefuse; }
    public MemberType getMemberType() { return memberType; }
    public Grade getGrade() { return grade; }
    public long getPoints() { return points; }
    public long getDeposit() { return deposit; }
    public int getCoupons() { return coupons; }
    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
}