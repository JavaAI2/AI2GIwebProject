package jp.kurologi.service;

/** 주문 상태 · 결제 상태를 화면에 보일 이름과 CSS 클래스로 바꿔 주는 도우미 */
public final class OrderStatus {

	private OrderStatus() { }

	/** STATUS 코드 -> 화면 이름 */
	public static String label(String status) {
		if ("SUBMIT".equals(status)) return "접수신청";
		if ("RECEIVED".equals(status)) return "입고완료";
		if ("SHIPPED".equals(status)) return "출고완료";
		return "접수대기";   // WAIT
	}

	/** STATUS 코드 -> 배지 CSS 클래스 (.state--wait / submit / received / shipped) */
	public static String css(String status) {
		if ("SUBMIT".equals(status)) return "state--submit";
		if ("RECEIVED".equals(status)) return "state--received";
		if ("SHIPPED".equals(status)) return "state--shipped";
		return "state--wait";
	}

	/** 결제 상태 이름. 접수대기(아직 신청 전)는 결제 대상이 아니라 "-" */
	public static String payLabel(String status, String payStatus) {
		if ("WAIT".equals(status)) return "-";
		return "PAID".equals(payStatus) ? "결제완료" : "미결제";
	}
}
