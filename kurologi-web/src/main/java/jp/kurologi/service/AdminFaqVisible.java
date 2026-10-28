package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.AdminFaqDAO;
import jp.kurologi.web.Session;

/**
 * 관리자 FAQ 노출 / 숨김 바꾸기 (POST 전용)
 * 파라미터 : id(FAQ 번호), visible("Y" = 노출 / 그 외 = 숨김), page(돌아갈 목록 페이지)
 * 숨긴 FAQ 는 사이트의 FAQ 화면에 보이지 않는다. 결과는 안내 문구와 함께 목록으로 redirect (false)
 */
public class AdminFaqVisible implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		long id = CommunityUtil.parseLong(request.getParameter("id"), -1);
		boolean visible = "Y".equals(CommunityUtil.param(request, "visible"));

		if (id >= 0 && new AdminFaqDAO().setVisible(id, visible) == 1) {
			Session.flash(request, "info", visible ? "사이트에 노출하도록 바꿨습니다." : "사이트에서 숨겼습니다.");
		} else {
			Session.flash(request, "error", "상태를 바꿀 수 없는 항목입니다.");
		}

		int page = CommunityUtil.safePage(request);
		response.sendRedirect(request.getContextPath() + "/admin/community/faq"
				+ (page > 1 ? "?page=" + page : ""));
		return false;
	}
}