package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.web.Session;

/** 내 구매대행 주문 목록 (GET /buyorder/list?page=1) — 한 페이지에 10건 */
public class BuyOrderList implements Command {

	private static final int PAGE_SIZE = 10;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		Long memberId = Session.memberId(request);
		if (memberId == null) {
			Session.flash(request, "error", "로그인 후 이용할 수 있습니다.");
			response.sendRedirect(request.getContextPath() + "/member/login");
			return false;
		}

		BuyOrderDAO dao = new BuyOrderDAO();
		String svc = ServiceType.of(request);   // 구매대행 / 배송대행 중 요청한 쪽의 주문만 보여 준다

		int totalCount = dao.countByMember(memberId, svc);
		int totalPages = Math.max(1, (totalCount + PAGE_SIZE - 1) / PAGE_SIZE);

		int page = 1;
		try {
			page = Integer.parseInt(request.getParameter("page"));
		} catch (NumberFormatException e) {
			page = 1;
		}
		page = Math.max(1, Math.min(page, totalPages));   // 범위를 벗어나면 맞춰 준다

		List<BuyOrderDTO> orders = dao.listByMember(memberId, svc, page, PAGE_SIZE);

		request.setAttribute("svc", svc);
		request.setAttribute("orders", orders);
		request.setAttribute("page", page);
		request.setAttribute("totalPages", totalPages);
		request.setAttribute("totalCount", totalCount);
		return true;   // order_list.jsp 로 forward
	}
}
