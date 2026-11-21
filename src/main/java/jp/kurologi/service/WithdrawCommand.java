package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.MemberDTO;
import jp.kurologi.repository.MemberDAO;
import jp.kurologi.repository.PaymentDAO;
import jp.kurologi.web.Session;

/**
 * 회원 탈퇴 서비스 (POST 로만 동작)
 * 돈이 남아 있으면 막는다 : 결제 대기건은 먼저 결제하고, 예치금은 환불 신청 후에 탈퇴할 수 있다.
 * 탈퇴하면 DB 에는 WITHDRAWN = 'Y' 로 표시하고 로그아웃한 뒤 홈으로 이동한다.
 */
public class WithdrawCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String back = request.getContextPath() + "/mypage/account";

		// 주소창(GET)으로 들어와서 탈퇴되는 일이 없도록 POST 만 처리한다
		if (!"POST".equalsIgnoreCase(request.getMethod())) {
			response.sendRedirect(back);
			return false;
		}

		MemberDTO member = (MemberDTO) request.getAttribute("member");

		if (new PaymentDAO().countPending(member.getId()) > 0) {
			Session.flash(request, "error", "결제 대기건이 있어 탈퇴할 수 없습니다. 결제를 먼저 완료해 주세요.");
			response.sendRedirect(back);
			return false;
		}
		if (member.getDeposit() > 0) {
			Session.flash(request, "error", "예치금이 남아 있어 탈퇴할 수 없습니다. 1:1 게시판으로 환불을 먼저 신청해 주세요.");
			response.sendRedirect(back);
			return false;
		}

		if (new MemberDAO().withdraw(member.getId()) == 0) {
			Session.flash(request, "error", "탈퇴 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
			response.sendRedirect(back);
			return false;
		}

		Session.logout(request);   // 세션 제거 (loginMember 포함)
		response.sendRedirect(request.getContextPath() + "/?withdrawn=1#loginForm");
		return false;
	}
}
