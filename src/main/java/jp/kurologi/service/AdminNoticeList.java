package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.PostDAO;

/**
 * 관리자 공지사항 목록 (수정 · 삭제 · 등록 버튼이 있는 화면)
 * 파라미터 : page, searchType(title / content / 그 외 전체), keyword
 * JSP 에 넘기는 값 : pageData, startPage, endPage, searchType, keyword
 */
public class AdminNoticeList implements Command {

	private static final int PAGE_SIZE = 10;

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