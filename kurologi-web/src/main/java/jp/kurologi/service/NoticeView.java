package jp.kurologi.service;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.PostDAO;

/**
 * 공지사항 상세 (누구나 볼 수 있다)
 * 파라미터 : id(글 번호)
 * JSP 에 넘기는 값 : post
 * 조회수는 같은 접속(세션)에서 같은 글을 새로고침해도 한 번만 올라간다.
 */
public class NoticeView implements Command {

	private static final String VIEWED_ATTR = "viewedNotices";

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		long id = CommunityUtil.parseLong(request.getParameter("id"), -1);
		PostDTO post = id < 0 ? null : new PostDAO().selectOne(id, PostDAO.TYPE_NOTICE);
		if (post == null) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return false;
		}

		// 이 접속에서 처음 보는 글이면 조회수 1 증가 (화면에도 바로 반영)
		HttpSession session = request.getSession();
		@SuppressWarnings("unchecked")
		Set<Long> viewed = (Set<Long>) session.getAttribute(VIEWED_ATTR);
		if (viewed == null) {
			viewed = new HashSet<>();
			session.setAttribute(VIEWED_ATTR, viewed);
		}
		if (viewed.add(id)) {
			new PostDAO().increaseViewCount(id);
			post.setViewCount(post.getViewCount() + 1);
		}

		request.setAttribute("post", post);
		return true;
	}
}