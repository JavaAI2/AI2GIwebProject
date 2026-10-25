package jp.kurologi.service;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.mindrot.jbcrypt.BCrypt;

import jp.kurologi.model.MemberDTO;
import jp.kurologi.repository.MemberDAO;
import jp.kurologi.web.MemberBridge;
import jp.kurologi.web.Session;

/**
 * 로그인 서비스
 *   GET  : 로그인 폼만 보여준다 (true -> forward)
 *   POST : 아이디/비밀번호 확인 -> 성공하면 Session.login 으로 로그인 처리 후 홈으로 redirect (false)
 *          실패하면 request 에 "loginFail" 메시지를 담고 true 를 돌려줘서 로그인 폼을 다시 보여준다
 */
public class LoginCommand implements Command {

	/** 아이디 저장용 쿠키 이름 (login.jsp 가 이 이름으로 읽는다) */
	public static final String SAVED_ID_COOKIE = "savedId";

	/** 공통 헤더(layout.jsp)에 "OOO님 환영합니다"를 찍기 위해 세션에 넣어 두는 이름 */
	public static final String LOGIN_NAME_ATTR = "loginMemberName";

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			return true;   // 로그인 화면만 보여준다
		}

		String loginId = request.getParameter("loginId") == null ? "" : request.getParameter("loginId").trim();
		String password = request.getParameter("password");

		MemberDAO dao = new MemberDAO();
		MemberDTO dto = null;
		if (!loginId.isEmpty() && password != null && !password.isEmpty()) {
			dto = dao.login(loginId);
		}

		// 아이디가 있고, 탈퇴하지 않았고, 비밀번호가 맞아야 성공
		boolean ok = false;
		if (dto != null && !dto.isWithdrawn() && dto.getPasswordHash() != null) {
			try {
				ok = BCrypt.checkpw(password, dto.getPasswordHash());
			} catch (IllegalArgumentException e) {
				ok = false;   // DB 에 BCrypt 형식이 아닌 값이 들어 있는 경우
			}
		}

		if (!ok) {
			// 아이디가 틀렸는지 비밀번호가 틀렸는지는 알려주지 않는다
			request.setAttribute("loginFail", "아이디 또는 비밀번호를 확인해 주세요.");
			return true;
		}

		// ---- 로그인 성공 ----
		dao.updateLastLogin(dto.getId());

		// 이 사이트는 로그인 상태를 Session 클래스(세션 속성 "loginMemberId")로 판단한다.
		// (기존 세션 폐기 + 새 세션 발급 + CSRF 토큰 발급까지 한 번에 해 준다)
		Session.login(request, dto.getId());

		// 마이페이지 · 홈 · AuthFilter 는 App.members(메모리 저장소)에서 회원을 찾는다.
		// DB 로 로그인한 회원도 거기서 찾을 수 있도록 같이 등록해 준다.
		MemberBridge.sync(request.getServletContext(), dto);

		// 공통 헤더에 보여줄 이름 (로그아웃하면 세션째로 사라진다)
		request.getSession().setAttribute(LOGIN_NAME_ATTR, dto.getName());

		// 아이디 저장 체크 시 30일, 아니면 쿠키 삭제
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

		response.sendRedirect(ctx + "/");
		return false;
	}
}
