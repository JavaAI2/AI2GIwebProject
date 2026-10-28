package jp.kurologi.service;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.CommentDTO;
import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.AdminQnaDAO;
import jp.kurologi.repository.CommentDAO;
import jp.kurologi.web.Session;

/**
 * 관리자 1:1 문의 보기 + 답변 등록
 *   GET  ?id= : 문의 내용, 지금까지의 답변, 답변 입력 폼을 보여준다 (true)
 *   POST      : 검증 -> 답변 저장(+ 답변완료 처리 + 문의 회원에게 알림) -> 같은 화면으로 redirect (false)
 *               실패하면 입력한 내용을 그대로 두고 폼을 다시 보여준다 (true)
 * JSP 에 넘기는 값 : post, comments, content(입력값), errors
 */
public class AdminQnaAnswer implements Command {

	/** 답변 최대 글자 수 (COMMUNITY_COMMENT.CONTENT 는 1000자) */
	private static final int ANSWER_MAX = 1000;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		long id = CommunityUtil.parseLong(request.getParameter("id"), -1);
		AdminQnaDAO dao = new AdminQnaDAO();

		PostDTO post = id < 0 ? null : dao.selectOne(id);
		if (post == null) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return false;
		}

		if ("POST".equalsIgnoreCase(request.getMethod())) {
			String content = CommunityUtil.param(request, "content");

			Map<String, String> errors = new LinkedHashMap<>();
			if (content.isEmpty()) {
				errors.put("content", "답변 내용을 입력해 주세요.");
			} else if (content.length() > ANSWER_MAX) {
				errors.put("content", "답변은 " + ANSWER_MAX + "자 이내로 입력해 주세요.");
			}

			if (errors.isEmpty()) {
				if (dao.answer(id, content)) {
					Session.flash(request, "info", "답변이 등록되었습니다. 문의한 회원에게 알림도 보냈습니다.");
					response.sendRedirect(request.getContextPath() + "/admin/community/qna/answer?id=" + id);
					return false;
				}
				errors.put("system", "답변을 저장하지 못했습니다. 잠시 후 다시 시도해 주세요.");
			}

			request.setAttribute("errors", errors);
			request.setAttribute("content", content);
		}

		List<CommentDTO> comments = new CommentDAO().selectByPost(id);
		request.setAttribute("post", post);
		request.setAttribute("comments", comments);
		return true;
	}
}