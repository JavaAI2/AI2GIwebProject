package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.service.Command;
import jp.kurologi.service.FindIdCommand;
import jp.kurologi.service.FindPwCommand;
import jp.kurologi.service.ResetPwCommand;

/**
 * 아이디 / 비밀번호 찾기 컨트롤러
 *
 *   /member/find/id       아이디 찾기 폼(GET) / 찾기 처리(POST)
 *   /member/find/pw       비밀번호 찾기 1단계 본인 확인 폼(GET) / 확인 처리(POST)
 *   /member/find/pwReset  비밀번호 찾기 2단계 새 비밀번호 저장(POST)
 *
 * 주소가 "/member/find/*" 로 더 길어서, 기존 MemberController("/member/*")보다 먼저 이 서블릿이 받는다.
 * 그래서 기존 MemberController 는 한 줄도 고치지 않아도 된다.
 */
@WebServlet("/member/find/*")
public class MemberFindController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	// JSP 위치 (WEB-INF/views/join 폴더: login.jsp, join.jsp 와 같은 곳)
	private static final String FIND_ID_PAGE = "/WEB-INF/views/join/find_id.jsp";
	private static final String FIND_PW_PAGE = "/WEB-INF/views/join/find_pw.jsp";

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

		String pathInfo = request.getPathInfo();   // /member/find/id 이면 "/id"

		if (pathInfo == null || "/".equals(pathInfo)) {
			response.sendRedirect(request.getContextPath() + "/member/find/id");
			return;
		}

		Command command = null;
		String page = null;

		switch (pathInfo) {

		case "/id":
			command = new FindIdCommand();
			page = FIND_ID_PAGE;
			break;

		case "/pw":
			command = new FindPwCommand();
			page = FIND_PW_PAGE;
			break;

		case "/pwReset":
			command = new ResetPwCommand();
			page = FIND_PW_PAGE;
			break;

		default:
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		boolean needForward = command.doCommand(request, response);

		if (needForward && page != null) {
			RequestDispatcher rd = request.getRequestDispatcher(page);
			rd.forward(request, response);
		}
	}
}
