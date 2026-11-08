package jp.kurologi.service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.repository.AdminOrderDAO;
import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.web.Session;

/**
 * 주문 처리 (POST /admin/orders/action)
 *   action : receive 입고 / pay 결제 확인 / ship 출고 / customs 세관 통관 완료(국내 배송 시작) / deliver 배송 완료
 *            delete 선택한 주문(ids 여러 개) 완전 삭제 + 결제금액 예치금 환불 — 회원의 주문내역 · 결제내역에서도 사라진다
 * 처리가 끝나면 회원에게 알림메세지를 보낸다.
 *
 * 관리자 확인은 AdminFilter, 위조 요청 방지는 CsrfFilter 가 앞에서 한다.
 * 처리 뒤에는 보던 목록(서비스 · 상태 필터 · 페이지 유지)으로 돌아간다.
 */
public class AdminOrderAction implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		long id = 0;
		try {
			id = Long.parseLong(request.getParameter("id"));
		} catch (NumberFormatException e) {
			id = 0;
		}

		// 처리 뒤에는 보던 목록으로 돌아간다. 돌아갈 주소는 입력값을 그대로 쓰지 않고 서버에서 다시 만든다.
		String svc = AdminOrderList.whitelist(request.getParameter("svc"), "all", "BUY", "SHIP");
		String st = AdminOrderList.whitelist(request.getParameter("st"), "all", "submit", "received", "billed",
				"shipped", "delivering", "delivered", "unpaid");
		int page = 1;
		try {
			page = Math.max(1, Integer.parseInt(request.getParameter("page")));
		} catch (NumberFormatException e) {
			page = 1;
		}
		String back = request.getContextPath() + "/admin/orders?svc=" + svc + "&st=" + st + "&page=" + page;

		String action = AdminOrderList.whitelist(request.getParameter("action"), "", "receive", "pay", "ship", "customs", "deliver", "delete");

		if ("delete".equals(action)) {
			List<Long> ids = new ArrayList<>();
			String[] raw = request.getParameterValues("ids");
			if (raw != null) {
				for (String s : raw) {
					try {
						long v = Long.parseLong(s);
						if (v > 0 && !ids.contains(v)) {
							ids.add(v);
						}
					} catch (NumberFormatException e) {
						// 숫자가 아닌 값은 건너뛴다
					}
				}
			}
			if (ids.isEmpty()) {
				Session.flash(request, "error", "삭제할 주문을 체크해 주세요.");
			} else {
				AdminOrderDAO.DeleteResult r = new AdminOrderDAO().deleteOrders(ids);
				if (r == null) {
					Session.flash(request, "error", "삭제 중 오류가 발생해 아무것도 지우지 않았습니다. 서버 로그를 확인해 주세요.");
				} else {
					Session.flash(request, "info", "주문 " + r.deleted() + "건을 삭제했습니다. (회원의 주문내역 · 결제내역에서도 사라졌습니다)"
							+ (r.refunded() > 0 ? " 결제금액 " + String.format("%,d", r.refunded()) + "원을 회원 예치금으로 환불했습니다." : " 환불할 결제금액은 없었습니다."));
				}
			}
			response.sendRedirect(back);
			return false;
		}

		AdminOrderDAO dao = new AdminOrderDAO();

		// 알림에 쓸 주문 정보(회원 번호 · 주문번호)를 미리 읽어 둔다
		BuyOrderDTO before = (id > 0 && !action.isEmpty()) ? new BuyOrderDAO().findById(id) : null;

		String name;
		switch (action) {
		case "receive": name = "입고 처리"; break;
		case "pay":     name = "결제 확인"; break;
		case "ship":    name = "출고 처리"; break;
		case "customs": name = "통관 완료 처리"; break;
		case "deliver": name = "배송 완료 처리"; break;
		default:        name = "";
		}

		if (id > 0 && !action.isEmpty() && dao.advance(id, action)) {
			boolean notified = false;
			if ("receive".equals(action)) {
				notified = OrderNotifier.sendStep(before, 2);
			} else if ("pay".equals(action)) {
				notified = OrderNotifier.sendPaid(before);
			} else if ("ship".equals(action)) {
				notified = OrderNotifier.sendStep(before, 4);
			} else if ("customs".equals(action)) {
				notified = OrderNotifier.sendStep(before, 5);
			} else if ("deliver".equals(action)) {
				notified = OrderNotifier.sendStep(before, 6);
			}
			Session.flash(request, "info", name + "를 완료했습니다." + (notified ? " (알림메세지 발송)" : ""));
		} else if ("ship".equals(action)) {
			Session.flash(request, "error", "출고할 수 없습니다. 입고완료(또는 배송비 대기)이면서 결제완료인 주문만 출고할 수 있습니다.");
		} else if ("customs".equals(action)) {
			Session.flash(request, "error", "통관 완료 처리를 할 수 없습니다. 출고완료 상태인 주문만 처리할 수 있습니다.");
		} else if ("deliver".equals(action)) {
			Session.flash(request, "error", "배송 완료 처리를 할 수 없습니다. 국내 배송 중인 주문만 처리할 수 있습니다.");
		} else {
			Session.flash(request, "error", "이미 처리되었거나 처리할 수 없는 주문입니다. 목록을 새로고침해서 확인해 주세요.");
		}
		response.sendRedirect(back);
		return false;
	}
}