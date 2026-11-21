package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.model.BuyOrderItemDTO;
import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.web.Session;

/**
 * 주문서 입력 화면 (GET /buyorder/form)
 *   id 없음 : 새 주문서
 *   id 있음 : 접수대기 주문 수정 (저장된 값이 채워진 상태로 열린다)
 *   copy 있음 : 이전 주문의 내용을 복사해서 새 주문서로 연다 (오더내역복사)
 */
public class BuyOrderForm implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String ctx = request.getContextPath();
		String svc = ServiceType.of(request);
		String idParam = request.getParameter("id");

		// ---- 오더내역복사 : 이전 주문(내 주문)의 내용을 새 주문서에 채운다 ----
		String copyParam = request.getParameter("copy");
		if (copyParam != null && !copyParam.trim().isEmpty() && (idParam == null || idParam.trim().isEmpty())) {
			Long memberId = Session.memberId(request);
			if (memberId == null) {
				Session.flash(request, "error", "로그인 후 이용할 수 있습니다.");
				response.sendRedirect(ctx + "/member/login");
				return false;
			}
			long copyId = 0;
			try {
				copyId = Long.parseLong(copyParam.trim());
			} catch (NumberFormatException e) {
				copyId = 0;
			}
			BuyOrderDTO src = (copyId > 0) ? new BuyOrderDAO().findById(copyId) : null;
			if (src == null || src.getMemberId() != memberId.longValue()) {
				Session.flash(request, "error", "복사할 주문을 찾을 수 없습니다.");
				response.sendRedirect(ctx + ServiceType.base(svc) + "/form");
				return false;
			}
			request.setAttribute("formOrder", copyOf(src));
			Session.flash(request, "info", "주문 " + src.getOrderNo() + " 의 내용을 복사했습니다. 트래킹번호와 쇼핑몰 주문번호는 새로 입력해 주세요.");
			return true;
		}

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
			response.sendRedirect(ctx + ServiceType.base(svc) + "/list");
			return false;
		}
		if (!"WAIT".equals(order.getStatus())) {
			Session.flash(request, "error", "접수신청된 주문은 수정할 수 없습니다.");
			response.sendRedirect(ctx + ServiceType.base(ServiceType.normalize(order.getServiceType())) + "/view?id=" + id);
			return false;
		}
		if (!svc.equals(ServiceType.normalize(order.getServiceType()))) {   // 서비스가 다른 주소로 열었으면 맞는 주소로
			response.sendRedirect(ctx + ServiceType.base(ServiceType.normalize(order.getServiceType())) + "/form?id=" + id);
			return false;
		}

		request.setAttribute("formOrder", order);   // 화면이 이 값으로 입력칸을 채운다
		return true;
	}

	/**
	 * 이전 주문을 "새 주문" 으로 쓰기 위해 복사한다.
	 * 주문번호 · 상태 · 환율 같은 값은 새로 만들어지므로 옮기지 않고(orderId = 0 이면 화면이 새 주문서로 인식),
	 * 주문마다 달라지는 트래킹번호 · 쇼핑몰 주문번호 · 오픈마켓 주문번호는 비운다.
	 */
	private BuyOrderDTO copyOf(BuyOrderDTO src) {
		BuyOrderDTO c = new BuyOrderDTO();
		c.setRecvNameKo(src.getRecvNameKo());
		c.setRecvNameEn(src.getRecvNameEn());
		c.setPostcode(src.getPostcode());
		c.setAddr1(src.getAddr1());
		c.setAddr2(src.getAddr2());
		c.setBizNo(src.getBizNo());
		c.setMobile(src.getMobile());
		c.setDeliverNote(src.getDeliverNote());
		c.setAddonOptions(src.getAddonOptions());
		c.setLogisticsNote(src.getLogisticsNote());
		c.setAutoPay(src.isAutoPay());
		for (BuyOrderItemDTO s : src.getItems()) {
			BuyOrderItemDTO it = new BuyOrderItemDTO();
			it.setItemNo(s.getItemNo());
			it.setShopSite(s.getShopSite());
			it.setBrand(s.getBrand());
			it.setItemNameEn(s.getItemNameEn());
			it.setNameEnDirect(s.isNameEnDirect());
			it.setQty(s.getQty());
			it.setUnitPrice(s.getUnitPrice());
			it.setColor(s.getColor());
			it.setItemSize(s.getItemSize());
			it.setProductUrl(s.getProductUrl());
			it.setImageUrl(s.getImageUrl());
			it.setMarketName(s.getMarketName());
			it.setMarketPrice(s.getMarketPrice());
			it.setHsCode(s.getHsCode());
			it.setMarketPay(s.getMarketPay());
			c.getItems().add(it);
		}
		return c;
	}
}
