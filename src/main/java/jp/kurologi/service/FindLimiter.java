package jp.kurologi.service;

import javax.servlet.http.HttpSession;

/**
 * 아이디/비밀번호 찾기 무작위 대입 방지.
 * 한 세션에서 5번 틀리면 10분 동안 막는다.
 * (세션 기준이라 쿠키를 지우면 우회할 수 있다. 제대로 막으려면 DB/IP 기준 횟수 제한이 필요하다)
 */
final class FindLimiter {

	static final String BLOCKED_MESSAGE = "시도 횟수를 초과했습니다. 10분 후 다시 시도해 주세요.";

	private static final int MAX_FAILS = 5;
	private static final long LOCK_MS = 10 * 60 * 1000L;
	private static final String FAILS = "findFails";
	private static final String LOCKED_UNTIL = "findLockedUntil";

	private FindLimiter() {}

	static boolean isBlocked(HttpSession s) {
		Long until = (Long) s.getAttribute(LOCKED_UNTIL);
		if (until == null) return false;
		if (until > System.currentTimeMillis()) return true;
		reset(s);   // 잠금 시간이 지났으면 초기화
		return false;
	}

	static void fail(HttpSession s) {
		Integer n = (Integer) s.getAttribute(FAILS);
		n = (n == null ? 0 : n) + 1;
		s.setAttribute(FAILS, n);
		if (n >= MAX_FAILS) {
			s.setAttribute(LOCKED_UNTIL, System.currentTimeMillis() + LOCK_MS);
		}
	}

	static void reset(HttpSession s) {
		s.removeAttribute(FAILS);
		s.removeAttribute(LOCKED_UNTIL);
	}
}
