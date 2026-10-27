package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.service.Command;
import jp.kurologi.service.DealList;
import jp.kurologi.service.FaqList;
import jp.kurologi.service.MessageDelete;
import jp.kurologi.service.MessageList;
import jp.kurologi.service.MessageRead;
import jp.kurologi.service.NoticeList;
import jp.kurologi.service.NoticeView;
import jp.kurologi.service.QnaDelete;
import jp.kurologi.service.QnaList;
import jp.kurologi.service.QnaUpdate;
import jp.kurologi.service.QnaView;
import jp.kurologi.service.QnaWrite;

/**
 * 커뮤니티 5개 화면(공지사항 · 1:1게시판 · 알림메세지 · 특가제품 · FAQ)을 받는 컨트롤러
 *
 *   /community/notice            공지 목록          /community/notice/view?id=   공지 상세
 *   /community/qna               내 문의 목록 *     /community/qna/view?id=      문의 상세 *
 *   /community/qna/write         문의 쓰기(GET 폼 / POST 저장) *
 *   /community/qna/update?id=    문의 수정(GET 폼 / POST 저장) *
 *   /community/qna/delete        문의 삭제(POST) *
 *   /community/message           알림 목록 *        /community/message/read, /delete  선택 알림 확인/삭제(POST) *
 *   /community/deals             특가제품           /community/faq               자주묻는 질문
 *                                                   (* = 로그인한 회원만)
 *
 * 흐름 : 컨트롤러(주소 판단) -> Command(서비스, 실제 처리) -> DAO(DB)
 *        Command 가 true 를 돌려주면 JSP 로 forward, false 면 이미 응답(redirect 등)을 끝낸 것
 *
 * 주소 규칙 : PageServlet 이 /community/* 전체를 받고 있어서 같은 주소를 쓰면 서버가 시작되지 않는다.
 *            그래서 /community/notice/* 처럼 더 구체적인 주소 5개만 이 컨트롤러가 받는다
 *            (서블릿은 더 구체적인 주소가 우선이라 PageServlet 은 고치지 않아도 된다).
 */
@WebServlet(urlPatterns = {
		"/community/notice/*", "/community/qna/*", "/community/message/*",
		"/community/deals/*", "/community/faq/*" })
public class CommunityController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/** JSP 위치는 여기 한 곳에서만 바꾸면 된다 */
	private static final String VIEWS = "/WEB-INF/views/community/";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doAction(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doAction(request, response);
	}

	protected void doAction(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		// /community/qna/write 로 들어오면 servletPath = "/community/qna", pathInfo = "/write"
		// /community/notice 로만 들어오면 pathInfo 가 없다 -> key = "/community/notice"
		String pathInfo = request.getPathInfo();
		String key = request.getServletPath();
		if (pathInfo != null && !"/".equals(pathInfo)) {
			key += pathInfo;
		}

		// 1:1게시판 · 알림메세지는 로그인한 회원만 (마이페이지의 AuthFilter 와 같이 홈 로그인 상자로 보낸다)
		boolean needLogin = key.startsWith("/community/qna") || key.startsWith("/community/message");
		if (needLogin && Session.memberId(request) == null) {
			response.sendRedirect(request.getContextPath() + "/?login=required#loginForm");
			return;
		}

		Command command = null;
		String page = null;           // forward 할 JSP (null 이면 Command 가 redirect 로 끝낸다)
		boolean postOnly = false;     // true 면 POST 로만 받는다 (삭제 · 처리 같은 동작)

		switch (key) {

		case "/community/notice":
			command = new NoticeList();
			page = "notice.jsp";
			break;
		case "/community/notice/view":
			command = new NoticeView();
			page = "notice_view.jsp";
			break;

		case "/community/qna":
			command = new QnaList();
			page = "qna.jsp";
			break;
		case "/community/qna/view":
			command = new QnaView();
			page = "qna_view.jsp";
			break;
		case "/community/qna/write":
			command = new QnaWrite();
			page = "qna_write.jsp";
			break;
		case "/community/qna/update":
			command = new QnaUpdate();
			page = "qna_write.jsp";   // 쓰기 화면을 같이 쓴다 (post 값이 있으면 수정 화면)
			break;
		case "/community/qna/delete":
			command = new QnaDelete();
			postOnly = true;
			break;

		case "/community/message":
			command = new MessageList();
			page = "message.jsp";
			break;
		case "/community/message/read":
			command = new MessageRead();
			postOnly = true;
			break;
		case "/community/message/delete":
			command = new MessageDelete();
			postOnly = true;
			break;

		case "/community/deals":
			command = new DealList();
			page = "deals.jsp";
			break;

		case "/community/faq":
			command = new FaqList();
			page = "faq.jsp";
			break;

		default:
			// 없는 주소 -> 404 (command 가 null 이라 NullPointerException 이 나지 않게)
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		if (postOnly && !"POST".equalsIgnoreCase(request.getMethod())) {
			response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
			return;
		}

		// 개인 정보가 있는 화면은 브라우저가 저장해 두지 않게 한다 (로그아웃 후 "뒤로 가기"로 보이는 것 방지)
		if (needLogin) {
			response.setHeader("Cache-Control", "no-store");
		}

		boolean needForward = command.doCommand(request, response);

		if (needForward && page != null) {
			attachMember(request);
			RequestDispatcher rd = request.getRequestDispatcher(VIEWS + page);
			rd.forward(request, response);
		}
	}

	/**
	 * 공통 헤더(layout.jsp)가 "OOO님 환영합니다"를 찍을 수 있게, PageServlet 과 똑같이
	 * 로그인한 회원을 request 의 "member" 로 넣어 둔다.
	 */
	private void attachMember(HttpServletRequest request) {
		Long memberId = Session.memberId(request);
		if (memberId != null) {
			App.of(getServletContext()).members.findById(memberId)
					.ifPresent(m -> request.setAttribute("member", m));
		}
	}
}