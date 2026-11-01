package jp.kurologi.web;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.model.Waybill;
import jp.kurologi.repository.TrackingDAO;
import jp.kurologi.repository.TrackingDAO.TrackingInfo;

/**
 * [시험용] 운송장 조회 (인덱스 페이지에서 fetch 로 부른다). 결과는 JSON 으로 돌려준다.
 *   GET /track/kr?type=AIR|SEA&no=운송장번호          한국 운송장
 *   GET /track/jp?type=YAMATO|...|MEITETSU&no=번호    일본 운송장
 * 로그인하지 않아도 조회할 수 있다. (AuthFilter 가 이 주소를 막고 있다면 /track 을 공개 주소에 추가해야 한다)
 */
@WebServlet({ "/track/kr", "/track/jp" })
public class TrackServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private static final Pattern NUMBER = Pattern.compile("^[0-9A-Za-z\\-]{6,30}$");

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		req.setCharacterEncoding("UTF-8");
		res.setContentType("application/json; charset=UTF-8");
		res.setHeader("Cache-Control", "no-store");

		boolean kr = req.getServletPath().endsWith("/kr");
		String type = trim(req.getParameter("type"));
		String no = trim(req.getParameter("no"));

		if (no.isEmpty()) {
			fail(res, "운송장번호를 입력해 주세요.");
			return;
		}
		if (!NUMBER.matcher(no).matches()) {
			fail(res, "운송장번호 형식을 확인해 주세요. (영문, 숫자, - 만 6~30자)");
			return;
		}
		if (kr ? !Waybill.isKrMethod(type) : !Waybill.isJpCarrier(type)) {
			fail(res, kr ? "배송방법을 선택해 주세요." : "택배사를 선택해 주세요.");
			return;
		}

		TrackingInfo info;
		try {
			TrackingDAO dao = new TrackingDAO();
			info = kr ? dao.findKorean(type, no) : dao.findJapanese(type, no);
		} catch (RuntimeException e) {
			e.printStackTrace();
			fail(res, "운송장을 조회하지 못했습니다. 잠시 후 다시 시도해 주세요.");
			return;
		}

		if (info == null) {
			fail(res, "조회된 운송장이 없습니다. 배송방법(택배사)과 운송장번호를 확인해 주세요.");
			return;
		}

		PrintWriter out = res.getWriter();
		out.print("{\"ok\":true,\"type\":" + q(info.typeLabel())
				+ ",\"number\":" + q(info.number())
				+ ",\"status\":" + q(info.status())
				+ ",\"date\":" + q(info.paidAt()) + "}");
	}

	private static void fail(HttpServletResponse res, String message) throws IOException {
		res.getWriter().print("{\"ok\":false,\"message\":" + q(message) + "}");
	}

	private static String trim(String s) {
		return s == null ? "" : s.trim();
	}

	/** JSON 문자열로 만든다 (따옴표 · 역슬래시 · 제어문자 이스케이프) */
	private static String q(String s) {
		if (s == null) return "\"\"";
		StringBuilder sb = new StringBuilder("\"");
		for (int i = 0; i < s.length(); i++) {
			char c = s.charAt(i);
			switch (c) {
			case '"':  sb.append("\\\""); break;
			case '\\': sb.append("\\\\"); break;
			case '\n': sb.append("\\n"); break;
			case '\r': sb.append("\\r"); break;
			case '\t': sb.append("\\t"); break;
			default:
				if (c < 0x20) sb.append(String.format("\\u%04x", (int) c));
				else sb.append(c);
			}
		}
		return sb.append('"').toString();
	}
}
