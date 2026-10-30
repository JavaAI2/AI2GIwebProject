package jp.kurologi.service;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jp.kurologi.repository.MemberFindDAO;

/**
 * 비밀번호 찾기 2단계(새 비밀번호 저장)
 * 어떤 회원의 비밀번호를 바꿀지는 화면 값(hidden)이 아니라, 1단계에서 세션에 저장해 둔 변경 허가로만 정한다.
 * (허가는 10분 동안만 유효하고, 사용하면 바로 지워진다)
 *   GET  : 직접 주소로 들어오면 1단계 화면으로 보낸다 (false)
 *   POST : 허가 확인 -> 새 비밀번호 검증 -> 암호화해서 저장 -> 로그인 화면으로 redirect (false)
 */
public class ResetPwCommand implements Command {

	static final String TICKET_ID = "pwResetMemberId";
	static final String TICKET_EXPIRES = "pwResetExpires";
	private static final long TICKET_MS = 10 * 60 * 1000L;

	static void issueTicket(HttpSession session, long memberId) {
		session.setAttribute(TICKET_ID, memberId);
		session.setAttribute(TICKET_EXPIRES, System.currentTimeMillis() + TICKET_MS);
	}

	static void clearTicket(HttpSession session) {
		session.removeAttribute(TICKET_ID);
		session.removeAttribute(TICKET_EXPIRES);
	}

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String ctx = request.getContextPath();

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			response.sendRedirect(ctx + "/member/find/pw");
			return false;
		}

		Map<String, String> errors = new LinkedHashMap<>();

		// 1. 변경 허가 확인
		HttpSession session = request.getSession(false);
		Long memberId = session == null ? null : (Long) session.getAttribute(TICKET_ID);
		Long expires  = session == null ? null : (Long) session.getAttribute(TICKET_EXPIRES);

		if (memberId == null || expires == null || expires < System.currentTimeMillis()) {
			if (session != null) clearTicket(session);
			errors.put("find", "본인 확인 시간이 만료되었습니다. 처음부터 다시 진행해 주세요.");
			request.setAttribute("errors", errors);
			request.setAttribute("pwStep", "verify");
			return true;
		}

		// 2. 새 비밀번호 검증
		String newPassword = request.getParameter("newPassword");
		String confirm     = request.getParameter("newPasswordConfirm");

		if (newPassword == null || newPassword.isEmpty()) {
			errors.put("newPassword", "새 비밀번호를 입력해 주세요.");
		} else if (newPassword.length() < 8 || newPassword.length() > 72) {   // BCrypt 는 72바이트까지만 사용
			errors.put("newPassword", "비밀번호는 8자 이상 72자 이하로 입력해 주세요.");
		} else if (!newPassword.equals(confirm)) {
			errors.put("newPasswordConfirm", "비밀번호가 일치하지 않습니다.");
		}

		if (!errors.isEmpty()) {
			request.setAttribute("errors", errors);
			request.setAttribute("pwStep", "reset");   // 허가는 그대로 두고 입력 화면만 다시
			return true;
		}

		// 3. 암호화해서 저장
		int result = new MemberFindDAO().updatePassword(memberId, PasswordHasher.hash(newPassword));

		if (result == 0) {
			errors.put("find", "비밀번호 변경 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
			request.setAttribute("errors", errors);
			request.setAttribute("pwStep", "reset");
			return true;
		}

		clearTicket(session);   // 허가는 한 번만 쓸 수 있다
		response.sendRedirect(ctx + "/member/login?pwReset=1");
		return false;
	}
}
