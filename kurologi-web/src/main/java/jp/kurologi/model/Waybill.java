package jp.kurologi.model;

import java.security.SecureRandom;

/**
 * [시험용] 운송장 도우미.
 * 결제가 완료되면 한국 운송(도쿄에어 / 후쿠오카 고속해상 중 하나)과 일본 택배사(야마토 ~ 메이테츠 중 하나)를
 * 무작위로 정하고, 각각 12자리 운송장번호를 만들어 Payment 에 담는다.
 * 인덱스 페이지의 select 값(AIR, SEA, YAMATO ...)과 이 클래스의 값이 같아야 조회가 된다.
 */
public final class Waybill {

	private Waybill() { }

	/** 한국 운송 방법 (인덱스 "한국 운송장조회" 의 select 값과 같다) */
	public static final String[] KR_METHODS = { "AIR", "SEA" };

	/** 일본 택배사 (인덱스 "일본 운송장조회" 의 select 값과 같다) */
	public static final String[] JP_CARRIERS = {
			"YAMATO", "SAGAWA", "AMAZON", "JAPANPOST", "SEINO", "FUKUTSU", "LASTONE", "MEITETSU" };

	private static final SecureRandom RND = new SecureRandom();

	/** 화면에 보일 한국 운송 방법 이름. 모르는 값이면 "-" */
	public static String krLabel(String method) {
		if ("AIR".equals(method)) return "도쿄에어";
		if ("SEA".equals(method)) return "후쿠오카 고속해상";
		return "-";
	}

	/** 화면에 보일 일본 택배사 이름. 모르는 값이면 "-" */
	public static String jpLabel(String carrier) {
		if (carrier == null) return "-";
		switch (carrier) {
		case "YAMATO":    return "야마토";
		case "SAGAWA":    return "사가와";
		case "AMAZON":    return "Amazon";
		case "JAPANPOST": return "우체국";
		case "SEINO":     return "세이노";
		case "FUKUTSU":   return "후쿠야마";
		case "LASTONE":   return "라스트원";
		case "MEITETSU":  return "메이테츠";
		default:          return "-";
		}
	}

	public static boolean isKrMethod(String v) {
		for (String m : KR_METHODS) if (m.equals(v)) return true;
		return false;
	}

	public static boolean isJpCarrier(String v) {
		for (String c : JP_CARRIERS) if (c.equals(v)) return true;
		return false;
	}

	/** 결제가 완료된 Payment 에 한국 / 일본 운송장을 무작위로 배정한다 (이미 있으면 그대로 둔다) */
	public static void assign(Payment p) {
		if (p.getKrWaybillNo() == null || p.getKrWaybillNo().isEmpty()) {
			p.setKrMethod(KR_METHODS[RND.nextInt(KR_METHODS.length)]);
			p.setKrWaybillNo(randomDigits(12));
		}
		if (p.getJpWaybillNo() == null || p.getJpWaybillNo().isEmpty()) {
			p.setJpCarrier(JP_CARRIERS[RND.nextInt(JP_CARRIERS.length)]);
			p.setJpWaybillNo(randomDigits(12));
		}
	}

	/** 맨 앞이 0이 아닌 n자리 숫자 문자열 */
	public static String randomDigits(int n) {
		StringBuilder sb = new StringBuilder(n);
		sb.append(1 + RND.nextInt(9));
		for (int i = 1; i < n; i++) sb.append(RND.nextInt(10));
		return sb.toString();
	}
}
