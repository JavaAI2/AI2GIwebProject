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
import jp.kurologi.web.Session;

/**
 * 계정관리 서비스 (회원정보 수정)
 *
 *   GET  : 계정관리 화면만 보여준다 (true -> account.jsp)
 *   POST : 입력값 검증 -> DAO 로 수정 -> 안내 메시지를 담고 같은 화면으로 redirect (false)
 *          검증에 실패하면 request 에 "errors" 를 담고 400 상태로 화면을 다시 보여준다 (true)
 *
 * 비밀번호 칸을 비워 두면 비밀번호는 바꾸지 않는다.
 */
public class AccountCommand implements Command {

	private static final Pattern ENGLISH_NAME = Pattern.compile("^[A-Z][A-Z .,'-]{1,49}$");
	private static final Pattern PHONE        = Pattern.compile("^0\\d{1,2}-?\\d{3,4}-?\\d{4}$");
	private static final Pattern PASSWORD     = Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d).{8,20}$");

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// 컨트롤러가 담아 둔 최신 회원정보
		MemberDTO member = (MemberDTO) request.getAttribute("member");

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			return true;
		}

		// ---- POST : 화면에서 입력한 값 ----
		String englishName   = trim(request.getParameter("englishName")).toUpperCase();   // 대문자로 통일
		String phone         = trim(request.getParameter("phone"));
		String newPassword   = request.getParameter("newPassword") == null ? "" : request.getParameter("newPassword");
		String newPasswordConfirm = request.getParameter("newPasswordConfirm");
		boolean smsRefuse    = request.getParameter("smsRefuse") != null;
		String memberType    = "BUSINESS".equals(request.getParameter("memberType")) ? "BUSINESS" : "PERSONAL";

		// ---- 입력값 검증 ----
		Map<String, String> errors = new LinkedHashMap<>();

		if (!ENGLISH_NAME.matcher(englishName).matches()) {
			errors.put("englishName", "영문이름은 영문 대문자와 공백으로 2~50자 입력해 주세요. (사서함 수취인으로 사용됩니다)");
		}
		if (!phone.isEmpty() && !PHONE.matcher(phone).matches()) {
			errors.put("phone", "휴대폰 번호 형식이 올바르지 않습니다. 예) 010-1234-5678");
		}
		if (!newPassword.isEmpty()) {
			if (!PASSWORD.matcher(newPassword).matches()) {
				errors.put("newPassword", "비밀번호는 영문과 숫자를 포함해 8~20자로 입력해 주세요.");
			} else if (!newPassword.equals(newPasswordConfirm)) {
				errors.put("newPasswordConfirm", "비밀번호 확인이 일치하지 않습니다.");
			}
		}

		if (!errors.isEmpty()) {
			request.setAttribute("errors", errors);
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			return true;   // 입력한 값이 사라지지 않도록 화면을 다시 보여준다
		}

		// ---- DAO 로 DB 수정 ----
		MemberDAO dao = new MemberDAO();
		int result = dao.updateInfo(member.getId(), englishName, phone.isEmpty() ? null : phone, smsRefuse, memberType);

		if (result > 0 && !newPassword.isEmpty()) {
			result = dao.updatePassword(member.getId(), PasswordHasher.hash(newPassword));   // 암호화해서 저장
		}

		// 한 번만 보이는 안내 메시지 (화면에서 보여준 뒤 자동으로 사라진다)
		if (result > 0) {
			Session.flash(request, "info", "회원정보가 수정되었습니다.");
		} else {
			Session.flash(request, "error", "회원정보를 저장하지 못했습니다. 잠시 후 다시 시도해 주세요.");
		}

		// 수정 후 새로고침해도 다시 수정 요청이 가지 않도록 redirect 한다
		response.sendRedirect(request.getContextPath() + "/mypage/account");
		return false;
	}

	private static String trim(String s) {
		return s == null ? "" : s.trim();
	}
}
