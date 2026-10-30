package jp.kurologi.service;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.model.BuyOrderItemDTO;
import jp.kurologi.repository.AdminOrderDAO;

/**
 * 관리자 주문 목록 (GET /admin/orders?svc=all|BUY|SHIP&st=all|submit|received|billed|shipped|delivering|unpaid&page=1)
 * 관리자 확인은 AdminFilter 가 이미 했다.
 */
public class AdminOrderList implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String svc = whitelist(request.getParameter("svc"), "all", "BUY", "SHIP");
		String st = whitelist(request.getParameter("st"), "all", "submit", "received", "billed", "shipped", "delivering", "unpaid");

		AdminOrderDAO dao = new AdminOrderDAO();

		Map<String, Integer> counts = dao.counts(svc);
		int totalCount = counts.get(st);
		int totalPages = Math.max(1, (totalCount + AdminOrderDAO.PAGE_SIZE - 1) / AdminOrderDAO.PAGE_SIZE);

		int page = 1;
		try {
			page = Integer.parseInt(request.getParameter("page"));
		} catch (NumberFormatException e) {
			page = 1;
		}
		page = Math.max(1, Math.min(page, totalPages));

		List<BuyOrderDTO> orders = dao.list(svc, st, page);
		Map<Long, List<BuyOrderItemDTO>> items = dao.itemsOf(orders);

		request.setAttribute("orders", orders);
		request.setAttribute("itemsByOrder", items);
		request.setAttribute("counts", counts);
		request.setAttribute("svcFilter", svc);
		request.setAttribute("stFilter", st);
		request.setAttribute("page", page);
		request.setAttribute("totalPages", totalPages);
		return true;   // admin/orders.jsp 로 forward
	}

	/** 허용한 값 중 하나가 아니면 첫 번째 값으로 되돌린다 */
	static String whitelist(String value, String... allowed) {
		for (String a : allowed) {
			if (a.equals(value)) {
				return a;
			}
		}
		return allowed[0];
	}
}