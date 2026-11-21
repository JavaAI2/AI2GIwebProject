package jp.kurologi.service;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.PostDAO;
import jp.kurologi.web.Session;

/**
 * 1:1 문의 수정 — 본인 글이고 아직 답변 전일 때만 가능
 *   GET  ?id=  : 기존 내용이 채워진 폼을 보여준다 (true)
 *   POST       : 검증 -> 수정 -> 상세로 redirect (false). 실패하면 폼을 다시 보여준다 (true)
 * JSP 에 넘기는 값 : post(수정할 글 — 이 값이 있으면 "수정" 화면), title, content, errors
 * (쓰기 화면 JSP 를 같이 쓴다)
 */
public class QnaUpdate implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String ctx = request.getContextPath();
		long loginId = CommunityUtil.loginId(request);
		long id = CommunityUtil.parseLong(request.getParameter("id"), -1);

		PostDTO post = id < 0 ? null : CommunityUtil.findOwnQna(id, loginId);
		if (post == null) {
			Session.flash(request, "error", "수정할 수 있는 문의가 아닙니다.");
			response.sendRedirect(ctx + "/community/qna");
			return false;
		}
		if (post.isAnswered()) {
			Session.flash(request, "error", "답변이 완료된 문의는 수정할 수 없습니다.");
			response.sendRedirect(ctx + "/community/qna/view?id=" + id);
			return false;
		}

		request.setAttribute("post", post);

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			request.setAttribute("title", post.getTitle());
			request.setAttribute("content", post.getContent());
			return true;
		}

		String title = CommunityUtil.param(request, "title");
		String content = CommunityUtil.param(request, "content");

		Map<String, String> errors = CommunityUtil.validatePost(title, content);
		if (errors.isEmpty()) {
			PostDTO dto = new PostDTO();
			dto.setPostId(id);
			dto.setBoardType(PostDAO.TYPE_QNA);
			dto.setTitle(title);
			dto.setContent(content);

			if (new PostDAO().update(dto, loginId) == 1) {
				Session.flash(request, "info", "문의가 수정되었습니다.");
				response.sendRedirect(ctx + "/community/qna/view?id=" + id);
				return false;
			}
			errors.put("system", "문의를 수정하지 못했습니다. 잠시 후 다시 시도해 주세요.");
		}

		request.setAttribute("errors", errors);
		request.setAttribute("title", title);
		request.setAttribute("content", content);
		return true;
	}
}