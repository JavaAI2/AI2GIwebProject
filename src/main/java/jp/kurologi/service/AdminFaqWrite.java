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
 * 관리자 FAQ 등록
 *   GET  : 빈 폼을 보여준다 (표시 순서는 "맨 뒤"로, 노출은 체크된 상태로 미리 채운다) (true)
 *   POST : 검증 -> 저장 -> FAQ 목록으로 redirect (false). 실패하면 입력값을 그대로 두고 폼을 다시 보여준다 (true)
 * JSP 에 넘기는 값 : faq(폼에 채울 값, faqId 가 0 이면 "등록" 화면), sortOrderText, categories, errors
 */
public class AdminFaqWrite implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		AdminFaqDAO dao = new AdminFaqDAO();
		request.setAttribute("categories", dao.selectCategories());

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			int next = Math.min(dao.maxSortOrder() + 10, AdminFaqForm.SORT_MAX);

			FaqDTO faq = new FaqDTO();
			faq.setVisible(true);
			faq.setSortOrder(next);
			request.setAttribute("faq", faq);
			request.setAttribute("sortOrderText", String.valueOf(next));
			return true;
		}

		FaqDTO faq = AdminFaqForm.read(request);
		Map<String, String> errors = AdminFaqForm.validate(faq);

		if (errors.isEmpty()) {
			faq.setFaqId(dao.nextId());
			if (faq.getFaqId() >= 0 && dao.insert(faq) == 1) {
				Session.flash(request, "info", "자주묻는 질문이 등록되었습니다.");
				response.sendRedirect(request.getContextPath() + "/admin/community/faq");
				return false;
			}
			faq.setFaqId(0);     // 저장에 실패했으니 아직 "등록 화면"이다
			errors.put("system", "저장하지 못했습니다. 잠시 후 다시 시도해 주세요.");
		}

		request.setAttribute("errors", errors);
		request.setAttribute("faq", faq);
		return true;
	}
}