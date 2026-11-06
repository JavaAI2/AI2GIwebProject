package jp.kurologi.service;

import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.Waybill;
import jp.kurologi.repository.TrackingDAO;
import jp.kurologi.repository.TrackingDAO.OrderTrackData;

/**
 * 관리자 주문 관리의 [배송 추적] 내용을 만든다. 주문 1건의 이동 과정을 두 단계로 나누어 JSON 으로 돌려준다.
 *
 *   1단계 (일본 내 이동)         일본 쇼핑몰 -> 쿠로로지 일본 창고            (일본 운송장으로 확인)
 *   2단계 (국제 배송 및 국내 이동) 창고 -> 항공/해운 운송 · 세관 통관 -> 한국 택배  (한국 운송장으로 확인)
 *
 * 운송장번호는 주문의 결제에 배정된 값(PAYMENT)을 쓰고, 지금 어디까지 왔는지는 주문의 진행 단계(OrderStatus)로 정한다.
 * 택배사 / 운송사의 실시간 조회 API 는 아직 연결하지 않았다. 연결할 때는 stage1(), stage2() 안의 events 만 바꾸면 된다.
 */
public final class OrderTracker {

	private OrderTracker() { }

	/** 주문의 배송 추적 JSON. 주문이 없으면 null */
	public static String toJson(long orderId, String ctx) {

		OrderTrackData d = new TrackingDAO().findOrderTrack(orderId);
		if (d == null) {
			return null;
		}

		int step = OrderStatus.step(d.status());
		boolean canceled = OrderStatus.CANCELED.equals(d.status());

		StringBuilder sb = new StringBuilder("{\"ok\":true");
		sb.append(",\"orderNo\":").append(Json.q(d.orderNo()));
		sb.append(",\"statusLabel\":").append(Json.q(OrderStatus.label(d.status())));
		sb.append(",\"canceled\":").append(canceled);
		sb.append(",\"stage1\":").append(stage1(d, step, ctx));
		sb.append(",\"stage2\":").append(stage2(d, step, ctx));
		return sb.append('}').toString();
	}

	// ------------------------------------------------------------------ 1단계 : 일본 내 이동

	private static String stage1(OrderTrackData d, int step, String ctx) {

		String state = step >= 2 ? "done" : (step == 1 ? "active" : "wait");
		String summary;
		if (step >= 2) {
			summary = "쿠로로지 일본 창고에 입고되었습니다.";
		} else if (step == 1) {
			summary = "일본 쇼핑몰에서 쿠로로지 일본 창고로 이동 중입니다. (입고 대기)";
		} else {
			summary = "신청 전이거나 취소된 주문입니다.";
		}

		List<String[]> ev = new ArrayList<>();
		ev.add(new String[] { "일본 쇼핑몰 발송 (신청 접수)", step >= 1 ? "done" : "wait", step >= 1 ? nz(d.createdAt()) : "" });
		ev.add(new String[] { "일본 국내 택배 이동", step >= 2 ? "done" : (step == 1 ? "active" : "wait"), "" });
		ev.add(new String[] { "쿠로로지 일본 창고 입고", step >= 2 ? "done" : "wait", step == 2 ? nz(d.statusUpdatedAt()) : "" });

		String carrier = d.jpCarrier();
		String no = d.jpWaybillNo();
		String link = (no == null || no.isEmpty()) ? ""
				: ctx + "/?jpCarrier=" + enc(carrier) + "&jpNo=" + enc(no) + "#tracking";

		return stageJson("1단계 · 일본 내 이동", "일본 쇼핑몰 → 쿠로로지 일본 창고", Waybill.jpLabel(carrier), no, d.shopTrackingNos(),
				state, summary, ev, link,
				"일본 운송장은 결제가 끝나면 배정됩니다.");
	}

	// ------------------------------------------------------------------ 2단계 : 국제 배송 및 국내 이동

