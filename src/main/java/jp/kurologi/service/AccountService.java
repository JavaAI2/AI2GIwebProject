package jp.kurologi.service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

import jp.kurologi.model.Member;
import jp.kurologi.model.MemberType;
import jp.kurologi.repository.MemberRepository;
import jp.kurologi.repository.PaymentRepository;

/** 계정관리 — 회원정보 수정 · 탈퇴. */
public class AccountService {

    private static final Pattern ENGLISH_NAME = Pattern.compile("^[A-Z][A-Z .,'-]{1,49}$");
    private static final Pattern PHONE = Pattern.compile("^0\\d{1,2}-?\\d{3,4}-?\\d{4}$");
    private static final Pattern PASSWORD = Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d).{8,20}$");

    /** 회원정보 수정 화면에서 받는 값. 비밀번호는 비워 두면 바꾸지 않습니다. */
    public record UpdateForm(String englishName, String newPassword, String newPasswordConfirm,
                             String phone, boolean smsRefuse, MemberType memberType) {}

    private final MemberRepository members;
    private final PaymentRepository payments;

    public AccountService(MemberRepository members, PaymentRepository payments) {
        this.members = members;
        this.payments = payments;
    }

    public void update(Member member, UpdateForm form) {
        Map<String, String> errors = new LinkedHashMap<>();

        String englishName = trim(form.englishName()).toUpperCase();
        if (!ENGLISH_NAME.matcher(englishName).matches()) {
            errors.put("englishName", "영문이름은 영문 대문자와 공백으로 2~50자 입력해 주세요. (사서함 수취인으로 사용됩니다)");
        }

        String phone = trim(form.phone());
        if (!phone.isEmpty() && !PHONE.matcher(phone).matches()) {
            errors.put("phone", "휴대폰 번호 형식이 올바르지 않습니다. 예) 010-1234-5678");
        }

        String newPassword = form.newPassword() == null ? "" : form.newPassword();
        if (!newPassword.isEmpty()) {
            if (!PASSWORD.matcher(newPassword).matches()) {
                errors.put("newPassword", "비밀번호는 영문과 숫자를 포함해 8~20자로 입력해 주세요.");
            } else if (!newPassword.equals(form.newPasswordConfirm())) {
                errors.put("newPasswordConfirm", "비밀번호 확인이 일치하지 않습니다.");
            }
        }

        if (!errors.isEmpty()) throw new ValidationException(errors);

        member.setEnglishName(englishName);
        member.setPhone(phone);
        member.setSmsRefuse(form.smsRefuse());
        if (form.memberType() != null) member.setMemberType(form.memberType());
        if (!newPassword.isEmpty()) member.setPasswordHash(PasswordHasher.hash(newPassword));
        members.save(member);
    }

    /**
     * 탈퇴. 돈이 남아 있으면 막습니다 — 결제 대기건은 먼저 처리하고,
     * 예치금은 환불 신청(1:1 문의) 후에 탈퇴할 수 있습니다.
     */
    public void withdraw(Member member) {
        if (!payments.findPendingCharges(member.getId()).isEmpty()) {
            throw new ValidationException("결제 대기건이 있어 탈퇴할 수 없습니다. 결제를 먼저 완료해 주세요.");
        }
        if (member.getDeposit() > 0) {
            throw new ValidationException("예치금이 남아 있어 탈퇴할 수 없습니다. 1:1 게시판으로 환불을 먼저 신청해 주세요.");
        }
        // TODO 진행 중인 화물(입고~배송중)이 있으면 막기 — shipment 테이블 연결 후
        member.setWithdrawn(true);
        members.save(member);
    }

    static String trim(String s) { return s == null ? "" : s.trim(); }
}
