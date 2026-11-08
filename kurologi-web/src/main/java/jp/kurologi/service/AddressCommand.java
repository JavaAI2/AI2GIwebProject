package jp.kurologi.service;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.Address;
import jp.kurologi.model.MemberDTO;
import jp.kurologi.repository.AddressDAO;
import jp.kurologi.web.Session;

/**
 * 주소관리 서비스 (나의 주소록)
 *
 *   GET  : 주소 목록 (?field=name|address&q=검색어&page=쪽번호) (true -> address.jsp)
 *   POST : action=delete 이면 삭제, 아니면 저장(id 가 0 이면 새 주소, 아니면 수정)
 *          성공하면 안내 메시지를 담아 목록으로 redirect (false)
 *          입력이 잘못되면 입력값을 지우지 않도록 redirect 하지 않고 같은 화면을 다시 보여준다 (true)
 */
public class AddressCommand implements Command {

	/** 한 쪽에 보일 주소 개수 (4열 x 2줄) */
	private static final int PAGE_SIZE = 8;

	private static final Pattern ZIPCODE      = Pattern.compile("^\\d{5}$");
	private static final Pattern PHONE        = Pattern.compile("^0\\d{1,2}-?\\d{3,4}-?\\d{4}$");
	/** 개인통관고유부호: P + 숫자 12자리 */
	private static final Pattern CUSTOMS_CODE = Pattern.compile("^P\\d{12}$");

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		MemberDTO member = (MemberDTO) request.getAttribute("member");
		long memberId = member.getId();
		AddressDAO dao = new AddressDAO();

		// ---- GET : 목록 보여주기 ----
		if ("GET".equalsIgnoreCase(request.getMethod())) {
			loadList(request, dao, memberId);
			return true;
		}

		// ---- POST : 삭제 ----
		if ("delete".equals(request.getParameter("action"))) {
			if (dao.delete(memberId, parseLong(request.getParameter("id"), 0)) > 0) {
				Session.flash(request, "info", "주소를 삭제했습니다.");
			} else {
				Session.flash(request, "error", "주소를 찾을 수 없습니다.");
			}
			response.sendRedirect(request.getContextPath() + "/mypage/address");
			return false;
		}

		// ---- POST : 저장 (새 주소 / 수정) ----
		// 화면에서 입력한 값을 Address 객체(DTO)에 담는다
		Address form = new Address();
		form.setId(parseLong(request.getParameter("id"), 0));
		form.setMemberId(memberId);
		form.setName(trim(request.getParameter("name")));
		form.setZipcode(trim(request.getParameter("zipcode")));
		form.setAddress1(trim(request.getParameter("address1")));
		form.setAddress2(trim(request.getParameter("address2")));
		form.setCountry(trim(request.getParameter("country")).isEmpty() ? "South Korea" : trim(request.getParameter("country")));
		form.setPhone(trim(request.getParameter("phone")));
		form.setCustomsCode(trim(request.getParameter("customsCode")).toUpperCase());

		// 입력값 검증
		Map<String, String> errors = new LinkedHashMap<>();
		if (form.getName().isEmpty() || form.getName().length() > 30) {
			errors.put("name", "받는 사람 이름을 30자 이내로 입력해 주세요.");
		}
		if (!ZIPCODE.matcher(form.getZipcode()).matches()) {
			errors.put("zipcode", "우편번호 5자리를 입력해 주세요.");
		}
		if (form.getAddress1().isEmpty()) {
			errors.put("address1", "주소를 입력해 주세요.");
		}
		if (!PHONE.matcher(form.getPhone()).matches()) {
			errors.put("phone", "전화번호 형식이 올바르지 않습니다. 예) 010-1234-5678");
		}
		if (!CUSTOMS_CODE.matcher(form.getCustomsCode()).matches()) {
			errors.put("customsCode", "개인통관고유부호는 P로 시작하는 13자리입니다. 예) P123456789012");
		}

		if (!errors.isEmpty()) {
			// 입력했던 값과 칸별 오류를 담아서 같은 화면을 다시 보여준다
			request.setAttribute("errors", errors);
			request.setAttribute("form", form);
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			loadList(request, dao, memberId);
			return true;
		}

		// DAO 로 저장 : id 가 0 이면 insert, 아니면 update
		boolean isNew = form.getId() == 0;
		int result = isNew ? dao.insert(form) : dao.update(form);

		if (result > 0) {
			Session.flash(request, "info", isNew ? "새 주소를 추가했습니다." : "주소를 수정했습니다.");
		} else {
			Session.flash(request, "error", isNew ? "주소를 저장하지 못했습니다." : "주소를 찾을 수 없습니다.");
		}
		response.sendRedirect(request.getContextPath() + "/mypage/address");
		return false;
	}

	// 검색 조건에 맞는 주소 목록을 request 에 담는다 (address.jsp 가 꺼내 쓴다)
	private void loadList(HttpServletRequest request, AddressDAO dao, long memberId) {
		String field = "address".equals(request.getParameter("field")) ? "address" : "name";
		String q = request.getParameter("q");
		int page = (int) parseLong(request.getParameter("page"), 1);

		request.setAttribute("field", field);
		request.setAttribute("q", q == null ? "" : q);
		request.setAttribute("result", dao.search(memberId, field, q, page, PAGE_SIZE));
	}

	private static String trim(String s) {
		return s == null ? "" : s.trim();
	}

	// 숫자가 아니면 fallback 값
	private static long parseLong(String s, long fallback) {
		try {
			return s == null ? fallback : Long.parseLong(s.trim());
		} catch (NumberFormatException e) {
			return fallback;
		}
	}
}
