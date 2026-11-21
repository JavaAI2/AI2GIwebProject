package jp.kurologi.service;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.MemberDTO;
import jp.kurologi.repository.MemberDAO;
import jp.kurologi.web.Session;

/**
 * [시연용] 예치금 충전 서비스
 * 실제 은행 거래 없이, 충전 신청을 하면 DB(KURO_MEMBER.DEPOSIT)의 예치금에 금액을 더한다.
 *
 *   GET  : 충전 화면 (true -> deposit.jsp)
 *   POST : 입력 확인 -> DAO 로 예치금 증가 -> 안내 메시지를 담아 같은 화면으로 redirect (false)
 *          입력이 잘못되면 request 에 "errors" 를 담고 화면을 다시 보여준다 (true)
 */
public class DepositCharge implements Command {

	private static final long MIN_AMOUNT = 1_000L;
	private static final long MAX_AMOUNT = 1_000_000L;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		MemberDTO member = (MemberDTO) request.getAttribute("member");

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			return true;
		}

		// ---- 충전 신청(POST) ----
		String method = request.getParameter("method");
		String depositor = request.getParameter("depositorName") == null ? "" : request.getParameter("depositorName").trim();
		long amount = parseLong(request.getParameter("amount"));

		Map<String, String> errors = new LinkedHashMap<>();
		if (!"BANK".equals(method)) {
			errors.put("method", "지금은 무통장입금만 선택할 수 있습니다.");
		}
		if (amount < MIN_AMOUNT || amount > MAX_AMOUNT || amount % 1_000 != 0) {
			errors.put("amount", "충전 금액은 1,000원 단위로 1,000원 ~ 1,000,000원 사이로 선택해 주세요.");
		}
		if (depositor.isEmpty()) {
			errors.put("depositorName", "입금자명을 입력해 주세요.");
		} else if (depositor.length() > 20) {
			errors.put("depositorName", "입금자명은 20자 이내로 입력해 주세요.");
		}

		if (!errors.isEmpty()) {
			request.setAttribute("errors", errors);
			return true;   // 입력 화면을 다시 보여준다
		}

		// 시연: 입금 확인을 기다리지 않고 바로 예치금에 더한다
		if (new MemberDAO().addDeposit(member.getId(), amount) > 0) {
			Session.flash(request, "info", String.format(
					"₩%,d 충전이 완료되었습니다. (무통장입금 시연) 현재 예치금: ₩%,d", amount, member.getDeposit() + amount));
		} else {
			Session.flash(request, "error", "충전 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
		}
		response.sendRedirect(request.getContextPath() + "/mypage/deposit");
		return false;
	}

	// 숫자가 아니면 -1
	private static long parseLong(String s) {
		try {
			return s == null ? -1 : Long.parseLong(s.trim());
		} catch (NumberFormatException e) {
			return -1;
		}
	}
}
