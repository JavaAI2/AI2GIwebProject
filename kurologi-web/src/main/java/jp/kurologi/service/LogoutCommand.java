package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/** 로그아웃 : 세션을 통째로 지우고 홈으로 이동 */
public class LogoutCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);   
		// 없으면 새로 만들지 않는다
		//getSession(true)를 하면 세션을 새로 생성하는데, 로그아웃을 할 때에는 세션을 없앨것이기에
		//세션이라는 객체를 선언하나 실제로 세션을 생성하지는 않기위해 false로 값을 채운다
		if (session != null) {
			session.invalidate();   
			//세션이 존재한다면 그 세션을 유효하지 않게하여 제거
		}

		response.sendRedirect(request.getContextPath() + "/");
		//세션이 제거되었으면 웹페이지의 꼭대기로(인덱스) 돌려보낸다
		return false;
	}
}
