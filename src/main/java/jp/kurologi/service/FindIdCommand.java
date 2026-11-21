package jp.kurologi.service;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jp.kurologi.repository.MemberFindDAO;

/**
 * 아이디 찾기 서비스
 *   GET  : 입력 폼만 보여준다 (true -> forward)
 *   POST : 이름 + 이메일 + 전화번호가 모두 일치하면 request "foundIds"(아이디 목록)를 담아 결과 화면으로(true)
 *          일치하지 않으면 request "errors" 를 담아 폼으로 되돌린다(true)
 */
public class FindIdCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			return true;
		}

		String name  = trim(request.getParameter("name"));
		String email = trim(request.getParameter("email"));
		String phone = trim(request.getParameter("phone"));
		String phoneDigits = phone.replaceAll("[^0-9]", "");   // 하이픈 등은 버리고 숫자만 비교

		Map<String, String> errors = new LinkedHashMap<>();
		if (name.isEmpty())        errors.put("name", "이름을 입력해 주세요.");
		if (email.isEmpty())       errors.put("email", "이메일을 입력해 주세요.");
		if (phoneDigits.isEmpty()) errors.put("phone", "휴대전화 번호를 입력해 주세요.");
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

		List<String> ids = new MemberFindDAO().findLoginIds(name, email, phoneDigits);

		if (ids.isEmpty()) {
			FindLimiter.fail(session);
			errors.put("find", "입력하신 정보와 일치하는 회원이 없습니다.");
			request.setAttribute("errors", errors);
			return true;
		}

		FindLimiter.reset(session);
		request.setAttribute("foundIds", ids);
		return true;   // find_id.jsp 가 foundIds 가 있으면 결과 화면을 보여준다
	}

	private static String trim(String s) {
		return s == null ? "" : s.trim();
	}
}
