package jp.kurologi.service;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.MemberDAO;

/**
 * 아이디 중복확인 서비스 (blogProject2 의 IdCheckCommand 와 같다)
 * join.jsp 의 Ajax 요청을 받아서 화면 이동 없이 {"isDuplicate":true/false} JSON 만 응답한다.
 * (비동기식이라 화면이 새로고침되지 않아서, 입력하던 가입 정보가 사라지지 않는다)
 */
public class IdCheckCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String loginId = request.getParameter("loginId");
		loginId = (loginId == null) ? "" : loginId.trim();

		// 비어 있으면 DB 에 묻지 않고 "중복(사용 불가)" 으로 취급
		boolean isDuplicate = loginId.isEmpty() || new MemberDAO().idCheck(loginId);

		// 브라우저에게 "HTML 이 아니라 JSON 이니 UTF-8 로 읽어라" 라고 알려준다
		// 주의: 쉼표(,)가 아니라 세미콜론(;) 으로 구분해야 한다
		response.setContentType("application/json; charset=UTF-8");

		// 응답 통로를 열어서 JSON 문자열을 보낸다. 예) {"isDuplicate":true}
		PrintWriter out = response.getWriter();
		out.print("{\"isDuplicate\":" + isDuplicate + "}");

		return false;   // 응답을 직접 끝냈으니 forward 하지 않는다 (화면 새로고침 방지)
	}
}
