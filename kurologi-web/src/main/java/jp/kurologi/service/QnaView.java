package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.CommentDTO;
import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.CommentDAO;

/**
 * 1:1 문의 상세 + 관리자 답변(댓글) — 본인 글만 볼 수 있다. 없거나 남의 글이면 404.
 * 파라미터 : id(글 번호)
 * JSP 에 넘기는 값 : post, comments
 */
public class QnaView implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		long id = CommunityUtil.parseLong(request.getParameter("id"), -1);
		PostDTO post = id < 0 ? null : CommunityUtil.findOwnQna(id, CommunityUtil.loginId(request));
		if (post == null) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return false;
		}

		List<CommentDTO> comments = new CommentDAO().selectByPost(id);

		request.setAttribute("post", post);
		request.setAttribute("comments", comments);
		return true;
	}
}