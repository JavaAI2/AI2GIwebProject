package jp.kurologi.service;

import java.io.IOException;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.StockOrderDTO;
import jp.kurologi.repository.StockDAO;
import jp.kurologi.web.Session;

/** 재고구매신청 (POST /stock/apply) — 선택한 재고를 받는 사람 · 주소 · 수량과 함께 신청한다 */
public class StockApply implements Command {

	private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9\\-+() ]{7,30}$");

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String back = request.getContextPath() + "/stock/form";

		Long memberId = Session.memberId(request);
		if (memberId == null) {
			Session.flash(request, "error", "로그인 후 이용할 수 있습니다.");
			response.sendRedirect(request.getContextPath() + "/member/login");
			return false;
		}
		if (!"POST".equalsIgnoreCase(request.getMethod())) {
			response.sendRedirect(back);
			return false;
		}

		StockOrderDTO order = new StockOrderDTO();
		order.setMemberId(memberId);
		order.setStockId(toLong(param(request, "stockId")));
		order.setRecvName(param(request, "recvName"));
		order.setMobile(param(request, "mobile"));
		order.setPostcode(param(request, "postcode"));
		order.setAddr1(param(request, "addr1"));
		order.setAddr2(param(request, "addr2"));
		order.setDeliverNote(param(request, "deliverNote"));
		long qty = toLong(param(request, "qty"));

		String error = null;
		if (order.getStockId() <= 0) {
			error = "신청할 재고 상품을 선택해 주세요.";
		} else if (qty < 1 || qty > 9999999) {
			error = "신청 수량은 1 이상의 숫자로 입력해 주세요.";
		} else if (order.getRecvName().isEmpty() || order.getRecvName().length() > 60) {
			error = "받는 사람을 60자 이내로 입력해 주세요.";
		} else if (!PHONE_PATTERN.matcher(order.getMobile()).matches()) {
			error = "휴대전화 번호를 확인해 주세요.";
		} else if (order.getPostcode().isEmpty() || order.getPostcode().length() > 10
				|| order.getAddr1().isEmpty() || order.getAddr1().length() > 200) {
			error = "우편번호와 주소를 입력해 주세요.";
		} else if (order.getAddr2().isEmpty() || order.getAddr2().length() > 200) {
			error = "상세주소를 입력해 주세요.";
		} else if (order.getDeliverNote().length() > 200) {
			error = "배송 요청사항은 200자 이내로 입력해 주세요.";
		}
		if (error != null) {
			Session.flash(request, "error", error);
			response.sendRedirect(back);
			return false;
		}
		order.setQty((int) qty);

		String result = new StockDAO().apply(order);   // null 이면 성공
		if (result == null) {
			Session.flash(request, "info", "재고구매신청이 접수되었습니다.");
		} else {
			Session.flash(request, "error", result);
		}
		response.sendRedirect(back);
		return false;
	}

	private static String param(HttpServletRequest request, String name) {
		String v = request.getParameter(name);
		return v == null ? "" : v.trim();
	}

	private static long toLong(String s) {
		try {
			return Long.parseLong(s.replace(",", ""));
		} catch (NumberFormatException e) {
			return -1;
		}
	}
}
