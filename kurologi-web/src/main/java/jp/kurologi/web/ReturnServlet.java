package jp.kurologi.web;

import java.io.IOException;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.Member;
import jp.kurologi.repository.RefundDAO.RefundResult;
import jp.kurologi.repository.RefundDAO.ShippingOrder;
import jp.kurologi.service.OrderStatus;
import jp.kurologi.service.ServiceType;

/**
 * 현지 반품신청 (종합현황의 "현지 반품신청" 버튼이 fetch 로 부른다). 결과는 JSON.
 *   GET  /status/return          지금 배송 중인 내 주문 목록 + 보유 예치금
 *   POST /status/return/cancel   고른 주문(id 여러 개)의 배송을 취소하고, 결제한 금액을 예치금으로 환불
 *
 * 로그인하지 않았으면 { "ok": false, "message": ... } 로 알려 준다.
 * (AuthFilter 가 이 주소를 로그인 페이지로 보내 버리면, /status/return 도 보호 대상에 포함되어 있는지 확인하세요)
 */
@WebServlet({ "/status/return", "/status/return/cancel" })
public class ReturnServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/** 한 번에 취소할 수 있는 주문 수 */
	private static final int MAX_CANCEL = 20;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		prepare(req, res);

		Long memberId = Session.memberId(req);
		if (memberId == null) {
			fail(res, "로그인 후 이용할 수 있습니다.");
			return;
		}

		App app = App.of(getServletContext());
		List<ShippingOrder> orders = app.payments.shippingOrders(memberId);
		long deposit = app.members.findById(memberId).map(Member::getDeposit).orElse(0L);

		StringBuilder sb = new StringBuilder("{\"ok\":true,\"deposit\":").append(deposit).append(",\"items\":[");
		for (int i = 0; i < orders.size(); i++) {
			ShippingOrder o = orders.get(i);
			String summary = (o.firstItem() == null ? "" : o.firstItem())
					+ (o.itemCount() > 1 ? " 외 " + (o.itemCount() - 1) + "건" : "");
			if (i > 0) sb.append(',');
			sb.append("{\"id\":").append(o.orderId())
					.append(",\"orderNo\":").append(q(o.orderNo()))
					.append(",\"service\":").append(q(ServiceType.label(ServiceType.normalize(o.serviceType()))))
					.append(",\"status\":").append(q(OrderStatus.label(o.status())))
					.append(",\"summary\":").append(q(summary))
					.append(",\"amount\":").append(o.paidAmount())
					.append('}');
		}
		sb.append("]}");
		res.getWriter().print(sb);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		prepare(req, res);

		if (!req.getServletPath().endsWith("/cancel")) {
			fail(res, "잘못된 요청입니다.");
			return;
		}

		Long memberId = Session.memberId(req);
		if (memberId == null) {
			fail(res, "로그인 후 이용할 수 있습니다.");
			return;
		}

		// 고른 주문 번호들 (숫자가 아니거나 너무 많으면 무시)
		Set<Long> ids = new LinkedHashSet<>();
		String[] raw = req.getParameterValues("id");
		if (raw != null) {
			for (String s : raw) {
				try {
					long id = Long.parseLong(s.trim());
					if (id > 0 && ids.size() < MAX_CANCEL) ids.add(id);
				} catch (NumberFormatException e) {
					// 숫자가 아닌 값은 무시한다
				}
			}
		}
		if (ids.isEmpty()) {
			fail(res, "취소할 물품을 선택해 주세요.");
			return;
		}

		App app = App.of(getServletContext());

		int done = 0;
		long refunded = 0;
		StringBuilder failures = new StringBuilder();
		for (Long id : ids) {
			RefundResult r = app.payments.refundShipping(memberId, id);
			if (r.ok()) {
				done++;
				refunded += r.refunded();
			} else {
				if (failures.length() > 0) failures.append(" / ");
				failures.append(r.message());
			}
		}

		long deposit = app.members.findById(memberId).map(Member::getDeposit).orElse(0L);

		StringBuilder msg = new StringBuilder();
		if (done > 0) {
			msg.append(done).append("건의 배송을 취소했습니다. ")
					.append(String.format("환불 ₩%,d 이(가) 예치금으로 돌아갔습니다. (현재 예치금 ₩%,d)", refunded, deposit));
		}
		if (failures.length() > 0) {
			if (msg.length() > 0) msg.append("\n");
			msg.append("취소하지 못한 주문 : ").append(failures);
		}

		res.getWriter().print("{\"ok\":" + (done > 0) + ",\"count\":" + done + ",\"refunded\":" + refunded
				+ ",\"deposit\":" + deposit + ",\"message\":" + q(msg.toString()) + "}");
	}

	private static void prepare(HttpServletRequest req, HttpServletResponse res) throws IOException {
		req.setCharacterEncoding("UTF-8");
		res.setContentType("application/json; charset=UTF-8");
		res.setHeader("Cache-Control", "no-store");
	}

	private static void fail(HttpServletResponse res, String message) throws IOException {
		res.getWriter().print("{\"ok\":false,\"message\":" + q(message) + "}");
	}

	/** JSON 문자열로 만든다 (따옴표 · 역슬래시 · 제어문자 이스케이프) */
	private static String q(String s) {
		if (s == null) return "\"\"";
		StringBuilder sb = new StringBuilder("\"");
		for (int i = 0; i < s.length(); i++) {
			char c = s.charAt(i);
			switch (c) {
			case '"':  sb.append("\\\""); break;
			case '\\': sb.append("\\\\"); break;
			case '\n': sb.append("\\n"); break;
			case '\r': sb.append("\\r"); break;
			case '\t': sb.append("\\t"); break;
			default:
				if (c < 0x20) sb.append(String.format("\\u%04x", (int) c));
				else sb.append(c);
			}
		}
		return sb.append('"').toString();
	}
}
