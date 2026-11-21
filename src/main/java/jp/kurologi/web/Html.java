package jp.kurologi.web;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * JSP 스크립틀릿용 도우미.
 *
 * <%= 값 %> 은 HTML 이스케이프를 하지 않습니다. 회원이 입력한 값(이름 · 주소 · 메시지)은
 * 반드시 <%= Html.esc(값) %> 로 출력하세요. 그렇지 않으면 <script> 가 그대로 실행됩니다.
 */
public final class Html {

    private Html() {}

    /** HTML 본문 · 속성값 이스케이프. null 은 빈 문자열. */
    public static String esc(Object value) {
        if (value == null) return "";
        String s = value.toString();
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '<': sb.append("&lt;"); break;
                case '>': sb.append("&gt;"); break;
                case '&': sb.append("&amp;"); break;
                case '"': sb.append("&#034;"); break;
                case '\'': sb.append("&#039;"); break;
                default: sb.append(c);
            }
        }
        return sb.toString();
    }

    /** 5000 → 5,000 */
    public static String num(long n) {
        return String.format("%,d", n);
    }

    /** URL 쿼리 값 인코딩 (검색어 등) */
    public static String url(String value) {
        return value == null ? "" : URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    /** 조건이 참이면 " checked" — <input ...<%= Html.checked(x) %>> */
    public static String checked(boolean on) { return on ? " checked" : ""; }

    public static String selected(boolean on) { return on ? " selected" : ""; }

    /** 조건이 참이면 " 클래스이름" — class="item<%= Html.cls(x, "is-active") %>" */
    public static String cls(boolean on, String className) { return on ? " " + className : ""; }

    /** 서블릿이 넣어 둔 입력 오류 (없으면 빈 Map). */
    @SuppressWarnings("unchecked")
    public static Map<String, String> errors(HttpServletRequest req) {
        Object e = req.getAttribute("errors");
        return e == null ? Map.of() : (Map<String, String>) e;
    }

    /** 해당 칸의 오류 문구 <p class="field-error">…</p>, 없으면 빈 문자열. */
    public static String error(Map<String, String> errors, String field) {
        String msg = errors.get(field);
        return msg == null ? "" : "<p class=\"field-error\">" + esc(msg) + "</p>";
    }
}
