package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.FaqDTO;
import jp.kurologi.repository.AdminFaqDAO;

/**
 * 관리자 FAQ 목록 (숨김 항목 포함, 사이트 화면과 같은 순서)
 * 파라미터 : page, searchType(category / question / 그 외 전체), keyword
 * JSP 에 넘기는 값 : pageData, startPage, endPage, searchType, keyword
 */
public class AdminFaqList implements Command {

	private static final int PAGE_SIZE = 15;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String searchType = CommunityUtil.searchType(request, "category", "question");
		String keyword = CommunityUtil.param(request, "keyword");

		AdminFaqDAO dao = new AdminFaqDAO();
		int totalCount = dao.selectCount(searchType, keyword);
		CommunityPaging paging = new CommunityPaging(request, totalCount, PAGE_SIZE);

		List<FaqDTO> list = dao.selectList(searchType, keyword, paging.startRow, paging.endRow);

		paging.apply(request, list);
		request.setAttribute("searchType", searchType);
		request.setAttribute("keyword", keyword);
		return true;
	}
}