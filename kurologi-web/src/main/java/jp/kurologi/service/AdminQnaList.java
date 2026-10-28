package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.AdminQnaDAO;

/**
 * 관리자 1:1 문의 목록 (전체 회원의 문의)
 * 파라미터 : status(wait=답변대기 / done=답변완료 / all=전체, 없으면 wait), page,
 *           searchType(title / content / writer / 그 외 제목+내용), keyword
 * JSP 에 넘기는 값 : pageData, startPage, endPage, status, searchType, keyword
 */
public class AdminQnaList implements Command {

	private static final int PAGE_SIZE = 10;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String status = CommunityUtil.param(request, "status");
		if (!"all".equals(status) && !"done".equals(status)) {
			status = "wait";     // 처음 들어오면 답변이 필요한 문의부터 보여준다
		}
		String searchType = CommunityUtil.searchType(request, "title", "content", "writer");
		String keyword = CommunityUtil.param(request, "keyword");

		AdminQnaDAO dao = new AdminQnaDAO();
		int totalCount = dao.selectCount(status, searchType, keyword);
		CommunityPaging paging = new CommunityPaging(request, totalCount, PAGE_SIZE);

		List<PostDTO> list = dao.selectList(status, searchType, keyword, paging.startRow, paging.endRow);

		paging.apply(request, list);
		request.setAttribute("status", status);
		request.setAttribute("searchType", searchType);
		request.setAttribute("keyword", keyword);
		return true;
	}  
}