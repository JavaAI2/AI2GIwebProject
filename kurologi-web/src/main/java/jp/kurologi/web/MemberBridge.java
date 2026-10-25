package jp.kurologi.web;

import java.time.LocalDateTime;

import javax.servlet.ServletContext;

import jp.kurologi.model.Grade;
import jp.kurologi.model.Member;
import jp.kurologi.model.MemberType;
import jp.kurologi.model.MemberDTO;

/**
 * DB(KURO_MEMBER)로 로그인한 회원을 기존 화면들이 쓰는 메모리 저장소(App.members)에도 등록해 주는 다리.
 *
 * 마이페이지 · 홈 · AuthFilter 는 모두 App.members.findById(...) 로 회원을 찾는데,
 * 이 저장소에는 DB 로 가입한 회원이 없어서 "로그인했는데 마이페이지로 못 가는" 문제가 생겼다.
 * 로그인에 성공할 때마다 이 메서드로 회원 정보를 넣어 주면 기존 화면들이 그대로 동작한다.
 *
 * (임시 방편) 주소록/결제/청구 등을 DB 로 옮기는 작업을 하게 되면 이 클래스는 필요 없어진다.
 */
public final class MemberBridge {

	private MemberBridge() {}

	public static void sync(ServletContext context, MemberDTO dto) {

		Member m = new Member();
		m.setId(dto.getId());
		m.setLoginId(dto.getLoginId());
		m.setPasswordHash(dto.getPasswordHash());
		m.setName(dto.getName());
		m.setEnglishName(dto.getEnglishName());
		m.setMailboxNo(dto.getMailboxNo());
		m.setMemberNo(dto.getMemberNo());
		m.setPhone(dto.getPhone());
		m.setEmail(dto.getEmail());
		m.setSmsRefuse(dto.isSmsRefuse());
		m.setPoints(dto.getPoints());
		m.setReferralPointsPending(dto.getReferralPointsPending());
		m.setReferralCode(dto.getReferralCode());
		m.setDeposit(dto.getDeposit());
		m.setCoupons(dto.getCoupons());
		m.setWithdrawn(false);
		m.setLastLoginAt(LocalDateTime.now());

		// DB 에는 문자열(PERSONAL, BASIC ...)로 저장되어 있으므로 enum 으로 바꾼다. 모르는 값이면 기본값
		try {
			m.setMemberType(MemberType.valueOf(dto.getMemberType()));
		} catch (Exception e) {
			m.setMemberType(MemberType.PERSONAL);
		}
		try {
			m.setGrade(Grade.valueOf(dto.getGrade()));
		} catch (Exception e) {
			m.setGrade(Grade.BASIC);
		}

		App.of(context).members.save(m);
	}
}
