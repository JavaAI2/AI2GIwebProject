package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.PostDAO;

/**
 * 공지사항 목록 (누구나 볼 수 있다)
 * 파라미터 : page(페이지), searchType(title / content / 그 외 전체), keyword(검색어)
 * JSP 에 넘기는 값 : pageData, startPage, endPage, searchType, keyword
 */
public class NoticeList implements Command {

	private static final int PAGE_SIZE = 10;   // 한 페이지에 보여줄 개수

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String searchType = CommunityUtil.searchType(request, "title", "content");
		String keyword = CommunityUtil.param(request, "keyword");

		PostDAO dao = new PostDAO();
		int totalCount = dao.selectCount(PostDAO.TYPE_NOTICE, searchType, keyword, null);
		CommunityPaging paging = new CommunityPaging(request, totalCount, PAGE_SIZE);

		List<PostDTO> list = dao.selectList(PostDAO.TYPE_NOTICE, searchType, keyword, null,
				paging.startRow, paging.endRow);

		paging.apply(request, list);
		request.setAttribute("searchType", searchType);
		request.setAttribute("keyword", keyword);
		return true;
	}
}