package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.PostDAO;

/**
 * 1:1게시판 목록 — 로그인한 회원 "본인이 쓴 문의"만 보인다 (로그인 검사는 컨트롤러가 먼저 한다)
 * 파라미터 : page, searchType(title / content / 그 외 전체), keyword
 * JSP 에 넘기는 값 : pageData, startPage, endPage, searchType, keyword
 */
public class QnaList implements Command {

	private static final int PAGE_SIZE = 10;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		Long loginId = CommunityUtil.loginId(request);
		String searchType = CommunityUtil.searchType(request, "title", "content");
		String keyword = CommunityUtil.param(request, "keyword");

		PostDAO dao = new PostDAO();
		int totalCount = dao.selectCount(PostDAO.TYPE_QNA, searchType, keyword, loginId);
		CommunityPaging paging = new CommunityPaging(request, totalCount, PAGE_SIZE);

		List<PostDTO> list = dao.selectList(PostDAO.TYPE_QNA, searchType, keyword, loginId,
				paging.startRow, paging.endRow);

		paging.apply(request, list);
		request.setAttribute("searchType", searchType);
		request.setAttribute("keyword", keyword);
		return true;
	}
}