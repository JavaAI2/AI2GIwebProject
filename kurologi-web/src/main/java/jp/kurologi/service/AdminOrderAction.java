package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.repository.AdminOrderDAO;
import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.web.Session;

/**
 * 주문 처리 (POST /admin/orders/action)
 *   action : receive 입고 / pay 결제 확인 / ship 출고
 *            set     [테스트용] 진행 단계(step 1 ~ 5)를 순서와 상관없이 직접 지정
 * 단계가 앞으로 나아갈 때만 회원에게 알림메세지를 보낸다. (되돌릴 때는 보내지 않는다)
 *
 * 관리자 확인은 AdminFilter, 위조 요청 방지는 CsrfFilter 가 앞에서 한다.
 * 처리 뒤에는 from=view 이면 그 주문의 상세 화면으로, 아니면 보던 목록으로 돌아간다.
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

		// 처리 뒤에는 보던 화면으로 돌아간다. 돌아갈 주소는 입력값을 그대로 쓰지 않고 서버에서 다시 만든다.
		//  - from=view : 주문 상세 (/buyorder/view?id=...). 배송대행 주문이면 상세 화면이 알아서 /shiporder/view 로 보낸다.
		//  - 그 밖     : 서비스 · 상태 필터 · 페이지가 유지된 관리자 목록
		String back;
		if ("view".equals(request.getParameter("from")) && id > 0) {
			back = request.getContextPath() + "/buyorder/view?id=" + id;
		} else {
			String svc = AdminOrderList.whitelist(request.getParameter("svc"), "all", "BUY", "SHIP");
			String st = AdminOrderList.whitelist(request.getParameter("st"), "all", "submit", "received", "billed",
					"shipped", "delivering", "unpaid");
			int page = 1;
			try {
				page = Math.max(1, Integer.parseInt(request.getParameter("page")));
			} catch (NumberFormatException e) {
				page = 1;
			}
			back = request.getContextPath() + "/admin/orders?svc=" + svc + "&st=" + st + "&page=" + page;
		}

		String action = AdminOrderList.whitelist(request.getParameter("action"), "", "receive", "pay", "ship", "set");

		AdminOrderDAO dao = new AdminOrderDAO();

		// 알림에 쓸 주문 정보(회원 번호 · 주문번호)와 바뀌기 전 단계를 미리 읽어 둔다
		BuyOrderDTO before = (id > 0 && !action.isEmpty()) ? new BuyOrderDAO().findById(id) : null;

		if ("set".equals(action)) {
			// [테스트용] 단계 번호(1 ~ 5)를 상태 · 결제 상태로 바꿔서 저장한다
			int step = 0;
			try {
				step = Integer.parseInt(request.getParameter("step"));
			} catch (NumberFormatException e) {
				step = 0;
			}
			String status = OrderStatus.statusOfStep(step);
			String payStatus = OrderStatus.isPaidStep(step) ? "PAID" : "UNPAID";

			if (id > 0 && status != null && dao.setStatus(id, status, payStatus)) {
				boolean notified = false;
				if (before != null && step > OrderStatus.step(before.getStatus())) {
					notified = OrderNotifier.sendStep(before, step);
				}
				Session.flash(request, "info", "[테스트] 0" + step + " " + OrderStatus.stepName(step) + " 단계로 바꿨습니다."
						+ (notified ? " (알림메세지 발송)" : ""));
			} else {
				Session.flash(request, "error", "단계를 바꿀 수 없습니다. 접수대기(신청 전) 주문이거나 없는 주문입니다.");
			}
			response.sendRedirect(back);
			return false;
		}

		String name;
		switch (action) {
		case "receive": name = "입고 처리"; break;
		case "pay":     name = "결제 확인"; break;
		case "ship":    name = "출고 처리"; break;
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
			}
			Session.flash(request, "info", name + "를 완료했습니다." + (notified ? " (알림메세지 발송)" : ""));
		} else if ("ship".equals(action)) {
			Session.flash(request, "error", "출고할 수 없습니다. 입고완료(또는 배송비 대기)이면서 결제완료인 주문만 출고할 수 있습니다.");
		} else {
			Session.flash(request, "error", "이미 처리되었거나 처리할 수 없는 주문입니다. 목록을 새로고침해서 확인해 주세요.");
		}
		response.sendRedirect(back);
		return false;
	}
}