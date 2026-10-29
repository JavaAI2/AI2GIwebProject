package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.AdminOrderDAO;
import jp.kurologi.web.Session;

/** 주문 처리 (POST /admin/orders/action) — action : receive 입고 / pay 결제 확인 / ship 출고 */
public class AdminOrderAction implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// 처리 뒤에는 보던 목록(서비스 · 상태 필터, 페이지)으로 돌아간다. 값은 모두 허용 목록/숫자로 다시 만든다.
		String svc = AdminOrderList.whitelist(request.getParameter("svc"), "all", "BUY", "SHIP");
		String st = AdminOrderList.whitelist(request.getParameter("st"), "all", "submit", "received", "shipped", "unpaid");
		int page = 1;
		try {
			page = Math.max(1, Integer.parseInt(request.getParameter("page")));
		} catch (NumberFormatException e) {
			page = 1;
		}
		String back = request.getContextPath() + "/admin/orders?svc=" + svc + "&st=" + st + "&page=" + page;

		long id = 0;
		try {
			id = Long.parseLong(request.getParameter("id"));
		} catch (NumberFormatException e) {
			id = 0;
		}
		String action = AdminOrderList.whitelist(request.getParameter("action"), "", "receive", "pay", "ship");

		String name;
		switch (action) {
		case "receive": name = "입고 처리"; break;
		case "pay":     name = "결제 확인"; break;
		case "ship":    name = "출고 처리"; break;
		default:        name = "";
		}

		if (id > 0 && !action.isEmpty() && new AdminOrderDAO().advance(id, action)) {
			Session.flash(request, "info", name + "를 완료했습니다.");
		} else if ("ship".equals(action)) {
			Session.flash(request, "error", "출고할 수 없습니다. 입고완료이면서 결제완료인 주문만 출고할 수 있습니다.");
		} else {
			Session.flash(request, "error", "이미 처리되었거나 처리할 수 없는 주문입니다. 목록을 새로고침해서 확인해 주세요.");
		}
		response.sendRedirect(back);
		return false;
	}
}
