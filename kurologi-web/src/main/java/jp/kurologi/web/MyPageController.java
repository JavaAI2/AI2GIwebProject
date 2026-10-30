package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.service.Command;
import jp.kurologi.service.DepositCharge;
import jp.kurologi.service.MyPageMain;

/**
 * 마이페이지 컨트롤러 (BoardController 와 같은 doAction 방식)
 *
 *   /mypage          마이페이지 첫 화면
 *   /mypage/deposit  예치금 충전 (시연용)
 *
 * 흐름 : 컨트롤러(주소 판단) -> Command(서비스, 실제 처리) -> JSP
 *        Command 가 true 를 돌려주면 page 로 forward, false 면 이미 redirect 등으로 응답을 끝낸 것
 *
 * ※ /mypage/account, /mypage/payment, /mypage/address 는 지금 따로 있는 서블릿
 *   (AccountServlet, PaymentServlet, AddressServlet)이 먼저 받는다. (정확히 같은 주소가 더 우선하기 때문)
 *   나중에 이쪽으로 옮기고 싶으면 아래 switch 에 case 를 추가하고 그 서블릿을 지우면 된다.
 *
 * ※ 이 파일을 넣으면 기존 MyPageServlet.java 는 지워야 한다 (주소 "/mypage" 가 겹쳐서 서버가 안 뜬다)
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

		String pathInfo = request.getPathInfo();   // /mypage 는 null, /mypage/ 는 "/"
		if (pathInfo == null) {
			pathInfo = "/";
		}

		Command command = null;
		String page = null;

		switch (pathInfo) {

		case "/":
			// 마이페이지 첫 화면: 나의 정보 · 사서함 주소 · 관리 메뉴
			command = new MyPageMain();
			page = VIEW + "mypage.jsp";
			break;

		case "/deposit":
			// 예치금 충전 (시연용): GET 은 화면, POST 는 충전 처리
			command = new DepositCharge();
			page = VIEW + "deposit.jsp";
			break;

		// ---- 새 화면을 만들 때는 이렇게 추가한다 ----
		// case "/orders":
		//     command = new MyOrders();            // service 폴더에 Command 를 구현한 클래스
		//     page = VIEW + "orders.jsp";
		//     break;

		default:
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		boolean needForward = command.doCommand(request, response);

		if (needForward && page != null) {
			request.getRequestDispatcher(page).forward(request, response);
		}
	}
}