	private static String stage2(OrderTrackData d, int step, String ctx) {

		String state = step >= 4 ? "active" : "wait";
		String summary;
		if (step >= 5) {
			summary = "통관이 끝나 한국 택배로 배송 중입니다.";
		} else if (step == 4) {
			summary = "창고에서 출고되어 국제 운송 · 세관 통관 중입니다.";
		} else if (step >= 1) {
			summary = "출고 전입니다. (배송비 결제 · 출고 대기)";
		} else {
			summary = "신청 전이거나 취소된 주문입니다.";
		}

		String method = d.krMethod();
		String transport = "AIR".equals(method) ? "항공 운송 (" + Waybill.krLabel(method) + ")"
				: ("SEA".equals(method) ? "해운 운송 (" + Waybill.krLabel(method) + ")" : "항공 / 해운 국제 운송");

		List<String[]> ev = new ArrayList<>();
		ev.add(new String[] { "쿠로로지 일본 창고 출고", step >= 4 ? "done" : "wait", step == 4 ? nz(d.statusUpdatedAt()) : "" });
		ev.add(new String[] { transport, step >= 5 ? "done" : (step == 4 ? "active" : "wait"), "" });
		ev.add(new String[] { "세관 통관", step >= 5 ? "done" : "wait", "" });
		ev.add(new String[] { "한국 택배 배송", step >= 5 ? "active" : "wait", step == 5 ? nz(d.statusUpdatedAt()) : "" });

		String no = d.krWaybillNo();
		String link = (no == null || no.isEmpty()) ? ""
				: ctx + "/?krMethod=" + enc(method) + "&krNo=" + enc(no) + "#tracking";

		return stageJson("2단계 · 국제 배송 및 국내 이동", "쿠로로지 일본 창고 → 항공/해운 · 세관 통관 → 한국 택배",
				Waybill.krLabel(method), no, null, state, summary, ev, link,
				"한국 운송장은 결제가 끝나면 배정됩니다.");
	}

	// ------------------------------------------------------------------ JSON

	private static String stageJson(String title, String route, String carrier, String no, List<String> shopNos,
			String state, String summary, List<String[]> events, String link, String noWaybillText) {

		boolean hasNo = no != null && !no.isEmpty();
		StringBuilder sb = new StringBuilder("{");
		sb.append("\"title\":").append(Json.q(title));
		sb.append(",\"route\":").append(Json.q(route));
		sb.append(",\"carrier\":").append(Json.q(hasNo ? carrier : ""));
		sb.append(",\"waybill\":").append(Json.q(hasNo ? no : ""));
		sb.append(",\"waybillText\":").append(Json.q(hasNo ? "" : noWaybillText));
		sb.append(",\"link\":").append(Json.q(link));
		sb.append(",\"state\":").append(Json.q(state));
		sb.append(",\"summary\":").append(Json.q(summary));

		sb.append(",\"shopNos\":[");
		if (shopNos != null) {
			for (int i = 0; i < shopNos.size(); i++) {
				sb.append(i == 0 ? "" : ",").append(Json.q(shopNos.get(i)));
			}
		}
		sb.append("]");

		sb.append(",\"events\":[");
		for (int i = 0; i < events.size(); i++) {
			String[] e = events.get(i);
			sb.append(i == 0 ? "" : ",")
					.append("{\"label\":").append(Json.q(e[0]))
					.append(",\"state\":").append(Json.q(e[1]))
					.append(",\"time\":").append(Json.q(e[2])).append('}');
		}
		sb.append("]}");
		return sb.toString();
	}

	private static String nz(String s) {
		return s == null ? "" : s;
	}

	/** 주소에 붙일 값이라 영문 · 숫자만 남긴다 (운송사 코드 · 운송장번호는 원래 영문 · 숫자 · - 뿐) */
	private static String enc(String s) {
		return s == null ? "" : s.replaceAll("[^0-9A-Za-z\\-]", "");
	}
}