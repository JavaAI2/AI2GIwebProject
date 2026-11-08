package jp.kurologi.service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.MemberDTO;
import jp.kurologi.repository.MemberDAO;
import jp.kurologi.web.Session;

/**
 * [시험용] 결제 화면의 "예치금 충전하기" 버튼 서비스 (POST 로만 동작)
 * 누를 때마다 예치금 30,000원이 충전된다. 결제 프로그램 연동은 없다.
 */
public class ChargeDepositCommand implements Command {

	/** 한 번 누를 때 충전되는 시험용 금액 */
	private static final long TEST_CHARGE_AMOUNT = 30_000L;

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String back = request.getContextPath() + "/mypage/payment";

		if (!"POST".equalsIgnoreCase(request.getMethod())) {
			response.sendRedirect(back);
			return false;
		}

		MemberDTO member = (MemberDTO) request.getAttribute("member");

		if (new MemberDAO().addDeposit(member.getId(), TEST_CHARGE_AMOUNT) > 0) {
			Session.flash(request, "info", String.format("예치금 ₩%,d 이(가) 충전되었습니다. (시험용) 현재 예치금: ₩%,d",
					TEST_CHARGE_AMOUNT, member.getDeposit() + TEST_CHARGE_AMOUNT));
		} else {
			Session.flash(request, "error", "예치금을 충전하지 못했습니다.");
		}

		response.sendRedirect(back);
		return false;
	}
}
