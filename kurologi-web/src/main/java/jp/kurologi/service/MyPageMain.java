package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.Grade;
import jp.kurologi.model.MailboxCenter;
import jp.kurologi.model.Member;
import jp.kurologi.model.UsageStats;
import jp.kurologi.web.App;
import jp.kurologi.web.Session;

/** 마이페이지 첫 화면에 필요한 값을 모아서 request 에 담는다 (기존 MyPageServlet + BaseServlet.render 의 내용) */
public class MyPageMain implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		App app = App.of(request.getServletContext());

		// AuthFilter 를 통과했으므로 로그인한 회원이 반드시 있다
		Member m = app.members.findById(Session.memberId(request)).orElseThrow();
		UsageStats usage = app.members.usageStats(m.getId());

		// 모든 마이페이지 화면이 쓰는 값 (BaseServlet.render 가 넣던 것)
		request.setAttribute("member", m);
		request.setAttribute("unpaidCount", app.payments.pendingCharges(m.getId()).size());

		// 마이페이지 첫 화면 전용 값
		request.setAttribute("usage", usage);
		request.setAttribute("centers", MailboxCenter.ALL);
		request.setAttribute("nextGrade", m.getGrade() == Grade.ROYAL_FAMILY ? null : Grade.ROYAL_FAMILY);
		request.setAttribute("countToNextGrade", Math.max(0, Grade.ROYAL_FAMILY_THRESHOLD - usage.thisMonth()));
		request.setAttribute("referralUrl", baseUrl(request) + "/member/join?ref=" + m.getReferralCode());

		return true;   // MyPageController 가 mypage.jsp 로 forward 한다
	}

	private static String baseUrl(HttpServletRequest req) {
		String port = (req.getServerPort() == 80 || req.getServerPort() == 443) ? "" : ":" + req.getServerPort();
		return req.getScheme() + "://" + req.getServerName() + port + req.getContextPath();
	}
}
