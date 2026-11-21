package jp.kurologi.web;

//수정

import java.io.Serializable;
import java.security.SecureRandom;
import java.util.HexFormat;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/** 세션에 담는 값은 여기서만 다룹니다 (로그인 회원 id · CSRF 토큰 · 1회용 알림). */
public final class Session {

    private static final String MEMBER_ID = "loginMemberId";
    public static final String CSRF = "csrfToken";
    public static final String FLASH = "flash";

    private static final SecureRandom RANDOM = new SecureRandom();

    private Session() {}

    public static Long memberId(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s == null ? null : (Long) s.getAttribute(MEMBER_ID);
    }

    public static void login(HttpServletRequest req, long memberId) {
        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate();          // 세션 고정 공격 방지
        HttpSession s = req.getSession(true);
        s.setAttribute(MEMBER_ID, memberId);
        csrfToken(req);
    }

    public static void logout(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s != null) s.invalidate();
    }

    public static String csrfToken(HttpServletRequest req) {
        HttpSession s = req.getSession(true);
        String token = (String) s.getAttribute(CSRF);
        if (token == null) {
            byte[] b = new byte[24];
            RANDOM.nextBytes(b);
            token = HexFormat.of().formatHex(b);
            s.setAttribute(CSRF, token);
        }
        return token;
    }

    /** 다음 화면 한 번만 보이는 안내 (PRG 패턴). type: info | error */
    public static void flash(HttpServletRequest req, String type, String message) {
        req.getSession(true).setAttribute(FLASH, new Flash(type, message));
    }

    public record Flash(String type, String message) implements Serializable {
        public String getType() { return type; }
        public String getMessage() { return message; }
    }
}
