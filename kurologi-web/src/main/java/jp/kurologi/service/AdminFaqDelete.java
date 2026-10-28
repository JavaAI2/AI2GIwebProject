package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.AdminFaqDAO;
import jp.kurologi.web.Session;

/**
 * 관리자 FAQ 삭제 (POST 전용) — 지우지 않고 감추고 싶으면 "숨기기"(AdminFaqVisible)를 쓴다
 * 파라미터 : id(FAQ 번호), page(돌아갈 목록 페이지). 결과는 안내 문구와 함께 목록으로 redirect (false)
 */
public class AdminFaqDelete implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		long id = CommunityUtil.parseLong(request.getParameter("id"), -1);

		if (id >= 0 && new AdminFaqDAO().delete(id) == 1) {
			Session.flash(request, "info", "자주묻는 질문이 삭제되었습니다.");
		} else {
			Session.flash(request, "error", "삭제할 수 없는 항목입니다.");
		}

		int page = CommunityUtil.safePage(request);
		response.sendRedirect(request.getContextPath() + "/admin/community/faq"
				+ (page > 1 ? "?page=" + page : ""));
		return false;
	}
}