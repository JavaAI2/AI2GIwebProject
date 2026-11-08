package jp.kurologi.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import util.DBmanager;

/**
 * 종합현황(dashboard.jsp)에 보여 줄 값을 DB 에서 직접 읽는다.
 *
 *   공지사항        : COMMUNITY_POST  (BOARD_TYPE = 'NOTICE')  최근 글
 *   나의 1:1 질문   : COMMUNITY_POST  (BOARD_TYPE = 'QNA', 내가 쓴 글) 최근 글
 *   자주하는 질문   : COMMUNITY_FAQ   (VISIBLE_YN = 'Y') 분류별
 *   배송 중 주문 수 : BUY_ORDER       (출고완료 · 국내 배송 중)  -> "현지 반품신청" 버튼의 숫자
 *
 * JSP 가 직접 부르므로 /status/dashboard 를 처리하는 서블릿을 고치지 않아도 된다.
 * 테이블이 없거나 오류가 나도 종합현황이 깨지지 않도록 빈 목록 · 0 을 돌려주고, 오류는 서버 콘솔에 남긴다.
 */
public final class DashboardBoard {

	private DashboardBoard() { }

	/** 공지사항 한 줄 */
	public record NoticeRow(long postId, String title, String date, boolean fresh) { }

	/** 나의 1:1 질문 한 줄 */
	public record QnaRow(long postId, String title, boolean answered) { }

	/** 자주하는 질문 한 건 */
	public record FaqRow(String question, String answer) { }

	/** 자주하는 질문 분류 하나 (예: 회원/기타) */
	public record FaqGroup(String category, List<FaqRow> items) { }

	/** 최근 공지사항 (최신 순, 최근 3일 안의 글은 N 표시) */
	public static List<NoticeRow> notices(int limit) {

		String sql = "SELECT POST_ID, TITLE, TO_CHAR(CREATED_AT, 'YYYY-MM-DD') AS D, "
				+ "CASE WHEN CREATED_AT >= SYSDATE - 3 THEN 1 ELSE 0 END AS IS_NEW "
				+ "FROM (SELECT POST_ID, TITLE, CREATED_AT FROM COMMUNITY_POST "
				+ "      WHERE BOARD_TYPE = 'NOTICE' ORDER BY POST_ID DESC) "
				+ "WHERE ROWNUM <= ?";

		List<NoticeRow> list = new ArrayList<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, limit);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(new NoticeRow(rs.getLong("POST_ID"), rs.getString("TITLE"),
							rs.getString("D"), rs.getInt("IS_NEW") == 1));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 내가 쓴 1:1 문의 (최신 순) */
	public static List<QnaRow> myQuestions(long memberId, int limit) {

		String sql = "SELECT POST_ID, TITLE, ANSWER_YN "
				+ "FROM (SELECT POST_ID, TITLE, ANSWER_YN FROM COMMUNITY_POST "
				+ "      WHERE BOARD_TYPE = 'QNA' AND WRITER_ID = ? ORDER BY POST_ID DESC) "
				+ "WHERE ROWNUM <= ?";

		List<QnaRow> list = new ArrayList<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, memberId);
			ps.setInt(2, limit);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(new QnaRow(rs.getLong("POST_ID"), rs.getString("TITLE"),
							"Y".equals(rs.getString("ANSWER_YN"))));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	/** 자주하는 질문 : 분류별로 묶어서 (분류 순서 = 그 분류의 가장 작은 SORT_ORDER 순), 분류마다 perCategory 건까지 */
	public static List<FaqGroup> faqGroups(int perCategory) {

		String sql = "SELECT CATEGORY, QUESTION, ANSWER FROM COMMUNITY_FAQ "
				+ "WHERE VISIBLE_YN = 'Y' ORDER BY SORT_ORDER, FAQ_ID";

		Map<String, List<FaqRow>> map = new LinkedHashMap<>();
		try (Connection conn = DBmanager.getInstance();
				PreparedStatement ps = conn.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				List<FaqRow> items = map.computeIfAbsent(rs.getString("CATEGORY"), k -> new ArrayList<>());
				if (items.size() < perCategory) {
					items.add(new FaqRow(rs.getString("QUESTION"), rs.getString("ANSWER")));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		List<FaqGroup> groups = new ArrayList<>();
		for (Map.Entry<String, List<FaqRow>> e : map.entrySet()) {
			groups.add(new FaqGroup(e.getKey(), e.getValue()));
		}
		return groups;
	}

	/** 현지 반품신청(환불)할 수 있는 내 주문 수. 출고 이후에는 환불할 수 없으므로 항상 0 */
	public static int shippingCount(long memberId) {

		if (true) {
			return 0;
		}

		String sql = "SELECT COUNT(*) FROM BUY_ORDER WHERE MEMBER_ID = ? AND STATUS = 'DELIVERING'";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setLong(1, memberId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return rs.getInt(1);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}
}
