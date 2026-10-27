package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.service.Command;
import jp.kurologi.service.StockAdd;
import jp.kurologi.service.StockApply;
import jp.kurologi.service.StockForm;

/**
 * /stock/* 로 들어오는 재고 · 재고구매신청 요청을 받는 컨트롤러
 *
 *   /stock/form    재고 목록 + 신청 화면 (GET)  -> StockForm  -> stock_order.jsp
 *   /stock/add     재고 상품 등록 (POST)        -> StockAdd   (redirect)
 *   /stock/apply   재고구매신청 (POST)          -> StockApply (redirect)
 */
@WebServlet("/stock/*")
public class StockController extends HttpServlet {
	private static final long serialVersionUID = 1L;

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
		if (pathInfo == null) {
			pathInfo = "";
		}

		Command command = null;
		String page = null;

		switch (pathInfo) {

		case "/form":
			command = new StockForm();
			page = "/WEB-INF/views/buy/stock_order.jsp";
			break;

		case "/add":
			command = new StockAdd();
			break;

		case "/apply":
			command = new StockApply();
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
