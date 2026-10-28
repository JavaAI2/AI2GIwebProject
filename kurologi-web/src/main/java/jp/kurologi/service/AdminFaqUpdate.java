package jp.kurologi.service;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.FaqDTO;
import jp.kurologi.repository.AdminFaqDAO;
import jp.kurologi.web.Session;

/**
 * 관리자 FAQ 수정
 *   GET  ?id= : 기존 내용이 채워진 폼을 보여준다 (true)
 *   POST      : 검증 -> 수정 -> FAQ 목록으로 redirect (false). 실패하면 폼을 다시 보여준다 (true)
 * 파라미터 : id(FAQ 번호), page(돌아갈 목록 페이지)
 * JSP 에 넘기는 값 : faq(faqId 가 0 보다 크면 "수정" 화면), sortOrderText, categories, errors (등록 폼 JSP 를 같이 쓴다)
 */
public class AdminFaqUpdate implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		AdminFaqDAO dao = new AdminFaqDAO();

		long id = CommunityUtil.parseLong(request.getParameter("id"), -1);
		FaqDTO current = id < 0 ? null : dao.selectOne(id);
		if (current == null) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return false;
		}

		request.setAttribute("categories", dao.selectCategories());

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			request.setAttribute("faq", current);
			request.setAttribute("sortOrderText", String.valueOf(current.getSortOrder()));
			return true;
		}

		FaqDTO faq = AdminFaqForm.read(request);
		faq.setFaqId(id);
		Map<String, String> errors = AdminFaqForm.validate(faq);

		if (errors.isEmpty()) {
			if (dao.update(faq) == 1) {
				Session.flash(request, "info", "자주묻는 질문이 수정되었습니다.");
				int page = CommunityUtil.safePage(request);
				response.sendRedirect(request.getContextPath() + "/admin/community/faq"
						+ (page > 1 ? "?page=" + page : ""));
				return false;
			}
			errors.put("system", "수정하지 못했습니다. 잠시 후 다시 시도해 주세요.");
		}

		request.setAttribute("errors", errors);
		request.setAttribute("faq", faq);
		return true;
	}
}