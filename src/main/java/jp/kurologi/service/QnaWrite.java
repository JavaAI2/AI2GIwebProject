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
 * 1:1 문의 쓰기
 *   GET  : 쓰기 폼을 보여준다 (true). ?title=... 로 제목을 미리 채울 수 있다 (특가제품 "문의하기" 버튼용)
 *   POST : 검증 -> 저장 -> 방금 쓴 글 상세로 redirect (false)
 *          검증/저장에 실패하면 request 에 "errors" 와 입력값(title, content)을 담고 true -> 폼을 다시 보여준다
 */
public class QnaWrite implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			String title = CommunityUtil.param(request, "title");
			if (title.length() > CommunityUtil.TITLE_MAX) {
				title = title.substring(0, CommunityUtil.TITLE_MAX);
			}
			request.setAttribute("title", title);
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
			dto.setBoardType(PostDAO.TYPE_QNA);
			dto.setTitle(title);
			dto.setContent(content);
			dto.setWriterId(CommunityUtil.loginId(request));

			if (id >= 0 && dao.insert(dto) == 1) {
				Session.flash(request, "info", "문의가 등록되었습니다.");
				response.sendRedirect(request.getContextPath() + "/community/qna/view?id=" + id);
				return false;
			}
			errors.put("system", "문의를 저장하지 못했습니다. 로그인 상태를 확인하고 잠시 후 다시 시도해 주세요.");
		}

		request.setAttribute("errors", errors);
		request.setAttribute("title", title);
		request.setAttribute("content", content);
		return true;
	}
}