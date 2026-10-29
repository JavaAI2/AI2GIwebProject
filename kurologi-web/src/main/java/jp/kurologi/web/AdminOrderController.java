package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.service.AdminOrderAction;
import jp.kurologi.service.AdminOrderList;
import jp.kurologi.service.Command;

/**
 * 관리자용 주문 관리 컨트롤러 (/admin/orders/*)
 * 관리자만 들어올 수 있게 AdminFilter 가 앞에서 막아 준다. (AdminCommunityController 와 같은 방식)
 *
 *   /admin/orders          구매대행 · 배송대행 주문 목록 (서비스 · 상태 필터)  -> AdminOrderList -> admin/orders.jsp
 *   /admin/orders/action   입고 · 결제 확인 · 출고 처리 (POST)               -> AdminOrderAction
 */
@WebServlet(urlPatterns = { "/admin/orders/*" })
public class AdminOrderController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private static final String VIEWS = "/WEB-INF/views/admin/";

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

		String pathInfo = request.getPathInfo();
		String key = (pathInfo == null || "/".equals(pathInfo)) ? "" : pathInfo;

		Command command = null;
		String page = null;
		boolean postOnly = false;

		switch (key) {
		case "":
			command = new AdminOrderList();
			page = "orders.jsp";
			break;
		case "/action":
			command = new AdminOrderAction();
			postOnly = true;   // 상태를 바꾸는 동작은 POST 로만 (주소창에 입력해서 처리되지 않게)
			break;
		default:
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		if (postOnly && !"POST".equalsIgnoreCase(request.getMethod())) {
			response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
			return;
		}

		boolean needForward = command.doCommand(request, response);

		if (needForward && page != null) {
			attachMember(request);
			RequestDispatcher rd = request.getRequestDispatcher(VIEWS + page);
			rd.forward(request, response);
		}
	}

	/** 공통 헤더(layout.jsp)가 "OOO님 환영합니다"를 찍을 수 있게 로그인한 회원을 request 의 "member" 로 넣는다 */
	private void attachMember(HttpServletRequest request) {
		Long memberId = Session.memberId(request);
		if (memberId != null) {
			App.of(getServletContext()).members.findById(memberId)
					.ifPresent(m -> request.setAttribute("member", m));
		}
	}
}
