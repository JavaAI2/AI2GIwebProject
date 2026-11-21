package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jp.kurologi.model.MemberDTO;
import jp.kurologi.repository.MemberDAO;
import jp.kurologi.repository.PaymentDAO;
import jp.kurologi.service.AccountCommand;
import jp.kurologi.service.AddressCommand;
import jp.kurologi.service.ChargeDepositCommand;
import jp.kurologi.service.Command;
import jp.kurologi.service.DepositCharge;
import jp.kurologi.service.LoginCommand;
import jp.kurologi.service.MyPageMain;
import jp.kurologi.service.PaymentCommand;
import jp.kurologi.service.WithdrawCommand;

/**
 * 마이페이지 컨트롤러 (blogProject2 의 Membercontroller / BoardController 와 같은 doAction + switch 구조)
 *
 *   /mypage                          마이페이지 첫 화면 (나의 정보 · 사서함 주소 · 운송품 현황)
 *   /mypage/account                  계정관리 (회원정보 수정)
 *   /mypage/account/withdraw         회원 탈퇴 (POST)
 *   /mypage/address                  주소관리
 *   /mypage/deposit                  예치금 충전 (시연용 화면)
 *   /mypage/payment                  결제방법 (비용결제 / 결제내역, 선택 결제는 POST)
 *   /mypage/payment/charge-deposit   예치금 30,000원 충전 (시험용, POST)
 *
 * 흐름 : 컨트롤러(로그인 확인 + 주소 판단) -> Command(서비스, 실제 처리) -> JSP
 *        Command 가 true 를 돌려주면 page 로 forward, false 면 이미 redirect 등으로 응답을 끝낸 것
 *
 * 마이페이지는 로그인한 사람만 볼 수 있으므로, 모든 요청에 대해 여기서 먼저 로그인 여부를 확인한다.
 * (blogProject2 의 MypageCommand 가 loginMember 가 null 이면 로그인 화면으로 보내던 것과 같은 일)
 */
@WebServlet("/mypage/*")
public class MyPageController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	// JSP 폴더 (WEB-INF/views/mypage)
	private static final String VIEW = "/WEB-INF/views/mypage/";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doAction(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doAction(request, response);
	}

	protected void doAction(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		// ---- 1. 로그인 확인 : 세션에 loginMember 가 없으면 홈 로그인 상자로 보낸다 ----
		HttpSession session = request.getSession(false);
		MemberDTO loginMember = session == null ? null : (MemberDTO) session.getAttribute(LoginCommand.LOGIN_MEMBER);
		if (loginMember == null) {
			response.sendRedirect(request.getContextPath() + "/?login=required#loginForm");
			return;
		}

		// ---- 2. 최신 회원정보를 DB 에서 다시 읽는다 ----
		// 세션에 담아 둔 값은 로그인 시점의 것이라, 예치금처럼 자주 바뀌는 값은 매번 새로 읽어야 정확하다
		MemberDTO member = new MemberDAO().findById(loginMember.getId());
		if (member == null) {   // 그 사이 탈퇴했거나 삭제된 회원이면 로그아웃 처리
			session.invalidate();
			response.sendRedirect(request.getContextPath() + "/?login=required#loginForm");
			return;
		}

		// 모든 마이페이지 화면(JSP)과 Command 가 같이 쓰는 값
		//   member      : 최신 회원정보 (화면 상단 요약 바 · 각 Command 가 사용)
		//   unpaidCount : 미결제 건수 (요약 바에 표시)
		request.setAttribute("member", member);
		request.setAttribute("unpaidCount", new PaymentDAO().countPending(member.getId()));

		// ---- 3. 주소에 따라 실행할 Command 와 보여줄 JSP 결정 ----
		String pathInfo = request.getPathInfo();   // /mypage 는 null, /mypage/ 는 "/"
		if (pathInfo == null) {
			pathInfo = "/";
		}

		Command command = null;   // 실행할 기능
		String page = null;       // 보여줄 JSP (없으면 null)

		switch (pathInfo) {

		case "/":
			command = new MyPageMain();
			page = VIEW + "mypage.jsp";
			break;

		case "/account":
			command = new AccountCommand();
			page = VIEW + "account.jsp";
			break;

		case "/account/withdraw":
			command = new WithdrawCommand();
			page = null;            // 탈퇴 후 redirect 로 끝난다
			break;

		case "/address":
			command = new AddressCommand();
			page = VIEW + "address.jsp";
			break;

		case "/deposit":
			command = new DepositCharge();
			page = VIEW + "deposit.jsp";
			break;

		case "/payment":
			command = new PaymentCommand();
			page = VIEW + "payment.jsp";
			break;

		case "/payment/charge-deposit":
			command = new ChargeDepositCommand();
			page = null;            // 충전 후 redirect 로 끝난다
			break;

		default:
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		// ---- 4. 실제 일은 Command 가 한다 ----
		boolean needForward = command.doCommand(request, response);

		if (needForward && page != null) {
			request.getRequestDispatcher(page).forward(request, response);
		}
	}
}
