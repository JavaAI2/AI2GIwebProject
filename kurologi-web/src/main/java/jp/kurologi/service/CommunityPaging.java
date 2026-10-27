package jp.kurologi.service;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import jp.kurologi.model.Page;

/**
 * 목록 페이징 계산 (공지 · 1:1 · 알림 · 특가 공용). 같은 패키지 안에서만 사용.
 *
 *   new CommunityPaging(request, 전체개수, 한 페이지에 보여줄 개수)  ->  startRow / endRow 로 DAO 조회
 *   apply(request, 목록)  ->  JSP 가 쓸 값을 request 에 담는다
 *
 * JSP 가 꺼내 쓰는 이름 : pageData(Page 객체: 목록·현재 페이지·전체 개수·전체 페이지 수), startPage, endPage
 */
final class CommunityPaging {

	/** 하단에 한 번에 보여줄 페이지 번호 개수 */
	static final int BLOCK_SIZE = 5;

	final int page;         // 현재 페이지
	final int size;         // 한 페이지 글 수
	final int totalCount;   // 전체 글 수
	final int totalPage;    // 전체 페이지 수 (글이 없어도 1)
	final int startRow;     // 이번 페이지의 첫 줄 번호 (DAO 에 넘긴다)
	final int endRow;       // 이번 페이지의 마지막 줄 번호
	final int startPage;    // 하단 번호 구간의 시작
	final int endPage;      // 하단 번호 구간의 끝

	CommunityPaging(HttpServletRequest request, int totalCount, int size) {
		int total = (int) Math.ceil((double) totalCount / size);
		if (total < 1) {
			total = 1;
		}
		int current = CommunityUtil.safePage(request);
		if (current > total) {
			current = total;
		}

		this.page = current;
		this.size = size;
		this.totalCount = totalCount;
		this.totalPage = total;
		this.startRow = (current - 1) * size + 1;
		this.endRow = current * size;
		this.startPage = ((current - 1) / BLOCK_SIZE) * BLOCK_SIZE + 1;
		this.endPage = Math.min(startPage + BLOCK_SIZE - 1, total);
	}

	/** 조회한 목록과 페이지 값을 JSP 가 쓸 수 있게 request 에 담는다 */
	<T> void apply(HttpServletRequest request, List<T> items) {
		request.setAttribute("pageData", new Page<>(items, page, size, totalCount));
		request.setAttribute("startPage", startPage);
		request.setAttribute("endPage", endPage);
	}
}