package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.AdminDAO;

/**
 * /admin/* 주소는 "관리자"만 들어올 수 있다. (AuthFilter 와 같은 방식, AuthFilter 는 고치지 않았다)
 *
 *   로그인 안 함        -> 홈 화면 로그인 상자로 이동
 *   로그인했지만 일반 회원 -> 404 (관리자 화면이 있다는 사실도 알려주지 않는다)
 *   관리자              -> 통과
 *
 * 관리자 여부는 요청마다 DB(KURO_MEMBER.ROLE)에서 확인한다. 그래서 관리자 권한을 회수하면 바로 적용된다.
 */
@WebFilter(urlPatterns = { "/admin", "/admin/*" })
public class AdminFilter extends HttpFilter {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doFilter(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
			throws IOException, ServletException {

		Long memberId = Session.memberId(req);
		if (memberId == null) {
			res.sendRedirect(req.getContextPath() + "/?login=required#loginForm");
			return;
		}
		if (!new AdminDAO().isAdmin(memberId)) {
			res.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		res.setHeader("Cache-Control", "no-store");   // 로그아웃 후 "뒤로 가기"로 관리자 화면이 보이지 않게
		chain.doFilter(req, res);
	}
}