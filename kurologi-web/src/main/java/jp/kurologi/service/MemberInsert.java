package jp.kurologi.service;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

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
	private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
	private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9\\-+() ]{7,30}$");

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			return true;
		}

		String loginId         = trim(request.getParameter("loginId"));
		String password        = request.getParameter("password");
		String passwordConfirm = request.getParameter("passwordConfirm");
		String pwQuizAnswer    = trim(request.getParameter("pwQuizAnswer"));
		String name            = trim(request.getParameter("name"));
		String englishName     = trim(request.getParameter("englishName"));
		String phone           = trim(request.getParameter("phone"));
		String email           = trim(request.getParameter("email"));
		boolean smsRefuse      = "Y".equals(request.getParameter("smsRefuse"));

		MemberDAO dao = new MemberDAO();

		Map<String, String> errors = new LinkedHashMap<>();

		if (loginId.isEmpty()) {
			errors.put("loginId", "아이디를 입력해 주세요.");
		} else if (!ID_PATTERN.matcher(loginId).matches()) {
			errors.put("loginId", "아이디는 영문, 숫자 조합 4~20자로 입력해 주세요.");
		} else if (dao.idCheck(loginId)) {
			errors.put("loginId", "이미 사용 중인 아이디입니다.");
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

		MemberDTO dto = new MemberDTO();
		dto.setLoginId(loginId);
		dto.setPasswordHash(PasswordHasher.hash(password));
		dto.setPwQuizAnswerHash(PwQuiz.hash(pwQuizAnswer));
		dto.setName(name);
		dto.setEnglishName(englishName.isEmpty() ? null : englishName);
		dto.setPhone(phone.isEmpty() ? null : phone);
		dto.setEmail(email.isEmpty() ? null : email);
		dto.setSmsRefuse(smsRefuse);

		long id = dao.nextId();
		if (id < 0) {
			errors.put("system", "회원가입 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
			request.setAttribute("errors", errors);
			return true;
		}
		String serial = String.format("%07d", id);
		dto.setId(id);
		dto.setMailboxNo("KR" + serial);
		dto.setMemberNo(serial);

		int result = dao.memberInsert(dto);
		if (result == 0) {
			errors.put("system", "회원가입 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
			request.setAttribute("errors", errors);
			return true;
		}

		response.sendRedirect(request.getContextPath() + "/member/login?joined=1");
		return false;
	}

	private static String trim(String s) {
		return s == null ? "" : s.trim();
	}
}
