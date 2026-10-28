package jp.kurologi.service;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.AdminNoticeDAO;
import jp.kurologi.repository.PostDAO;
import jp.kurologi.web.Session;

/**
 * 관리자 공지사항 수정
 *   GET  ?id= : 기존 내용이 채워진 폼을 보여준다 (true)
 *   POST      : 검증 -> 수정 -> 공지 목록으로 redirect (false). 실패하면 폼을 다시 보여준다 (true)
 * 파라미터 : id(글 번호), page(돌아갈 목록 페이지)
 * JSP 에 넘기는 값 : post(수정할 글 — 있으면 "수정" 화면), title, content, errors  (등록 폼 JSP 를 같이 쓴다)
 */
public class AdminNoticeUpdate implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		long id = CommunityUtil.parseLong(request.getParameter("id"), -1);
		PostDTO post = id < 0 ? null : new PostDAO().selectOne(id, PostDAO.TYPE_NOTICE);
		if (post == null) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
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
			dto.setBoardType(PostDAO.TYPE_NOTICE);
			dto.setTitle(title);
			dto.setContent(content);

			if (new AdminNoticeDAO().update(dto) == 1) {
				Session.flash(request, "info", "공지사항이 수정되었습니다.");
				int page = CommunityUtil.safePage(request);
				response.sendRedirect(request.getContextPath() + "/admin/community/notice"
						+ (page > 1 ? "?page=" + page : ""));
				return false;
			}
			errors.put("system", "공지사항을 수정하지 못했습니다. 잠시 후 다시 시도해 주세요.");
		}

		request.setAttribute("errors", errors);
		request.setAttribute("title", title);
		request.setAttribute("content", content);
		return true;
	}
}