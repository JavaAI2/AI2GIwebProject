package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.repository.AdminDAO;
import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.web.Session;

/** 주문 상세 (GET /buyorder/view?id=3) — 내 주문만 볼 수 있다 */
public class BuyOrderView implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String ctx = request.getContextPath();

		Long memberId = Session.memberId(request);
		if (memberId == null) {
			Session.flash(request, "error", "로그인 후 이용할 수 있습니다.");
			response.sendRedirect(ctx + "/member/login");
			return false;
		}

		long id = 0;
		try {
			id = Long.parseLong(request.getParameter("id"));
		} catch (NumberFormatException e) {
			id = 0;
		}

		BuyOrderDTO order = (id > 0) ? new BuyOrderDAO().findById(id) : null;

		// 없는 주문이거나 남의 주문이면 똑같이 "없다"고 알려 준다 (남의 주문 번호를 추측하지 못하게)
		if (order == null || order.getMemberId() != memberId.longValue()) {
			Session.flash(request, "error", "존재하지 않는 주문입니다.");
			response.sendRedirect(ctx + ServiceType.base(ServiceType.of(request)) + "/list");
			return false;
		}

		// 배송대행 주문을 구매대행 주소로 열었으면(또는 반대) 맞는 주소로 보낸다
		String svc = ServiceType.normalize(order.getServiceType());
		if (!svc.equals(ServiceType.of(request))) {
			response.sendRedirect(ctx + ServiceType.base(svc) + "/view?id=" + id);
			return false;
		}

		request.setAttribute("svc", svc);
		request.setAttribute("order", order);
		// 관리자 계정이면 화면에 [테스트용 상태 변경] 버튼을 보여 준다 (처리 자체는 AdminFilter 가 다시 확인한다)
		request.setAttribute("isAdmin", new AdminDAO().isAdmin(memberId));
		return true;   // order_view.jsp 로 forward
	}
}