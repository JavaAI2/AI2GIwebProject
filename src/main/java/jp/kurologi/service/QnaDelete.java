package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.PostDAO;
import jp.kurologi.web.Session;

/**
 * 1:1 문의 삭제 (POST 전용) — 본인 글이고 아직 답변 전일 때만 가능
 * 파라미터 : id(글 번호). 결과는 안내 문구와 함께 redirect (false)
 */
public class QnaDelete implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String ctx = request.getContextPath();
		long loginId = CommunityUtil.loginId(request);
		long id = CommunityUtil.parseLong(request.getParameter("id"), -1);

		PostDTO post = id < 0 ? null : CommunityUtil.findOwnQna(id, loginId);
		if (post == null) {
			Session.flash(request, "error", "삭제할 수 있는 문의가 아닙니다.");
			response.sendRedirect(ctx + "/community/qna");
			return false;
		}
		if (post.isAnswered()) {
			Session.flash(request, "error", "답변이 완료된 문의는 삭제할 수 없습니다.");
			response.sendRedirect(ctx + "/community/qna/view?id=" + id);
			return false;
		}

		if (new PostDAO().delete(id, PostDAO.TYPE_QNA, loginId) == 1) {
			Session.flash(request, "info", "문의가 삭제되었습니다.");
		} else {
			Session.flash(request, "error", "문의를 삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.");
		}
		response.sendRedirect(ctx + "/community/qna");
		return false;
	}
}