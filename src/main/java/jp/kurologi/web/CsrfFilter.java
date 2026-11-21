package jp.kurologi.web;

import java.io.IOException;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** 모든 POST 폼은 hidden _csrf 값을 보내야 합니다 (common/csrf.jspf). */
@WebFilter("/*")
public class CsrfFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        if ("POST".equals(req.getMethod())) {
            String expected = req.getSession(false) == null ? null
                    : (String) req.getSession(false).getAttribute(Session.CSRF);
            String actual = req.getParameter("_csrf");
            if (expected == null || actual == null || !MessageDigest.isEqual(
                    expected.getBytes(StandardCharsets.UTF_8), actual.getBytes(StandardCharsets.UTF_8))) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "잘못된 요청입니다. 페이지를 새로고침해 주세요.");
                return;
            }
        } else if (Session.memberId(req) != null) {
            Session.csrfToken(req);
        }
        chain.doFilter(req, res);
    }
}
