package jp.kurologi.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.model.ExchangeRate;
import jp.kurologi.model.BuyOrderItemDTO;
import jp.kurologi.repository.BuyOrderDAO;
import jp.kurologi.web.App;
import jp.kurologi.web.Session;

/**
 * 구매대행 주문서 저장 서비스 (POST /buyorder/save) — 새 주문 저장 + 접수대기 주문 수정을 함께 처리한다.
 *   mode=wait   : 접수대기 — 받는 사람 이름과 상품명만 있으면 저장 (트래킹번호 등은 나중에 입력)
 *   mode=submit : 접수신청 — 주소 · 휴대전화 · 트래킹번호 · 25개 동의를 모두 확인
 *   orderId 가 같이 넘어오면 "수정"이다 (내 주문 + 접수대기 상태일 때만).
 *
 * 검증에 실패하면 입력한 값을 그대로 담아(formOrder) 주문서 화면으로 되돌려 보낸다.
 * (브라우저의 JavaScript 검사는 우회할 수 있으므로 서버에서 다시 검사한다)
 */
public class BuyOrderInsert implements Command {

	private static final int MAX_ITEMS = 20;        // 제품품목수 20건 제한 (동의 3번)
	private static final int AGREE_COUNT = 25;      // 해외배송규정 동의 항목 수
	private static final String CENTER = "위해 / LCL 사업자(월/수/금)";

