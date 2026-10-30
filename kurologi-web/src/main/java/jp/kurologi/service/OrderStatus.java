package jp.kurologi.service;

/** 주문 상태 · 결제 상태를 화면에 보일 이름과 CSS 클래스로 바꿔 주는 도우미 */
public final class OrderStatus {

	private OrderStatus() { }

	/** 진행 단계 5개 (01 ~ 05) 의 STATUS 코드. 배열 번호 + 1 이 단계 번호 */
	private static final String[] STEP_STATUS = { "SUBMIT", "RECEIVED", "BILLED", "SHIPPED", "DELIVERING" };

	/** 진행 단계 5개의 화면 이름 */
	private static final String[] STEP_NAME = { "신청 완료", "현지 창고 입고", "배송비 대기", "결제 완료 / 출고", "국내 배송 중" };

	/** 진행 단계 개수 */
	public static final int STEP_COUNT = STEP_STATUS.length;

	/** STATUS 코드 -> 화면 이름 */
	public static String label(String status) {
		if ("SUBMIT".equals(status)) return "접수신청";
		if ("RECEIVED".equals(status)) return "입고완료";
		if ("BILLED".equals(status)) return "배송비 대기";
		if ("SHIPPED".equals(status)) return "출고완료";
		if ("DELIVERING".equals(status)) return "국내 배송 중";
		return "접수대기";   // WAIT
	}

	/** STATUS 코드 -> 배지 CSS 클래스 (.state--wait / submit / received / billed / shipped / delivering) */
	public static String css(String status) {
		if ("SUBMIT".equals(status)) return "state--submit";
		if ("RECEIVED".equals(status)) return "state--received";
		if ("BILLED".equals(status)) return "state--billed";
		if ("SHIPPED".equals(status)) return "state--shipped";
		if ("DELIVERING".equals(status)) return "state--delivering";
		return "state--wait";
	}

	/** 결제 상태 이름. 접수대기(아직 신청 전)는 결제 대상이 아니라 "-" */
	public static String payLabel(String status, String payStatus) {
		if ("WAIT".equals(status)) return "-";
		return "PAID".equals(payStatus) ? "결제완료" : "미결제";
	}

	// ------------------------------------------------------------------
	// 진행 단계 (01 신청 완료 ~ 05 국내 배송 중)
	// ------------------------------------------------------------------

	/** STATUS 코드 -> 단계 번호 (1 ~ 5). 접수대기(WAIT) 등 단계에 없는 값은 0 */
	public static int step(String status) {
		for (int i = 0; i < STEP_STATUS.length; i++) {
			if (STEP_STATUS[i].equals(status)) {
				return i + 1;
			}
		}
		return 0;
	}

	/** 단계 번호 -> 화면 이름. 범위 밖이면 빈 문자열 */
	public static String stepName(int step) {
		return (step >= 1 && step <= STEP_NAME.length) ? STEP_NAME[step - 1] : "";
	}

	/** 단계 번호 -> STATUS 코드. 범위 밖이면 null */
	public static String statusOfStep(int step) {
		return (step >= 1 && step <= STEP_STATUS.length) ? STEP_STATUS[step - 1] : null;
	}

	/** 그 단계가 결제 완료 상태인지 (04 결제 완료 / 출고, 05 국내 배송 중부터 결제 완료) */
	public static boolean isPaidStep(int step) {
		return step >= 4;
	}
}