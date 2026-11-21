package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.Grade;
import jp.kurologi.model.MailboxCenter;
import jp.kurologi.model.MemberDTO;
import jp.kurologi.model.UsageStats;

/**
 * 마이페이지 첫 화면 서비스
 * 화면(mypage.jsp)에 필요한 값을 모아서 request 에 담는다. (blogProject2 의 MypageCommand 와 같은 역할)
 * 로그인 확인과 회원정보("member")는 MyPageController 가 이미 담아 두었다.
 */
public class MyPageMain implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		MemberDTO member = (MemberDTO) request.getAttribute("member");

		// 이용실적 (전월 · 당월 · 누적 이용건수) : 화물(shipment) 집계 테이블이 생기기 전이라 지금은 0건으로 보여준다
		UsageStats usage = UsageStats.EMPTY;
		request.setAttribute("usage", usage);

		// 일본 사서함(센터) 주소 목록
		request.setAttribute("centers", MailboxCenter.ALL);

		// 다음 등급 안내 : 이미 최고 등급이면 null
		boolean topGrade = "ROYAL_FAMILY".equals(member.getGrade());
		request.setAttribute("nextGrade", topGrade ? null : Grade.ROYAL_FAMILY);
		request.setAttribute("countToNextGrade", Math.max(0, Grade.ROYAL_FAMILY_THRESHOLD - usage.thisMonth()));

		// 친구 추천 링크
		request.setAttribute("referralUrl", baseUrl(request) + "/member/join?ref=" + member.getReferralCode());

		// 결제가 완료된 운송품 현황 (최근 결제 5건)
		request.setAttribute("shipments", ShipmentBoard.load(member.getId()));

		return true;   // 컨트롤러가 mypage.jsp 로 forward 한다 
	}

	// http://서버:포트/프로젝트 까지의 주소를 만든다  
	private static String baseUrl(HttpServletRequest req) {
		String port = (req.getServerPort() == 80 || req.getServerPort() == 443) ? "" : ":" + req.getServerPort();
		return req.getScheme() + "://" + req.getServerName() + port + req.getContextPath();
	}
}
