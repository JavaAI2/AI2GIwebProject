package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.MessageDTO;
import jp.kurologi.repository.MessageDAO;

/**
 * 알림메세지 목록 — 로그인한 회원 본인에게 온 알림만 (로그인 검사는 컨트롤러가 먼저 한다)
 * 파라미터 : page, searchType(type=구분 / content=내용 / 그 외 전체), keyword
 * JSP 에 넘기는 값 : pageData, startPage, endPage, searchType, keyword
 */
public class MessageList implements Command {

	private static final int PAGE_SIZE = 10;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		long memberId = CommunityUtil.loginId(request);
		String searchType = CommunityUtil.searchType(request, "type", "content");
		String keyword = CommunityUtil.param(request, "keyword");

		MessageDAO dao = new MessageDAO();
		int totalCount = dao.selectCount(memberId, searchType, keyword);
		CommunityPaging paging = new CommunityPaging(request, totalCount, PAGE_SIZE);

		List<MessageDTO> list = dao.selectList(memberId, searchType, keyword, paging.startRow, paging.endRow);

		paging.apply(request, list);
		request.setAttribute("searchType", searchType);
		request.setAttribute("keyword", keyword);
		return true;
	}
}