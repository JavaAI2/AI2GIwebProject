package jp.kurologi.service;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jp.kurologi.model.MemberDTO;
import jp.kurologi.repository.MemberDAO;
import jp.kurologi.web.Session;

/**
 * 로그인 서비스 (blogProject2 의 LoginCommand 와 같은 구조)
 *
 *   GET  : 로그인 폼만 보여준다 (true -> 컨트롤러가 login.jsp 로 forward)
 *   POST : 아이디/비밀번호 확인
 *          성공 -> 세션에 로그인 정보를 담고 홈으로 redirect (false)
 *          실패 -> request 에 "loginFail" 메시지를 담고 true 를 돌려줘서 로그인 폼을 다시 보여준다
 *
 * [blogProject2 와 다른 점 두 가지]
 *  1) 비밀번호 암호화는 BCrypt 대신 PasswordHasher(PBKDF2) 를 쓴다.
 *     hash() = BCrypt.hashpw(), matches() = BCrypt.checkpw() 와 같은 역할이다.
 *     이미 가입한 회원들의 비밀번호가 이 방식으로 저장되어 있어서 바꾸면 로그인이 안 된다.
 *  2) 세션에 "loginMember"(MemberDTO)를 담는 것은 같지만, 팀원이 만든 주문 · 커뮤니티 코드가
 *     Session.login() 으로 만드는 "로그인 회원 번호"를 쓰고 있어서 두 가지를 함께 담는다.
 */
public class LoginCommand implements Command {

	/** 세션 속성 이름 : 로그인한 회원(MemberDTO). 이 속성이 있으면 로그인 상태, 지우면 로그아웃 (blogProject2 와 같다) */
	public static final String LOGIN_MEMBER = "loginMember";

	/** 아이디 저장용 쿠키 이름 (login.jsp, 홈 화면이 이 이름으로 읽는다) */
	public static final String SAVED_ID_COOKIE = "savedId";

	/** 공통 헤더(layout.jsp)에 "OOO님 환영합니다"를 찍기 위해 세션에 넣어 두는 이름 */
	public static final String LOGIN_NAME_ATTR = "loginMemberName";

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// GET 요청이면 로그인 화면만 보여준다
		if ("GET".equalsIgnoreCase(request.getMethod())) {
			return true;
		}

		// ---- POST : 로그인 처리 ----
		String loginId = request.getParameter("loginId") == null ? "" : request.getParameter("loginId").trim();
		String password = request.getParameter("password");

		MemberDAO dao = new MemberDAO();
		MemberDTO dto = null;
		if (!loginId.isEmpty() && password != null && !password.isEmpty()) {
			dto = dao.login(loginId);   // 아이디로 회원 1명 조회 (없으면 null)
		}

		// 아이디가 있고, 탈퇴하지 않았고, 비밀번호가 맞아야 성공
		boolean ok = false;
		if (dto != null && !dto.isWithdrawn() && dto.getPasswordHash() != null) {
			try {
				// 입력한 비밀번호와 DB 의 암호화된 비밀번호를 비교한다 (BCrypt.checkpw 와 같은 역할)
				ok = PasswordHasher.matches(password, dto.getPasswordHash());
			} catch (RuntimeException e) {
				ok = false;   // DB 에 알 수 없는 형식의 값이 들어 있는 경우
			}
		}

		if (!ok) {
			// 아이디가 틀렸는지 비밀번호가 틀렸는지는 알려주지 않는다 (보안)
			// request 속성은 이번 요청 한 번만 유지된다 -> login.jsp 가 꺼내서 화면에 보여준다
			request.setAttribute("loginFail", "아이디 또는 비밀번호를 확인해 주세요.");
			return true;   // 로그인 폼 다시 보여주기
		}

		// ---- 로그인 성공 ----
		dao.updateLastLogin(dto.getId());   // 마지막 로그인 시각 갱신

		// 팀 공통 로그인 처리 : 기존 세션을 버리고 새 세션을 만든 뒤 회원 번호를 담는다
		Session.login(request, dto.getId());

		// 세션에 로그인 회원을 담는다 (blogProject2 의 session.setAttribute("loginMember", dto) 와 같다)
		// 세션은 로그아웃하거나 시간이 지나 만료될 때까지 서버에 유지되어 다른 페이지에서도 꺼내 쓸 수 있다.
		dto.setPasswordHash(null);   // 세션에 비밀번호(암호문)까지 남겨 둘 필요가 없다
		HttpSession session = request.getSession();
		session.setAttribute(LOGIN_MEMBER, dto);
		session.setAttribute(LOGIN_NAME_ATTR, dto.getName());   // 공통 헤더에 이름 표시용

		// 아이디 저장 체크 시 30일, 아니면 쿠키 삭제
		// (쿠키 = 사용자 컴퓨터에 저장 / 세션 = 서버에 저장)
		String encodedId;
		try {
			encodedId = URLEncoder.encode(loginId, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			encodedId = "";   // UTF-8 은 항상 지원되므로 실제로는 일어나지 않는다
		}
		Cookie cookie = new Cookie(SAVED_ID_COOKIE, encodedId);
		String ctx = request.getContextPath();
		cookie.setPath(ctx.isEmpty() ? "/" : ctx);
		cookie.setHttpOnly(true);
		cookie.setMaxAge(request.getParameter("saveId") != null ? 60 * 60 * 24 * 30 : 0);
		response.addCookie(cookie);

		response.sendRedirect(ctx + "/");   // 홈으로 이동
		return false;                       // 이미 redirect 했으니 컨트롤러는 forward 하지 않는다
	}
}
