package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.Address;
import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.model.BuyOrderItemDTO;
import jp.kurologi.model.Page;
import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.web.App;
import jp.kurologi.web.Session;

/**
 * 주문서 화면의 [주소록] [등록상품 불러오기] [오더내역복사] 팝업에 목록을 JSON 으로 돌려준다. (GET, Ajax)
 *   /buyorder/addresses  내 주소록 (마이페이지 > 주소관리에 저장한 주소)
 *   /buyorder/products   내가 주문했던 상품 (같은 상품은 한 번만)
 *   /buyorder/recent     내 최근 주문 10건
 * 응답 : {"ok":true,"items":[...]}  /  실패 {"ok":false,"message":"..."}
 * 로그인한 회원 본인의 데이터만 돌려준다.
 */
public class BuyOrderLookup implements Command {

	private final String kind;   // "addresses" | "products" | "recent"

	public BuyOrderLookup(String kind) {
		this.kind = kind;
	}

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json;charset=UTF-8");
		response.setHeader("Cache-Control", "no-store");

		Long memberId = Session.memberId(request);
		if (memberId == null) {
			response.setStatus(401);
			response.getWriter().write("{\"ok\":false,\"message\":\"로그인 후 이용할 수 있습니다.\"}");
			return false;
		}

		StringBuilder sb = new StringBuilder("{\"ok\":true,\"items\":[");
		boolean first = true;

		if ("addresses".equals(kind)) {
			App app = App.of(request.getServletContext());
			// 주소는 한 페이지에 8개씩 나뉘어 있으므로 5페이지(40개)까지만 모은다
			for (int page = 1; page <= 5; page++) {
				Page<Address> p = app.addresses.search(memberId, "name", "", page);
				for (Address a : p.getItems()) {
					if (!first) sb.append(',');
					first = false;
					sb.append("{\"name\":").append(Json.q(a.getName()))
					  .append(",\"phone\":").append(Json.q(a.getPhone()))
					  .append(",\"zipcode\":").append(Json.q(a.getZipcode()))
					  .append(",\"address1\":").append(Json.q(a.getAddress1()))
					  .append(",\"address2\":").append(Json.q(a.getAddress2())).append('}');
				}
				if (page >= p.getTotalPages()) break;
			}

		} else if ("products".equals(kind)) {
			List<BuyOrderItemDTO> items = new BuyOrderDAO().recentProducts(memberId, 20);
			for (BuyOrderItemDTO it : items) {
				if (!first) sb.append(',');
				first = false;
				sb.append("{\"name\":").append(Json.q(it.getItemNameEn()))
				  .append(",\"shopSite\":").append(Json.q(it.getShopSite()))
				  .append(",\"brand\":").append(Json.q(it.getBrand()))
				  .append(",\"color\":").append(Json.q(it.getColor()))
				  .append(",\"size\":").append(Json.q(it.getItemSize()))
				  .append(",\"productUrl\":").append(Json.q(it.getProductUrl()))
				  .append(",\"imageUrl\":").append(Json.q(it.getImageUrl()))
				  .append(",\"hsCode\":").append(Json.q(it.getHsCode()))
				  .append(",\"unitPrice\":").append(Json.q(it.getUnitPrice() == null ? "0" : it.getUnitPrice().toPlainString()))
				  .append('}');
			}

		} else {   // recent
			List<BuyOrderDTO> orders = new BuyOrderDAO().recentOrders(memberId, 10);
			for (BuyOrderDTO o : orders) {
				if (!first) sb.append(',');
				first = false;
				String firstName = o.getFirstItemName() == null ? "" : o.getFirstItemName();
				String summary = firstName + (o.getItemCount() > 1 ? " 외 " + (o.getItemCount() - 1) + "건" : "");
				sb.append("{\"id\":").append(o.getOrderId())
				  .append(",\"orderNo\":").append(Json.q(o.getOrderNo()))
				  .append(",\"service\":").append(Json.q(ServiceType.label(o.getServiceType())))
				  .append(",\"status\":").append(Json.q(OrderStatus.label(o.getStatus())))
				  .append(",\"date\":").append(Json.q(o.getCreatedAt()))
				  .append(",\"summary\":").append(Json.q(summary)).append('}');
			}
		}

		sb.append("]}");
		response.getWriter().write(sb.toString());
		return false;
	}
}