	private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9\\-+() ]{7,30}$");
	private static final Pattern BIZNO_PATTERN = Pattern.compile("^[0-9]{10}$");

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String ctx = request.getContextPath();
		String svc = ServiceType.of(request);   // BUY 구매대행 / SHIP 배송대행 (같은 코드를 두 서비스가 같이 쓴다)
		String base = ServiceType.base(svc);    // /buyorder 또는 /shiporder

		// 주소창에 직접 들어온 경우(GET)는 주문서 화면으로
		if (!"POST".equalsIgnoreCase(request.getMethod())) {
			response.sendRedirect(ctx + base + "/form");
			return false;
		}

		// 로그인한 회원만 주문할 수 있다
		Long memberId = Session.memberId(request);
		if (memberId == null) {
			Session.flash(request, "error", "로그인 후 주문서를 등록할 수 있습니다.");
			response.sendRedirect(ctx + "/member/login");
			return false;
		}

		boolean submit = "submit".equals(request.getParameter("mode"));
		BuyOrderDAO dao = new BuyOrderDAO();

		// ---- 수정이면 : 내 주문이고 접수대기 상태인지 먼저 확인 ----
		long editId = toLong(param(request, "orderId"));
		BuyOrderDTO existing = null;
		if (editId > 0) {
			existing = dao.findById(editId);
			if (existing == null || existing.getMemberId() != memberId.longValue()
					|| !svc.equals(ServiceType.normalize(existing.getServiceType()))) {
				Session.flash(request, "error", "존재하지 않는 주문입니다.");
				response.sendRedirect(ctx + base + "/list");
				return false;
			}
			if (!"WAIT".equals(existing.getStatus())) {
				Session.flash(request, "error", "접수신청된 주문은 수정할 수 없습니다.");
				response.sendRedirect(ctx + base + "/view?id=" + editId);
				return false;
			}
		}

		// ---- 화면에서 넘어온 값 읽기 (숫자가 이상해도 멈추지 않고 읽은 뒤 아래에서 검사) ----
		String[] parseError = new String[1];
		BuyOrderDTO order = readOrder(request, memberId, submit, parseError);
		order.setServiceType(svc);
		if (existing != null) {
			order.setOrderId(existing.getOrderId());
			order.setOrderNo(existing.getOrderNo());
		}

		String error = (parseError[0] != null) ? parseError[0] : validate(request, order, submit);
		if (error != null) {
			return fail(request, order, error);
		}

		// ---- 오늘의 환율 적용 (구매대행만) ----
		// 구매대행은 상품값도 우리가 대신 결제하므로, 저장하는 시점의 고시환율로 결제 예정 금액(원)을 계산해 함께 저장한다.
		// 배송대행은 고객이 쇼핑몰에 이미 상품값을 냈고 상품 금액은 세관 신고용일 뿐이라 원화 결제 금액을 만들지 않는다.
		// 접수대기 주문을 다시 저장하면 그 날의 환율로 다시 계산되고, 접수신청된 주문은 수정할 수 없어서 그 시점의 환율로 확정된다.
		// 환율 정보가 아직 없으면(DB 에 한 번도 저장된 적이 없음) 원화 금액 없이 저장한다.
		ExchangeRate rate = ExchangeRateService.current();
		if (rate != null && ServiceType.BUY.equals(svc)) {
			order.setAppliedRate(rate.getNoticeRate());
			order.setTotalKrw(rate.toKrw(order.getTotalYen()));
		}

		// ---- DB 저장 ----
		boolean ok;
		if (existing != null) {
			ok = dao.update(order);
		} else {
			long orderId = dao.nextOrderId();
			if (orderId < 0) {
				return fail(request, order, "주문서 저장 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
			}
			order.setOrderId(orderId);
			order.setOrderNo((ServiceType.SHIP.equals(svc) ? "D" : "B") + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE)
					+ "-" + String.format("%05d", orderId));
			ok = dao.insert(order);
		}
		if (!ok) {
			return fail(request, order, "주문서 저장 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
		}

		// 접수신청이면 상품대금(원화)을 마이페이지 > 결제관리 > 비용결제 목록에 결제 대기건으로 올린다.
		// 금액은 위에서 계산한 "접수 시점 고시환율" 기준이라, 이후 환율이 바뀌어도 이 주문의 결제 금액은 변하지 않는다.
		boolean charged = false;
		if (submit && order.getAppliedRate() != null && order.getTotalKrw() > 0) {
			App app = App.of(request.getServletContext());
			if (app != null) {
				String title = ServiceType.label(svc) + " 상품대금 (고시환율 100엔=" + order.getAppliedRate().toPlainString() + "원 적용)";
				app.payments.addCharge(memberId, title, order.getOrderNo(), order.getTotalKrw());
				charged = true;
			}
		}

		Session.flash(request, "info", (submit ? "접수신청" : "접수대기") + "으로 저장했습니다. 주문번호 : " + order.getOrderNo()
				+ (charged ? " (결제 금액 ₩" + String.format("%,d", order.getTotalKrw()) + " 은 마이페이지 > 결제관리에서 결제할 수 있습니다)" : ""));
		response.sendRedirect(ctx + base + "/view?id=" + order.getOrderId());
		return false;
	}

	/** 요청 값을 BuyOrderDTO 로 옮긴다. 숫자 변환에 실패하면 parseError[0] 에 메시지를 남긴다. */
	private BuyOrderDTO readOrder(HttpServletRequest request, long memberId, boolean submit, String[] parseError) {

		BuyOrderDTO order = new BuyOrderDTO();
		order.setMemberId(memberId);
		order.setStatus(submit ? "SUBMIT" : "WAIT");
		order.setCenter(CENTER);
		order.setRecvNameKo(cut(param(request, "recvNameKo"), 60));
		order.setRecvNameEn(cut(param(request, "recvNameEn"), 60));
		order.setPostcode(cut(param(request, "postcode"), 10));
		order.setAddr1(cut(param(request, "addr1"), 200));
		order.setAddr2(cut(param(request, "addr2"), 200));
		order.setBizNo(param(request, "bizNo"));
		order.setMobile(cut(param(request, "mobile"), 30));
		order.setDeliverNote(cut(param(request, "deliverNote"), 200));
		order.setLogisticsNote(cut(param(request, "logisticsNote"), 1000));
		order.setAutoPay("auto".equals(request.getParameter("autoPay")));

		// 부가서비스 체크박스(name="addon")는 체크한 것만 넘어온다 -> 쉼표로 이어서 한 칸에 저장
		String[] addons = request.getParameterValues("addon");
		order.setAddonOptions(addons == null ? null : cut(String.join(",", addons), 1000));

		// 상품 목록 : 같은 name 으로 여러 개가 넘어오므로 getParameterValues
		String[] nameEn = request.getParameterValues("itemNameEn");
		if (nameEn == null) {
			return order;
		}
		String[] shopSite    = request.getParameterValues("itemShopSite");
		String[] brand       = request.getParameterValues("itemBrand");
		String[] shopOrderNo = request.getParameterValues("itemShopOrderNo");
		String[] trackingNo  = request.getParameterValues("itemTrackingNo");
		String[] qty         = request.getParameterValues("itemQty");
		String[] unitPrice   = request.getParameterValues("itemUnitPrice");
		String[] color       = request.getParameterValues("itemColor");
		String[] size        = request.getParameterValues("itemSize");
		String[] productUrl  = request.getParameterValues("itemProductUrl");
		String[] imageUrl    = request.getParameterValues("itemImageUrl");
		String[] marketName  = request.getParameterValues("itemMarketName");
		String[] marketOrder = request.getParameterValues("itemMarketOrderNo");
		String[] marketPrice = request.getParameterValues("itemMarketPrice");
		String[] hsCode      = request.getParameterValues("itemHsCode");
		String[] marketPay   = request.getParameterValues("itemMarketPay");

		// 영문명 직접 기재 체크박스 : 체크한 상품의 순번(0부터)만 넘어온다
		Set<String> directIdx = new HashSet<>();
		String[] direct = request.getParameterValues("itemNameEnDirect");
		if (direct != null) {
			for (String d : direct) {
				directIdx.add(d);
			}
		}

		int count = Math.min(nameEn.length, MAX_ITEMS);
		if (nameEn.length > MAX_ITEMS) {
			parseError[0] = "상품은 최대 " + MAX_ITEMS + "개까지 등록할 수 있습니다.";
		}

		int totalQty = 0;
		BigDecimal totalYen = BigDecimal.ZERO;

		for (int i = 0; i < count; i++) {
			BuyOrderItemDTO item = new BuyOrderItemDTO();
			item.setItemNo(i + 1);
			item.setItemNameEn(cut(at(nameEn, i), 300));
			item.setTrackingNo(cut(at(trackingNo, i), 100));
			item.setShopSite(cut(at(shopSite, i), 200));
			item.setBrand(cut(at(brand, i), 100));
			item.setShopOrderNo(cut(at(shopOrderNo, i), 100));
			item.setNameEnDirect(directIdx.contains(String.valueOf(i)));
			item.setColor(cut(at(color, i), 100));
			item.setItemSize(cut(at(size, i), 100));
			item.setProductUrl(cut(at(productUrl, i), 1000));
			item.setImageUrl(cut(at(imageUrl, i), 1000));
			item.setMarketName(cut(at(marketName, i), 100));
			item.setMarketOrderNo(cut(at(marketOrder, i), 100));
			item.setHsCode(cut(at(hsCode, i), 30));
			item.setMarketPay(cut(at(marketPay, i), 100));

			// 숫자 칸 : 쉼표(1,000)를 없애고 숫자로 바꾼다. 숫자가 아니면 NumberFormatException
			try {
				String q = at(qty, i).replace(",", "");
				item.setQty(q.isEmpty() ? 1 : Integer.parseInt(q));

				String up = at(unitPrice, i).replace(",", "");
				item.setUnitPrice((up.isEmpty() ? BigDecimal.ZERO : new BigDecimal(up))
						.setScale(2, RoundingMode.HALF_UP));

				String mp = at(marketPrice, i).replace(",", "");
				item.setMarketPrice(mp.isEmpty() ? 0 : Long.parseLong(mp));
			} catch (NumberFormatException e) {
				if (parseError[0] == null) {
					parseError[0] = "상품 " + (i + 1) + " : 수량과 금액은 숫자로 입력해 주세요.";
				}
				item.setQty(1);
				item.setUnitPrice(BigDecimal.ZERO.setScale(2));
				item.setMarketPrice(0);
			}

			// 합계는 화면에 보이는 값을 믿지 않고 서버에서 다시 계산한다
			totalQty += item.getQty();
			totalYen = totalYen.add(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQty())));

			order.getItems().add(item);
		}

		order.setTotalQty(totalQty);
		order.setTotalYen(totalYen);
		return order;
	}

	/** 규칙 검사. 문제가 없으면 null, 있으면 첫 번째 오류 메시지를 돌려준다. */
	private String validate(HttpServletRequest request, BuyOrderDTO order, boolean submit) {

		// ---- 공통 검사 ----
		if (order.getRecvNameKo().isEmpty()) {
			return "받는 사람(한글)을 입력해 주세요.";
		}
		if (!order.getBizNo().isEmpty() && !BIZNO_PATTERN.matcher(order.getBizNo()).matches()) {
			return "사업자번호는 숫자 10자리로 입력해 주세요.";
		}
		if (!order.getMobile().isEmpty() && !PHONE_PATTERN.matcher(order.getMobile()).matches()) {
			return "휴대전화 번호 형식을 확인해 주세요.";
		}
		if (order.getItems().isEmpty()) {
			return "상품을 1개 이상 입력해 주세요.";
		}

		// ---- 접수신청일 때만 하는 검사 ----
		if (submit) {
			if (order.getPostcode().isEmpty() || order.getAddr1().isEmpty()) {
				return "우편번호와 주소를 입력해 주세요.";
			}
			if (order.getAddr2().isEmpty()) {
				return "세관신고 시 상세주소는 필수입니다.";
			}
			if (order.getMobile().isEmpty()) {
				return "휴대전화를 입력해 주세요.";
			}
			if (!allAgreed(request)) {
				return "해외배송규정 25개 항목에 모두 동의해 주세요.";
			}
		}

		// ---- 상품별 검사 ----
		for (BuyOrderItemDTO item : order.getItems()) {
			String label = "상품 " + item.getItemNo() + " : ";

			if (item.getItemNameEn().isEmpty()) {
				return label + "상품명(영문)을 입력해 주세요.";
			}
			// 상품URL · 이미지URL 은 나중에 링크/이미지로 화면에 출력되므로 http(s) 또는 우리 업로드 주소만 허용
			// (javascript: 같은 주소를 막기 위해)
			if (!isSafeUrl(item.getProductUrl(), false)) {
				return label + "상품URL은 http:// 또는 https:// 로 시작해야 합니다.";
			}
			if (!isSafeUrl(item.getImageUrl(), true)) {
				return label + "이미지URL은 http:// 또는 https:// 로 시작하거나, 이미지 업로드 버튼으로 올려 주세요.";
			}
			if (submit && item.getTrackingNo().isEmpty()) {
				return label + "트래킹번호를 입력해 주세요. (없으면 '접수대기'로 저장하세요)";
			}
			if (item.getQty() < 1 || item.getQty() > 99999) {
				return label + "수량은 1 이상으로 입력해 주세요.";
			}
			if (item.getUnitPrice().signum() < 0 || item.getUnitPrice().compareTo(new BigDecimal("9999999999")) > 0
					|| item.getMarketPrice() < 0) {
				return label + "금액을 확인해 주세요.";
			}
		}
		return null;
	}

	/**
	 * 검사에 실패했을 때 : 입력한 값을 formOrder 에 담고 오류 메시지를 띄운 채 주문서 화면으로 forward 한다.
	 * (redirect 가 아니라 forward 라서 사용자가 쓴 내용이 지워지지 않는다)
	 * true 를 돌려주면 컨트롤러가 order_form.jsp 로 forward 한다.
	 */
	private boolean fail(HttpServletRequest request, BuyOrderDTO order, String message) {
		request.setAttribute("formOrder", order);
		Session.flash(request, "error", message);
		return true;
	}

	/** 빈 값이거나 http(s) 주소이거나, (allowUpload 일 때) 우리가 만든 업로드 주소인지 */
	private static boolean isSafeUrl(String url, boolean allowUpload) {
		if (url.isEmpty()) {
			return true;
		}
		String lower = url.toLowerCase();
		if (lower.startsWith("http://") || lower.startsWith("https://")) {
			return true;
		}
		return allowUpload && url.startsWith(UploadStore.URL_PREFIX)
				&& UploadStore.FILE_NAME.matcher(url.substring(UploadStore.URL_PREFIX.length())).matches();
	}

	/** 동의 체크박스(name="agree", value=1~25) 25개가 모두 넘어왔는지 */
	private boolean allAgreed(HttpServletRequest request) {
		String[] agree = request.getParameterValues("agree");
		if (agree == null) {
			return false;
		}
		Set<String> set = new HashSet<>();
		for (String a : agree) {
			set.add(a);
		}
		for (int i = 1; i <= AGREE_COUNT; i++) {
			if (!set.contains(String.valueOf(i))) {
				return false;
			}
		}
		return true;
	}

	private static String param(HttpServletRequest request, String name) {
		String v = request.getParameter(name);
		return v == null ? "" : v.trim();
	}

	/** 배열의 i번째 값을 trim 해서 돌려준다 (배열이 없거나 값이 없으면 "") */
	private static String at(String[] arr, int i) {
		if (arr == null || i >= arr.length || arr[i] == null) {
			return "";
		}
		return arr[i].trim();
	}

	/** DB 컬럼 길이를 넘지 않도록 자른다 (넘으면 ORA-12899 오류) */
	private static String cut(String s, int max) {
		if (s == null) {
			return "";
		}
		return s.length() > max ? s.substring(0, max) : s;
	}

	private static long toLong(String s) {
		try {
			return Long.parseLong(s);
		} catch (NumberFormatException e) {
			return 0;
		}
	}
}
