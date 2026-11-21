package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.MessageDAO;
import jp.kurologi.web.Session;

/**
 * 선택한 알림을 "확인함"으로 바꾼다 (POST 전용)
 * 파라미터 : ids(체크박스로 선택한 알림 번호, 여러 개), page(돌아갈 페이지)
 * 내 알림이 아닌 번호는 DAO 의 SQL 이 걸러낸다. 결과는 안내 문구와 함께 목록으로 redirect (false)
 */
public class MessageRead implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		long memberId = CommunityUtil.loginId(request);
		List<Long> ids = CommunityUtil.idList(request, "ids");

		if (ids.isEmpty()) {
			Session.flash(request, "error", "확인할 알림을 선택해 주세요.");
		} else {
			MessageDAO dao = new MessageDAO();
			int done = 0;
			for (long id : ids) {
				done += dao.markRead(id, memberId);
			}
			Session.flash(request, "info", done + "건을 확인 처리했습니다.");
		}

		int page = CommunityUtil.safePage(request);
		response.sendRedirect(request.getContextPath() + "/community/message" + (page > 1 ? "?page=" + page : ""));
		return false;
	}
}