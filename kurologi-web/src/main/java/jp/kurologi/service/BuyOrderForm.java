package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.web.Session;

/**
 * 주문서 입력 화면 (GET /buyorder/form)
 *   id 없음 : 새 주문서
 *   id 있음 : 접수대기 주문 수정 (저장된 값이 채워진 상태로 열린다)
 */
public class BuyOrderForm implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String ctx = request.getContextPath();
		String idParam = request.getParameter("id");

		if (idParam == null || idParam.trim().isEmpty()) {
			return true;   // 새 주문서 : 빈 화면
		}

		Long memberId = Session.memberId(request);
		if (memberId == null) {
			Session.flash(request, "error", "로그인 후 이용할 수 있습니다.");
			response.sendRedirect(ctx + "/member/login");
			return false;
		}

		long id = 0;
		try {
			id = Long.parseLong(idParam.trim());
		} catch (NumberFormatException e) {
			id = 0;
		}

		BuyOrderDTO order = (id > 0) ? new BuyOrderDAO().findById(id) : null;
		if (order == null || order.getMemberId() != memberId.longValue()) {
			Session.flash(request, "error", "존재하지 않는 주문입니다.");
			response.sendRedirect(ctx + "/buyorder/list");
			return false;
		}
		if (!"WAIT".equals(order.getStatus())) {
			Session.flash(request, "error", "접수신청된 주문은 수정할 수 없습니다.");
			response.sendRedirect(ctx + "/buyorder/view?id=" + id);
			return false;
		}

		request.setAttribute("formOrder", order);   // 화면이 이 값으로 입력칸을 채운다
		return true;
	}
}
