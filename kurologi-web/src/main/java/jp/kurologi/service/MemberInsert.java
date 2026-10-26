package jp.kurologi.service;

//회원가입을 처리하는 서비스문

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.MemberDTO;
import jp.kurologi.repository.MemberDAO;

/**
 * 회원가입 서비스
 *   GET  : 가입 폼만 보여준다 (true -> forward)
 *   POST : 입력값 검증 -> 비밀번호 암호화 -> DB 저장 -> 로그인 화면으로 redirect (false)
 *          검증에 실패하면 request 에 "errors" 를 담고 true 를 돌려줘서 가입 폼을 다시 보여준다
 * (수정) 비밀번호 찾기에 쓰는 "비밀번호 퀴즈 답(pwQuizAnswer)"을 필수로 받아 암호화해서 저장한다
 */
public class MemberInsert implements Command {

	private static final Pattern ID_PATTERN    = Pattern.compile("^[A-Za-z0-9]{4,20}$");
	//영문,숫자 조합 4~20자만 허용
	private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
	private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9\\-+() ]{7,30}$");
	//이메일과 전화번호는 올바른 형식 구조를 가졌는지 체크

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			return true;
		}
		//우선 회원가입 링크를 누르면 회원가입 폼을 열어야하니
		//해당 jsp를 보이도록 유도하기 위한 포워딩을 한다

		String loginId         = trim(request.getParameter("loginId"));
		String password        = request.getParameter("password");
		String passwordConfirm = request.getParameter("passwordConfirm");
		String pwQuizAnswer    = trim(request.getParameter("pwQuizAnswer"));
		String name            = trim(request.getParameter("name"));
		String englishName     = trim(request.getParameter("englishName"));
		String phone           = trim(request.getParameter("phone"));
		String email           = trim(request.getParameter("email"));
		boolean smsRefuse      = "Y".equals(request.getParameter("smsRefuse"));
		//html에 사용자가 입력한 값들을 받아와서
		MemberDAO dao = new MemberDAO();
		//데이터 베이스에 넘겨주기위한 메서드가 있는 dao로 전달

		Map<String, String> errors = new LinkedHashMap<>();
		//사용자가 여러 부분에서 입력을 잘못했을 시에 한꺼번에 오류내용을 묶어서 보여주기 위해서 선언하는 객체
		//링크를 사용해서 여러개의 오류를 묶을수가 있고, 맵을 사용했기에 jsp에서 쉽게 가져다 쓸수있다.

		if (loginId.isEmpty()) {
			//아무것도 입력이 안되어있다면.
			errors.put("loginId", "아이디를 입력해 주세요.");
		} else if (!ID_PATTERN.matcher(loginId).matches()) {
			//위에서 선언한 PATTERN에서 사용자가 입력한 아이디가 기준에서 벗어나지 않았는지 체크
			//#$#$^#$% 같이 요상한 특수문자로 아이디를 못만들게끔 한다
			errors.put("loginId", "아이디는 영문, 숫자 조합 4~20자로 입력해 주세요.");
		} else if (dao.idCheck(loginId)) {
			errors.put("loginId", "이미 사용 중인 아이디입니다.");
			//중복된 아이디를 체크하는  dao의 메서드를 실행
		}

		if (password == null || password.isEmpty()) {
			errors.put("password", "비밀번호를 입력해 주세요.");
		} else if (password.length() < 8 || password.length() > 72) {
			errors.put("password", "비밀번호는 8자 이상 72자 이하로 입력해 주세요.");
		} else if (!password.equals(passwordConfirm)) {
			errors.put("passwordConfirm", "비밀번호가 일치하지 않습니다.");
		}

		// (추가) 비밀번호 퀴즈 답 : 비밀번호 찾기에 꼭 필요하다
		if (pwQuizAnswer.isEmpty()) {
			errors.put("pwQuizAnswer", "비밀번호 퀴즈 답을 입력해 주세요.");
		} else if (pwQuizAnswer.length() > PwQuiz.MAX_LENGTH) {
			//PwQuiz라는 클래스에서 MAX_LENGTH라는 상수를 가져와서 비밀번호 입력 길이를 지정
			//이런식으로 하는 이유는 PwQuiz에서 아이디체크 뿐만 아니라 비밀번호체크 기능도 다같이 넣어서 만들기 위함
			errors.put("pwQuizAnswer", "비밀번호 퀴즈 답은 " + PwQuiz.MAX_LENGTH + "자 이내로 입력해 주세요.");
		}

		if (name.isEmpty()) {
			errors.put("name", "이름을 입력해 주세요.");
		} else if (name.length() > 20) {
			errors.put("name", "이름은 20자 이내로 입력해 주세요.");
		}

		if (englishName.length() > 50) {
			errors.put("englishName", "영문 이름은 50자 이내로 입력해 주세요.");
		}
		if (!phone.isEmpty() && !PHONE_PATTERN.matcher(phone).matches()) {
			errors.put("phone", "휴대전화 번호 형식을 확인해 주세요.");
		}
		if (!email.isEmpty() && (email.length() > 100 || !EMAIL_PATTERN.matcher(email).matches())) {
			errors.put("email", "이메일 형식을 확인해 주세요.");
		}

		if (!errors.isEmpty()) {
			request.setAttribute("errors", errors);
			return true;
		}
		//만약 위에서 입력한 것에서 문제가 생기면(에러가 있다면) 회원가입을 중단하고 에러 메시지들을 챙겨서
		//사용자에게 무엇이 문제다라고 보여주고 다시 회원가입 페이지를 띄워라

		
		//사용자가 입력한 폼이 정상이라면 DB에 저장하는 과정을 거친다
		MemberDTO dto = new MemberDTO();
		dto.setLoginId(loginId);
		dto.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt()));
		//비밀번호는 해시로 섞어서 저장한다
		dto.setPwQuizAnswerHash(PwQuiz.hash(pwQuizAnswer));
		//비밀번호 찾는데 사용할 대답도 해시로 섞어서 저장
		dto.setName(name);
		dto.setEnglishName(englishName.isEmpty() ? null : englishName);
		dto.setPhone(phone.isEmpty() ? null : phone);
		dto.setEmail(email.isEmpty() ? null : email);
		//영어명,전화번호,이메일은 필수 사항이 아니라서 만약 입력을 안했으면 null로 저장한다
		dto.setSmsRefuse(smsRefuse);
		//광고 수신같은거 동의하냐.

		long id = dao.nextId();
		//DB에서 다음에 가입할 회원의 숫자 ID를 가져온다.
		//만약 해당 사이트에 가입된 사람의 수가 3100명이면 3101번쨰를 가져와서 해당 회원을 등록
		if (id < 0) {
			//dao의 nextId란느 메서드를 돌렸을때 전달받은 값이 -1이면 DB연동중에 문제가 생겨서 에러가 터진거기에
			//아래의 에러내용을 보여주고 다시 회원가입 폼을 연다
			errors.put("system", "회원가입 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
			request.setAttribute("errors", errors);
			return true;
		}
		String serial = String.format("%07d", id);
		//만약 가입된 아이디 번호가 5라면 0000005 로써 저장되도록 하는 방법
		dto.setId(id);
		//실제 데이터베이스에 사용할 기본키로 쓸 숫자를 지정 (예:5)
		dto.setMailboxNo("KR" + serial);
		//직구 사이트에서 쓰일 나의 고유 가상 사서함 번호 생성(KR0000005)같은
		dto.setMemberNo(serial);
		//사이트에서 내 정보에 표현될 고유 회원번호 (0000005님) 같은

		
		//위에서 열심히 담은 dto를 이제 DB에 넣기위해 dao로써 보낸다
		int result = dao.memberInsert(dto);
		
		//dao에서 문제가 생겨 돌아왔다면.
		if (result == 0) {
			errors.put("system", "회원가입 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
			request.setAttribute("errors", errors);
			return true;
		}

		response.sendRedirect(request.getContextPath() + "/member/login?joined=1");
		//무사히 회원가입이 끝났으면 이제 로그인하라고 로그인 창을 띄워준다
		return false;
		//컨트롤러 종료
	}

	private static String trim(String s) {
		return s == null ? "" : s.trim();
		//위에서 trim이란 함수를 만나면 이쪽으로 연결되어서 공백을 다 제거하고 null인지 아닌지 판단한다.
		//만약 아무것도 없는 null값이라면 null포인터 예외 에러를 막기위해서 임의로 공백을 대신 대입한다.
	}
}
