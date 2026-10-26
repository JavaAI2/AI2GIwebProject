package jp.kurologi.service;

//아이디, 비번 찾기 서비스문

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
			//만약 get방식으로 요청이 들어오면 컨트롤러로 유도하여
			//아이디,비번찾기 폼을 띄우도록 시킴
			return true;
		}
		//get이 아니라면 post방식으로 사용자가 입력한 내용을 보내는 방식으로 
		//아래의 내용을 서버로 전달
		

		String name  = trim(request.getParameter("name"));
		String email = trim(request.getParameter("email"));
		String phone = trim(request.getParameter("phone"));
		String phoneDigits = phone.replaceAll("[^0-9]", "");   // 하이픈 등은 버리고 숫자만 비교
		//사용자로부터 이름,이메일,전화번호 등을 받아오는데
		//공백등을 다 제거하고, 전화번호는 만약 010-3333-3333같이 입력 시 
		//- 부분을 다 제거해서 숫자값 만을 가져오도록 시킨다

		Map<String, String> errors = new LinkedHashMap<>();
		//입력받은 값 유효성 검사를 한다
		if (name.isEmpty())        errors.put("name", "이름을 입력해 주세요.");
		if (email.isEmpty())       errors.put("email", "이메일을 입력해 주세요.");
		if (phoneDigits.isEmpty()) errors.put("phone", "휴대전화 번호를 입력해 주세요.");
		//공백이면 값을 입력하라고 시킨다
		if (!errors.isEmpty()) {
			//만약 에러가 몇개 존재한다면
			//모든 에러를 다 담아서 사용자에게 알럿 형식으로 보여주고
			//다시 아이디 비번찾기 폼을 띄워서 보이도록 포워딩 시킨다
			request.setAttribute("errors", errors);
			return true;
		}

		HttpSession session = request.getSession(true);
		//무차별 대입 공격을 막기위해서 사용자의 세션을 확인한다
		if (FindLimiter.isBlocked(session)) {
			//만약 해당 세션에서 입력 한도를 넘어서면
			errors.put("find", FindLimiter.BLOCKED_MESSAGE);
			request.setAttribute("errors", errors);
			//더이상 DB조회를 하지않고 에러를 반환한다
			return true;
		}

		List<String> ids = new MemberFindDAO().findLoginIds(name, email, phoneDigits);
		//입력된 값이 대조된게 옳다면 DB에서 사용자의 정보를 가져온다

		if (ids.isEmpty()) {
			//사용자가 입력한 아이디가 DB에 존재하는지 확인한다
			FindLimiter.fail(session);
			errors.put("find", "입력하신 정보와 일치하는 회원이 없습니다.");
			request.setAttribute("errors", errors);
			//계속 아이디를 찾지못하면 해당 횟수를 누적하고 에러를 발생
			return true;
		}

		FindLimiter.reset(session);
		//만약 아이디를 찾아냈으면 리미트에 쌓인 에러 횟수를 초기화
		request.setAttribute("foundIds", ids);
		//id가 찾아졌으면 DB에서 가져온 값을 view에서 보여주기 위해서 foundIds 속성에 담는다
		return true;   // find_id.jsp 가 foundIds 가 있으면 결과 화면을 보여준다
	}

	private static String trim(String s) {
		return s == null ? "" : s.trim();
		//위에서 입력된 값들의 공백을 없애주는 메서드
	}
}
