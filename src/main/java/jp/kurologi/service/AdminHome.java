package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.AdminDAO;

/**
 * 관리자 첫 화면 (커뮤니티 현황)
 * JSP 에 넘기는 값 : stats (QNA_WAIT, QNA_ALL, NOTICE_CNT, FAQ_CNT, DEAL_CNT, MSG_CNT -> 개수)
 * 관리자 확인은 AdminFilter 가 이미 했다.
 */
public class AdminHome implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setAttribute("stats", new AdminDAO().summary());
		return true;
	}
}