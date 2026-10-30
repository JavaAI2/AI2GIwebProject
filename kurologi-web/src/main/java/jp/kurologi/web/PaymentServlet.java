package jp.kurologi.web;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.Member;
import jp.kurologi.model.Payment;
import jp.kurologi.service.PaymentService.PayRequest;
import jp.kurologi.service.ValidationException;

/**
 * 결제 관리 (마이페이지 > 결제방법) — [시험용]
 *   GET  /mypage/payment                 비용결제 탭 (결제 대기건)   ?tab=history 이면 결제내역 탭
 *   POST /mypage/payment                 선택한 대기건을 예치금으로 결제 -> 결제내역 탭으로 이동
 *   POST /mypage/payment/charge-deposit  예치금 30,000원 충전 (시험용)
 */
@WebServlet({"/mypage/payment", "/mypage/payment/charge-deposit"})
public class PaymentServlet extends BaseServlet {
    private static final long serialVersionUID = 1L;

    /** 한 번 누를 때 충전되는 시험용 금액 */
    private static final long TEST_CHARGE_AMOUNT = 30_000L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Member m = member(req);
        String tab = "history".equals(req.getParameter("tab")) ? "history" : "pending";

        req.setAttribute("tab", tab);
        req.setAttribute("charges", app().payments.pendingCharges(m.getId()));
        req.setAttribute("payments", app().payments.history(m.getId()));
        render(req, res, "mypage/payment");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        if (req.getServletPath().endsWith("/charge-deposit")) {
            chargeDeposit(req, res);
        } else {
            pay(req, res);
        }
    }

    /** 예치금 충전 (시험용) */
    private void chargeDeposit(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Member m = member(req);
        try {
            long now = app().payments.chargeTestDeposit(m.getId(), TEST_CHARGE_AMOUNT);
            Session.flash(req, "info", String.format("예치금 ₩%,d 이(가) 충전되었습니다. (시험용) 현재 예치금: ₩%,d",
                    TEST_CHARGE_AMOUNT, now));
        } catch (ValidationException e) {
            Session.flash(req, "error", message(e, "예치금을 충전하지 못했습니다."));
        }
        redirect(req, res, "/mypage/payment");
    }

    /** 선택한 대기건을 예치금으로 결제 */
    private void pay(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Member m = member(req);

        List<Long> ids = new ArrayList<>();
        String[] raw = req.getParameterValues("chargeId");
        if (raw != null) {
            for (String s : raw) {
                long id = parseLong(s, -1);
                if (id > 0) ids.add(id);
            }
        }

        try {
            // 결제수단(method)을 무엇으로 골랐든 예치금으로 결제한다 (시험용)
            Payment p = app().payments.pay(m.getId(), new PayRequest(ids, Payment.Method.DEPOSIT, 0, null));
            long left = member(req).getDeposit();
            Session.flash(req, "info", String.format("₩%,d 결제가 완료되었습니다. (예치금 사용) 남은 예치금: ₩%,d",
                    p.getTotalAmount(), left));
            redirect(req, res, "/mypage/payment?tab=history");
        } catch (ValidationException e) {
            Session.flash(req, "error", message(e, "결제할 수 없습니다."));
            redirect(req, res, "/mypage/payment");
        }
    }

    private static String message(ValidationException e, String fallback) {
        return e.getMessage() == null || e.getMessage().isBlank() ? fallback : e.getMessage();
    }
}
