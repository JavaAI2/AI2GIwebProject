package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 주문 1건의 배송 추적 (GET /admin/orders/track?id=주문고유번호) — JSON 으로 돌려준다.
 * 관리자 확인은 AdminFilter 가 이미 했다. 화면(admin/orders.jsp)이 열려 있는 동안 주기적으로 다시 부른다.
 */
public class AdminOrderTrack implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=UTF-8");
		response.setHeader("Cache-Control", "no-store");

		long id = 0;
		try {
			id = Long.parseLong(request.getParameter("id"));
		} catch (NumberFormatException e) {
			id = 0;
		}

		String json = null;
		if (id > 0) {
			try {
				json = OrderTracker.toJson(id, request.getContextPath());
			} catch (RuntimeException e) {
				e.printStackTrace();
				response.getWriter().print("{\"ok\":false,\"message\":\"배송 정보를 읽지 못했습니다. 잠시 후 다시 시도해 주세요.\"}");
				return false;
			}
		}

		if (json == null) {
			response.getWriter().print("{\"ok\":false,\"message\":\"없는 주문입니다.\"}");
		} else {
			response.getWriter().print(json);
		}
		return false;   // 화면 이동 없음
	}
}