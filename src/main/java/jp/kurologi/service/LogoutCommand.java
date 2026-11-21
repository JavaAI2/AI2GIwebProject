package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 로그아웃 서비스 (blogProject2 의 LogoutCommand 와 같다)
 * 세션을 통째로 지우면 loginMember 도 함께 사라져서 로그아웃이 된다.
 * (헤더의 "로그아웃" 링크는 /logout 의 LogoutServlet 이 같은 일을 한다)
 */
public class LogoutCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);   // 없으면 새로 만들지 않는다
		if (session != null) {
			session.invalidate();   // 세션 안의 모든 값 제거 (invalidate : 무효로 하다)
		}

		response.sendRedirect(request.getContextPath() + "/");   // 홈으로
		return false;   // 이미 이동 방향을 정했으니 컨트롤러가 forward 하지 않게 false
	}
}
