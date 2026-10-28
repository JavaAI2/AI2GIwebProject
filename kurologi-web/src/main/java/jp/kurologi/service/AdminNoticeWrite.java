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
 * 관리자 공지사항 등록
 *   GET  : 빈 등록 폼을 보여준다 (true)
 *   POST : 검증 -> 저장 -> 공지 목록으로 redirect (false)
 *          실패하면 입력값을 그대로 두고 폼을 다시 보여준다 (true)
 * 공지는 작성자(WRITER_ID)를 NULL 로 저장한다 (화면에는 "관리자"로 표시된다)
 */
public class AdminNoticeWrite implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			return true;
		}

		String title = CommunityUtil.param(request, "title");
		String content = CommunityUtil.param(request, "content");

		Map<String, String> errors = CommunityUtil.validatePost(title, content);
		if (errors.isEmpty()) {
			PostDAO dao = new PostDAO();
			long id = dao.nextId();

			PostDTO dto = new PostDTO();
			dto.setPostId(id);
			dto.setBoardType(PostDAO.TYPE_NOTICE);
			dto.setTitle(title);
			dto.setContent(content);
			// writerId 를 비워 둔다 = 관리자 작성

			if (id >= 0 && dao.insert(dto) == 1) {
				Session.flash(request, "info", "공지사항이 등록되었습니다.");
				response.sendRedirect(request.getContextPath() + "/admin/community/notice");
				return false;
			}
			errors.put("system", "공지사항을 저장하지 못했습니다. 잠시 후 다시 시도해 주세요.");
		}

		request.setAttribute("errors", errors);
		request.setAttribute("title", title);
		request.setAttribute("content", content);
		return true;
	}
}