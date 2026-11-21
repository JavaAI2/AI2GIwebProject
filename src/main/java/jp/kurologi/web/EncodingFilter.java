package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 요청/응답 UTF-8. web.xml 의 request-character-encoding 대신 사용 (Eclipse WTP 가 해당 요소를 인식하지 못함).
 * getParameter 보다 먼저 실행되어야 하므로 @WebFilter 가 아닌 web.xml 에 선언합니다.
 */
public class EncodingFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        if (req.getCharacterEncoding() == null) {
            req.setCharacterEncoding("UTF-8");
        }
        res.setCharacterEncoding("UTF-8");
        chain.doFilter(req, res);
    }
}
