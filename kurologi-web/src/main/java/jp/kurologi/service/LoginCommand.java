package jp.kurologi.service;


//로그인과 세션 쿠키를 관리하는 서비스문
//세션은 서버가 저장하고, 쿠키는 사용자가 저장한다

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
			return true;   // 사용자가 로그인 링크를 눌렀을때. 겟 요청으로써 로그인 화면만 보여준다
		}

			String loginId = request.getParameter("loginId") == null ? "" : request.getParameter("loginId").trim();
			String password = request.getParameter("password");
		//사용자에게서 아이디와 비밀번호를 받아온다. 
			//비밀번호에는 공백도 넣을수 있어서 trim을 안한다

		MemberDAO dao = new MemberDAO();
		MemberDTO dto = null;
		if (!loginId.isEmpty() && password != null && !password.isEmpty()) {
			dto = dao.login(loginId);
			//만약 사용자에게 받아온 값이 다 정상이라면 login이라는 메서드를 실행시켜서 dto에 해당 사용자의 데이터를 담아도록 시킨다
		}

		// 아이디가 있고, 탈퇴하지 않았고, 비밀번호가 맞아야 성공
		boolean ok = false;
		if (dto != null && !dto.isWithdrawn() && dto.getPasswordHash() != null) {
			//dto에서 가져온 데이터를 판단하는데 사용자가 탈퇴하지 않았고, 패스워드도 무사히 가져왔다면
			try {
				ok = BCrypt.checkpw(password, dto.getPasswordHash());
				//사용자가 입력한 비밀번호를 다시 해시해서 DB에 저장된 비밀번호와 비교해서 똑같다면 ok변수에 true를 저장
			} catch (IllegalArgumentException e) {
				ok = false;   // DB 에 BCrypt 형식이 아닌 값이 들어 있는 경우(간단히 말해서 비번이 틀렸다면 false를 유지)
			}
		}

		if (!ok) {
			//계속 아이디나 비번이 틀렸다면 메시지를 출력
			// 아이디가 틀렸는지 비밀번호가 틀렸는지는 알려주지 
//해커가 특정 아이디 존재 여부를 모르게 하기위함
			request.setAttribute("loginFail", "아이디 또는 비밀번호를 확인해 주세요.");
			return true;
		}

		// ---- 로그인 성공 ----
		dao.updateLastLogin(dto.getId());
		//마지막 로그인 시간을 기록

		// 이 사이트는 로그인 상태를 Session 클래스(세션 속성 "loginMemberId")로 판단한다.
		// (기존 세션 폐기 + 새 세션 발급 + CSRF 토큰 발급까지 한 번에 해 준다)
		Session.login(request, dto.getId());

		// 마이페이지 · 홈 · AuthFilter 는 App.members(메모리 저장소)에서 회원을 찾는다.
		// DB 로 로그인한 회원도 거기서 찾을 수 있도록 같이 등록해 준다.
		MemberBridge.sync(request.getServletContext(), dto);
		//멤버 브릿지라는 컨트롤러로 가서 ServletContext라는 메모리에다가
		//해당 사용자의 정보를 저장하도록 시킨다.
		//매번 DB에서 해당 사용자의 정보를 쓰려고하면 DB가 터지기에 사용하는 방법
		//세션이 해제되면(로그아웃시) 메모리에서 해당 내용은 사라진다

		// 공통 헤더에 보여줄 이름 (로그아웃하면 세션째로 사라진다)
		request.getSession().setAttribute(LOGIN_NAME_ATTR, dto.getName());
		//로그인을 하면 헤더쪽에 ??님 환영합니다 표시용 이름 저장

		// 아이디 저장 체크 시 30일, 아니면 쿠키 삭제
		String encodedId;
		//웹사이트에서 한글을 무사히 받아오기 위한 인코딩을 지정
		try {
			encodedId = URLEncoder.encode(loginId, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			encodedId = "";   // UTF-8 은 항상 지원되므로 실제로는 일어나지 않는다
			
		}
		
		Cookie cookie = new Cookie(SAVED_ID_COOKIE, encodedId);
		//세션된 ID를 저장할 쿠키를 생성(세션을 유지하는데 쿠키를 사용)
		String ctx = request.getContextPath();
		//쿠키가 연결될 url 주소를 지정
		cookie.setPath(ctx.isEmpty() ? "/" : ctx);
		//만약 url을 지정 안했으면 해당 사이트 전체(아마도 인덱스부터 시작)를 대상으로 쿠키를 지정하고
		//지정했으면 해당 링크내부에서만 쿠키가 유지되도록 한다
		cookie.setHttpOnly(true);
		//오로지 사이트와 유저가 대화하고 있을때만 쿠키를 생성하도록 해서
		//쿠키 정보를 도중에 훔쳐가는 XSS공격을 방어한다.
		cookie.setMaxAge(request.getParameter("saveId") != null ? 60 * 60 * 24 * 30 : 0);
		//사용자가 아이디 저장을 체크 시에는 서버가 메모리에 쿠키를 30일동안 가지고 있도록 하여 아이디를 30일동안 저장하도록 한다
		//저 60초 * 60분 * 24시간 * 30일같은 경우에는 전부다 '초'를 의미한다. 다 곱하면 2592000초가 되어 30일로 계산된다
		//만약 체크하지 않았다면 쿠키의 유지시간은 0으로써 로그인시 입력한 아이디가 바로 삭제되게 된다
		response.addCookie(cookie);
		//이 모든 설정이 담긴 쿠키를 사용자의 브라우저로 보내준다

		response.sendRedirect(ctx + "/");
		//로그인이 끝나고 쿠키설정도 끝났으면 맨 위의 인덱스 화면을 보이도록 한다
		return false;
		//포워딩 거부
	
	}
}
