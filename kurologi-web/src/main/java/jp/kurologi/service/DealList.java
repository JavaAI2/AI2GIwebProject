package jp.kurologi.service;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.DealDTO;
import jp.kurologi.repository.DealDAO;

/**
 * 특가제품안내 목록 (누구나 볼 수 있다). 화면이 한 줄 4칸이라 한 페이지에 8개(2줄)
 * 파라미터 : page
 * JSP 에 넘기는 값 : pageData, startPage, endPage
 */
public class DealList implements Command {

	private static final int PAGE_SIZE = 8;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		DealDAO dao = new DealDAO();
		CommunityPaging paging = new CommunityPaging(request, dao.selectCount(), PAGE_SIZE);

		List<DealDTO> list = dao.selectList(paging.startRow, paging.endRow);

		paging.apply(request, list);
		return true;
	}
}