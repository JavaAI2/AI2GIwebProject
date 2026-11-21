package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.AdminMessageDTO;
import jp.kurologi.repository.AdminMessageDAO;

/**
 * 관리자 알림 발송 이력 (전체 회원에게 나간 알림)
 * 파라미터 : page, searchType(member=받는 회원 / type=구분 / content=내용 / 그 외 구분+내용), keyword
 * JSP 에 넘기는 값 : pageData, startPage, endPage, searchType, keyword
 */
public class AdminMessageList implements Command {

	private static final int PAGE_SIZE = 15;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String searchType = CommunityUtil.searchType(request, "member", "type", "content");
		String keyword = CommunityUtil.param(request, "keyword");

		AdminMessageDAO dao = new AdminMessageDAO();
		int totalCount = dao.selectCount(searchType, keyword);
		CommunityPaging paging = new CommunityPaging(request, totalCount, PAGE_SIZE);

		List<AdminMessageDTO> list = dao.selectList(searchType, keyword, paging.startRow, paging.endRow);

		paging.apply(request, list);
		request.setAttribute("searchType", searchType);
		request.setAttribute("keyword", keyword);
		return true;
	}
}