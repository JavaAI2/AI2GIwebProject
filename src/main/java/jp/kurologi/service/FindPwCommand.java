package jp.kurologi.service;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jp.kurologi.model.MemberDTO;
import jp.kurologi.repository.MemberFindDAO;

/**
 * 비밀번호 찾기 1단계(본인 확인)
 *   GET  : 확인 폼만 보여준다. 이전에 받아 둔 변경 허가가 있으면 지운다
 *   POST : 아이디 + 이름 + 비밀번호 퀴즈 답이 모두 맞으면
 *          세션에 "10분짜리 변경 허가"(ResetPwCommand.TICKET_*)를 저장하고
 *          request "pwStep" = "reset" 으로 새 비밀번호 입력 화면을 보여준다(true)
 */
public class FindPwCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			HttpSession old = request.getSession(false);
			if (old != null) ResetPwCommand.clearTicket(old);
			return true;
		}

		String loginId = trim(request.getParameter("loginId"));
		String name    = trim(request.getParameter("name"));
		String answer  = request.getParameter("pwQuizAnswer");

		Map<String, String> errors = new LinkedHashMap<>();
		if (loginId.isEmpty()) errors.put("loginId", "아이디를 입력해 주세요.");
		if (name.isEmpty())    errors.put("name", "이름을 입력해 주세요.");
		if (answer == null || answer.trim().isEmpty()) errors.put("pwQuizAnswer", "비밀번호 퀴즈 답을 입력해 주세요.");
		if (!errors.isEmpty()) {
			request.setAttribute("errors", errors);
			return true;
		}

		HttpSession session = request.getSession(true);
		if (FindLimiter.isBlocked(session)) {
			errors.put("find", FindLimiter.BLOCKED_MESSAGE);
			request.setAttribute("errors", errors);
			return true;
		}

		MemberDTO m = new MemberFindDAO().findForPwReset(loginId, name);
		boolean ok = m != null && PwQuiz.matches(answer, m.getPwQuizAnswerHash());

		if (!ok) {
			// 아이디가 없는지, 이름이 틀렸는지, 퀴즈 답이 틀렸는지(또는 퀴즈를 등록하지 않은 계정인지) 구분해서 알려주지 않는다
			FindLimiter.fail(session);
			errors.put("find", "입력하신 정보와 일치하는 회원이 없습니다.");
			request.setAttribute("errors", errors);
			return true;
		}

		FindLimiter.reset(session);
		ResetPwCommand.issueTicket(session, m.getId());   // 2단계(새 비밀번호 입력)에서 확인할 허가증
		request.setAttribute("pwStep", "reset");
		return true;
	}

	private static String trim(String s) {
		return s == null ? "" : s.trim();
	}
}
