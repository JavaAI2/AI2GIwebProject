package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.web.Session;

/** 접수대기 주문 삭제 (POST /buyorder/delete) — 내 주문 + 접수대기 상태만 삭제된다 */
public class BuyOrderDelete implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String ctx = request.getContextPath();
		String base = ServiceType.base(ServiceType.of(request));   // 삭제 뒤 돌아갈 목록 주소

		Long memberId = Session.memberId(request);
		if (memberId == null) {
			Session.flash(request, "error", "로그인 후 이용할 수 있습니다.");
			response.sendRedirect(ctx + "/member/login");
			return false;
		}

		if (!"POST".equalsIgnoreCase(request.getMethod())) {
			response.sendRedirect(ctx + base + "/list");
			return false;
		}

		long id = 0;
		try {
			id = Long.parseLong(request.getParameter("id"));
		} catch (NumberFormatException e) {
			id = 0;
		}

		// 내 주문 + 접수대기일 때만 지워지도록 SQL 의 WHERE 에서 한 번 더 확인한다
		if (id > 0 && new BuyOrderDAO().delete(id, memberId)) {
			Session.flash(request, "info", "주문을 삭제했습니다.");
		} else {
			Session.flash(request, "error", "삭제할 수 없는 주문입니다. (접수신청된 주문은 삭제할 수 없습니다)");
		}
		response.sendRedirect(ctx + base + "/list");
		return false;
	}
}
