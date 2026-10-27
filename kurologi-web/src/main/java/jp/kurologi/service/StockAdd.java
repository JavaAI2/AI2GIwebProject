package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.StockItemDTO;
import jp.kurologi.repository.StockDAO;
import jp.kurologi.web.Session;

/** 재고 상품 등록 (POST /stock/add) — 상품명 · 옵션 · 수량 · 판매가 */
public class StockAdd implements Command {

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

		String name = param(request, "itemName");
		String option = param(request, "optionName");
		long qty = toLong(param(request, "qty"));
		long price = toLong(param(request, "price"));

		String error = null;
		if (name.isEmpty() || name.length() > 200) {
			error = "상품명을 200자 이내로 입력해 주세요.";
		} else if (option.length() > 100) {
			error = "옵션은 100자 이내로 입력해 주세요.";
		} else if (qty < 1 || qty > 9999999) {
			error = "재고수량은 1 이상의 숫자로 입력해 주세요.";
		} else if (price < 0 || price > 999999999999L) {
			error = "판매가를 숫자로 입력해 주세요.";
		}
		if (error != null) {
			Session.flash(request, "error", error);
			response.sendRedirect(back);
			return false;
		}

		StockItemDTO dto = new StockItemDTO();
		dto.setMemberId(memberId);
		dto.setItemName(name);
		dto.setOptionName(option);
		dto.setQty((int) qty);
		dto.setPrice(price);

		if (new StockDAO().insertItem(dto)) {
			Session.flash(request, "info", "재고 상품을 등록했습니다.");
		} else {
			Session.flash(request, "error", "재고 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
		}
		response.sendRedirect(back);
		return false;
	}

	private static String param(HttpServletRequest request, String name) {
		String v = request.getParameter(name);
		return v == null ? "" : v.trim();
	}

	/** 쉼표를 없애고 숫자로. 숫자가 아니면 -1 */
	private static long toLong(String s) {
		try {
			return Long.parseLong(s.replace(",", ""));
		} catch (NumberFormatException e) {
			return -1;
		}
	}
}
