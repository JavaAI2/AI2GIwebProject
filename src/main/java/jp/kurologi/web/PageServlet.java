package jp.kurologi.web;

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.service.LoginCommand;

/**
 * 안내 · 현황 · 신청서 같은 화면용 — 주소를 받아 같은 이름의 JSP 로 넘겨 줍니다.
 *
 *   /                         → WEB-INF/views/index.jsp
 *   /service/info_company     → WEB-INF/views/service/info_company.jsp
 *   /status/dashboard  /buy/order_form  /ship/order_form  /community/notice …
 *
 * 마이페이지는 기능이 있어서 따로 컨트롤러가 있습니다 (MyPageController).
 */
@WebServlet(urlPatterns = {"", "/service/*", "/status/*", "/buy/*", "/ship/*", "/community/*"})
public class PageServlet extends HttpServlet {

    /** 영문 소문자 · 숫자 · _ 만 — "../" 같은 경로로 다른 파일을 열지 못하게 */
    private static final Pattern NAME = Pattern.compile("[a-z0-9_]+");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String view;
        if (req.getServletPath().isEmpty()) {
            view = "index";
        } else {
            String name = req.getPathInfo() == null ? "" : req.getPathInfo().substring(1);
            if (!NAME.matcher(name).matches()) {
                res.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            view = req.getServletPath().substring(1) + "/" + name;
        }
        String jsp = "/WEB-INF/views/" + view + ".jsp";
        if (getServletContext().getResource(jsp) == null) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // 로그인한 회원이면 화면에서 이름 · 사서함번호를 쓸 수 있게
        Long memberId = Session.memberId(req);
        if (memberId != null) {
            App.of(getServletContext()).members.findById(memberId).ifPresent(m -> req.setAttribute("member", m));
        }
        req.setAttribute("savedId", savedId(req));
        req.getRequestDispatcher(jsp).forward(req, res);
    }

    /** 아이디저장 쿠키 (LoginCommand 가 만듭니다) */
    private static String savedId(HttpServletRequest req) {
        if (req.getCookies() == null) return null;
        for (Cookie c : req.getCookies()) {
            if (LoginCommand.SAVED_ID_COOKIE.equals(c.getName())) {
                return URLDecoder.decode(c.getValue(), StandardCharsets.UTF_8);
            }
        }
        return null;
    }
}
