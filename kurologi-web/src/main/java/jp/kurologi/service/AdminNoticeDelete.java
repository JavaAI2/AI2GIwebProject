package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.AdminNoticeDAO;
import jp.kurologi.web.Session;

/**
 * 관리자 공지사항 삭제 (POST 전용)
 * 파라미터 : id(글 번호), page(돌아갈 목록 페이지). 결과는 안내 문구와 함께 목록으로 redirect (false)
 */
public class AdminNoticeDelete implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		long id = CommunityUtil.parseLong(request.getParameter("id"), -1);

		if (id >= 0 && new AdminNoticeDAO().delete(id) == 1) {
			Session.flash(request, "info", "공지사항이 삭제되었습니다.");
		} else {
			Session.flash(request, "error", "삭제할 수 없는 공지사항입니다.");
		}

		int page = CommunityUtil.safePage(request);   // 삭제로 마지막 페이지가 비면 목록에서 알아서 앞 페이지로 맞춰 준다
		response.sendRedirect(request.getContextPath() + "/admin/community/notice"
				+ (page > 1 ? "?page=" + page : ""));
		return false;
	}
}