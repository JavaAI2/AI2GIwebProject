package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.StockDAO;
import jp.kurologi.web.Session;

/** 재고구매신청 화면 (GET /stock/form) — 내 재고 목록과 신청 내역을 담아 stock_order.jsp 로 보낸다 */
public class StockForm implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		Long memberId = Session.memberId(request);
		if (memberId == null) {
			Session.flash(request, "error", "로그인 후 이용할 수 있습니다.");
			response.sendRedirect(request.getContextPath() + "/member/login");
			return false;
		}

		StockDAO dao = new StockDAO();
		request.setAttribute("stockItems", dao.listItems(memberId));
		request.setAttribute("stockOrders", dao.listOrders(memberId));
		return true;
	}
}
