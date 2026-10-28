package jp.kurologi.web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.service.AdminHome;
import jp.kurologi.service.AdminFaqDelete;
import jp.kurologi.service.AdminFaqList;
import jp.kurologi.service.AdminFaqUpdate;
import jp.kurologi.service.AdminFaqVisible;
import jp.kurologi.service.AdminFaqWrite;
import jp.kurologi.service.AdminNoticeDelete;
import jp.kurologi.service.AdminNoticeList;
import jp.kurologi.service.AdminNoticeUpdate;
import jp.kurologi.service.AdminNoticeWrite;
import jp.kurologi.service.AdminQnaAnswer;
import jp.kurologi.service.AdminQnaList;
import jp.kurologi.service.Command;

/**
 * 관리자용 커뮤니티 관리 화면을 받는 컨트롤러 (/admin/community/*)
 * 관리자만 들어올 수 있게 AdminFilter 가 앞에서 막아 준다.
 *
 *   /admin/community               현황 (답변 대기 문의 수 등)
 *   /admin/community/qna           1:1 문의 목록 (전체 회원)
 *   /admin/community/qna/answer    문의 보기 + 답변 등록 (GET 화면 / POST 저장)
 *   /admin/community/notice        공지사항 목록 (관리)
 *   /admin/community/notice/write  공지 등록 (GET 폼 / POST 저장)
 *   /admin/community/notice/update 공지 수정 (GET 폼 / POST 저장)
 *   /admin/community/notice/delete 공지 삭제 (POST)
 *   /admin/community/faq           자주묻는 질문 목록 (관리)
 *   /admin/community/faq/write     FAQ 등록 (GET 폼 / POST 저장)
 *   /admin/community/faq/update    FAQ 수정 (GET 폼 / POST 저장)
 *   /admin/community/faq/visible   FAQ 노출 / 숨김 바꾸기 (POST)
 *   /admin/community/faq/delete    FAQ 삭제 (POST)
 *   (이후 단계에서 특가, 알림 발송 주소를 이 switch 에 하나씩 추가한다)
 *
 * 흐름은 CommunityController 와 같다 : 컨트롤러 -> Command(서비스) -> DAO,
 * Command 가 true 를 돌려주면 JSP 로 forward, false 면 이미 응답(redirect 등)을 끝낸 것.
 */
@WebServlet(urlPatterns = { "/admin/community/*" })
public class AdminCommunityController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private static final String VIEWS = "/WEB-INF/views/admin/";

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

		// /admin/community 로만 들어오면 pathInfo 가 없다 -> key = "/admin/community"
		String pathInfo = request.getPathInfo();
		String key = request.getServletPath();
		if (pathInfo != null && !"/".equals(pathInfo)) {
			key += pathInfo;
		}

		Command command = null;
		String page = null;           // forward 할 JSP (null 이면 Command 가 redirect 로 끝낸다)
		boolean postOnly = false;     // true 면 POST 로만 받는다 (등록 · 삭제 같은 동작)

		switch (key) {

		case "/admin/community":
			command = new AdminHome();
			page = "community_home.jsp";
			break;

		case "/admin/community/qna":
			command = new AdminQnaList();
			page = "qna_list.jsp";
			break;
		case "/admin/community/qna/answer":
			command = new AdminQnaAnswer();
			page = "qna_answer.jsp";
			break;

		case "/admin/community/notice":
			command = new AdminNoticeList();
			page = "notice_list.jsp";
			break;
		case "/admin/community/notice/write":
			command = new AdminNoticeWrite();
			page = "notice_form.jsp";
			break;
		case "/admin/community/notice/update":
			command = new AdminNoticeUpdate();
			page = "notice_form.jsp";   // 등록 폼을 같이 쓴다 (post 값이 있으면 수정 화면)
			break;
		case "/admin/community/notice/delete":
			command = new AdminNoticeDelete();
			postOnly = true;
			break;

		case "/admin/community/faq":
			command = new AdminFaqList();
			page = "faq_list.jsp";
			break;
		case "/admin/community/faq/write":
			command = new AdminFaqWrite();
			page = "faq_form.jsp";
			break;
		case "/admin/community/faq/update":
			command = new AdminFaqUpdate();
			page = "faq_form.jsp";   // 등록 폼을 같이 쓴다 (faqId 가 0 보다 크면 수정 화면)
			break;
		case "/admin/community/faq/visible":
			command = new AdminFaqVisible();
			postOnly = true;
			break;
		case "/admin/community/faq/delete":
			command = new AdminFaqDelete();
			postOnly = true;
			break;

		default:
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		if (postOnly && !"POST".equalsIgnoreCase(request.getMethod())) {
			response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
			return;
		}

		boolean needForward = command.doCommand(request, response);

		if (needForward && page != null) {
			attachMember(request);
			RequestDispatcher rd = request.getRequestDispatcher(VIEWS + page);
			rd.forward(request, response);
		}
	}

	/** 공통 헤더(layout.jsp)가 "OOO님 환영합니다"를 찍을 수 있게 로그인한 회원을 request 의 "member" 로 넣는다 (PageServlet 과 같음) */
	private void attachMember(HttpServletRequest request) {
		Long memberId = Session.memberId(request);
		if (memberId != null) {
			App.of(getServletContext()).members.findById(memberId)
					.ifPresent(m -> request.setAttribute("member", m));
		}
	}
}