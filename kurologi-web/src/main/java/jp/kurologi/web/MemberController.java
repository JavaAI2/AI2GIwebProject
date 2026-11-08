package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.service.Command;
import jp.kurologi.service.IdCheckCommand;
import jp.kurologi.service.LoginCommand;
import jp.kurologi.service.LogoutCommand;
import jp.kurologi.service.MemberInsert;

/**
 * 회원 컨트롤러 (blogProject2 의 Membercontroller 와 같은 구조)
 *
 * /member/* 로 들어오는 모든 요청을 이 클래스가 받는다.
 *
 *   /member/join     회원가입 폼(GET) / 가입 처리(POST)
 *   /member/idCheck  아이디 중복확인(Ajax, JSON 응답)
 *   /member/login    로그인 폼(GET) / 로그인 처리(POST)
 *   /member/logout   로그아웃
 *
 * 흐름 : 컨트롤러(주소 판단) -> Command(서비스, 실제 처리) -> DAO(DB)
 *        Command 가 true 를 돌려주면 JSP 로 forward(화면 보여주기),
 *        false 면 Command 가 이미 redirect / JSON 으로 응답을 끝낸 것이라 아무것도 안 한다.
 *
 * (아이디/비밀번호 찾기는 같은 방식의 MemberFindController 가 /member/find/* 를 따로 맡는다)
 */
@WebServlet("/member/*")
public class MemberController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	// JSP 위치는 여기 한 곳에서만 바꾸면 된다
	// (WEB-INF 안에 두면 주소창으로 JSP 에 직접 들어올 수 없고, 반드시 컨트롤러를 거치게 된다)
	private static final String JOIN_PAGE  = "/WEB-INF/views/join/join.jsp";
	private static final String LOGIN_PAGE = "/WEB-INF/views/join/login.jsp";

	public MemberController() {
		super();
	}

	// GET, POST 어느 쪽으로 들어와도 doAction 하나로 모은다
	// (GET/POST 구분은 각 Command 안에서 request.getMethod() 로 한다)
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

		// 파라미터를 읽기 전에 먼저 지정해야 한글이 깨지지 않는다
		request.setCharacterEncoding("UTF-8");

		String pathInfo = request.getPathInfo();   // 주소가 /member/join 이면 "/join"
		System.out.println("pathInfo : " + pathInfo);

		// /member 또는 /member/ 로만 들어오면 로그인 화면으로 보낸다
		if (pathInfo == null || "/".equals(pathInfo)) {
			response.sendRedirect(request.getContextPath() + "/member/login");
			return;
		}

		Command command = null;   // 어떤 기능을 실행할지 (다형성: 모두 Command 로 다룬다)
		String page = null;       // 작업이 끝난 뒤 보여줄 JSP (없으면 null)

		switch (pathInfo) {

		case "/join":
			command = new MemberInsert();
			page = JOIN_PAGE;
			break;

		case "/idCheck":
			command = new IdCheckCommand();
			page = null;            // Ajax 라서 이동할 화면이 없다
			break;

		case "/login":
			command = new LoginCommand();
			page = LOGIN_PAGE;
			break;

		case "/logout":
			command = new LogoutCommand();
			page = null;            // 로그아웃 후 redirect 로 끝난다
			break;

		default:
			// 없는 주소면 command 가 null 이라 NullPointerException 이 나므로 404 로 처리
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		// 실제 일은 Command 가 한다
		boolean needForward = command.doCommand(request, response);

		// true 이고 보여줄 JSP 가 있으면 그 JSP 로 forward
		if (needForward && page != null) {
			RequestDispatcher rd = request.getRequestDispatcher(page);
			rd.forward(request, response);
		}
	}
}
