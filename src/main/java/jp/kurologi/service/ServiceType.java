package jp.kurologi.service;

import javax.servlet.http.HttpServletRequest;

/**
 * 구매대행(BUY) / 배송대행(SHIP) 구분 도우미.
 * 두 서비스는 같은 코드 · 같은 테이블(BUY_ORDER)을 쓰고, "어느 주소로 들어왔는지" 로만 구분한다.
 *   /buyorder/*  -> BUY
 *   /shiporder/* -> SHIP
 */
public final class ServiceType {

	private ServiceType() { }

	public static final String BUY = "BUY";
	public static final String SHIP = "SHIP";

	/** 요청이 어느 서비스 주소로 들어왔는지 */
	public static String of(HttpServletRequest request) {
		return "/shiporder".equals(request.getServletPath()) ? SHIP : BUY;
	}

	/** 이상한 값이 들어와도 BUY / SHIP 둘 중 하나로 맞춘다 */
	public static String normalize(String type) {
		return SHIP.equals(type) ? SHIP : BUY;
	}

	/** 컨트롤러 주소 앞부분 (프로젝트 주소 ctx 는 붙이지 않은 값) */
	public static String base(String type) {
		return SHIP.equals(type) ? "/shiporder" : "/buyorder";
	}

	/** 화면에 보일 이름 */
	public static String label(String type) {
		return SHIP.equals(type) ? "배송대행" : "구매대행";
	}
}
