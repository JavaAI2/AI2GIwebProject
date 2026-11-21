package jp.kurologi.service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.FaqDTO;
import jp.kurologi.repository.FaqDAO;

/**
 * 자주묻는 질문 (누구나 볼 수 있다) — 분류(CATEGORY)별로 묶어서 넘긴다
 * JSP 에 넘기는 값 : faqGroups (분류 이름 -> 그 분류의 질문 목록, 분류는 SORT_ORDER 가 작은 순서)
 */
public class FaqList implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		List<FaqDTO> all = new FaqDAO().selectAll();

		// LinkedHashMap : 처음 나온 순서를 그대로 유지한다
		Map<String, List<FaqDTO>> groups = new LinkedHashMap<>();
		for (FaqDTO faq : all) {
			groups.computeIfAbsent(faq.getCategory(), k -> new ArrayList<>()).add(faq);
		}

		request.setAttribute("faqGroups", groups);
		return true;
	}
}