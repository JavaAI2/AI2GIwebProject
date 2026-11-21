package jp.kurologi.service;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import jp.kurologi.model.PostDTO;
import jp.kurologi.repository.PostDAO;
import jp.kurologi.web.Session;

/** 커뮤니티 Command 들이 같이 쓰는 도우미 (같은 패키지 안에서만 사용) */
final class CommunityUtil {

	/** 제목 최대 글자 수 (COMMUNITY_POST.TITLE 은 200자) */
	static final int TITLE_MAX = 200;
	/** 내용 최대 바이트 수 (COMMUNITY_POST.CONTENT 는 4000바이트, DB 문자셋 UTF-8 이라 한글 1글자 = 3바이트) */
	static final int CONTENT_MAX_BYTES = 4000;

	private CommunityUtil() {}

	/** 파라미터를 읽어 앞뒤 공백을 지운다. 없으면 빈 문자열 */
	static String param(HttpServletRequest request, String name) {
		String v = request.getParameter(name);
		return v == null ? "" : v.trim();
	}

	/** 숫자로 바꾼다. 숫자가 아니면 fallback */
	static long parseLong(String s, long fallback) {
		try {
			return s == null ? fallback : Long.parseLong(s.trim());
		} catch (NumberFormatException e) {
			return fallback;
		}
	}

	/** 로그인한 회원 번호(KURO_MEMBER.ID). 로그인 전이면 -1 (컨트롤러가 먼저 막으므로 보통 일어나지 않는다) */
	static long loginId(HttpServletRequest request) {
		Long id = Session.memberId(request);
		return id == null ? -1 : id;
	}

	/** 검색 종류. allowed 에 있는 값만 인정하고, 아니면 "all"(전체) */
	static String searchType(HttpServletRequest request, String... allowed) {
		String v = param(request, "searchType");
		for (String a : allowed) {
			if (a.equals(v)) {
				return v;
			}
		}
		return "all";
	}

	/** 현재 페이지 번호. 없거나 이상한 값이면 1 */
	static int safePage(HttpServletRequest request) {
		long p = parseLong(request.getParameter("page"), 1);
		return (p < 1 || p > Integer.MAX_VALUE) ? 1 : (int) p;
	}

	/** 체크박스 등으로 여러 개 넘어온 번호들을 읽는다 (숫자가 아닌 값은 건너뛴다) */
	static List<Long> idList(HttpServletRequest request, String name) {
		List<Long> ids = new ArrayList<>();
		String[] values = request.getParameterValues(name);
		if (values != null) {
			for (String v : values) {
				long id = parseLong(v, -1);
				if (id >= 0) {
					ids.add(id);
				}
			}
		}
		return ids;
	}

	static int utf8Bytes(String s) {
		return s.getBytes(StandardCharsets.UTF_8).length;
	}

	/** 1:1 문의 제목/내용 검사. 문제가 없으면 빈 Map (Html.error 가 읽는 "errors" 와 같은 모양) */
	static Map<String, String> validatePost(String title, String content) {
		Map<String, String> errors = new LinkedHashMap<>();

		if (title.isEmpty()) {
			errors.put("title", "제목을 입력해 주세요.");
		} else if (title.length() > TITLE_MAX) {
			errors.put("title", "제목은 " + TITLE_MAX + "자 이내로 입력해 주세요.");
		}

		if (content.isEmpty()) {
			errors.put("content", "내용을 입력해 주세요.");
		} else if (utf8Bytes(content) > CONTENT_MAX_BYTES) {
			errors.put("content", "내용이 너무 깁니다. 한글 기준 약 1,300자 이내로 입력해 주세요.");
		}
		return errors;
	}

	/** 내가 쓴 1:1 문의 1건. 없거나 남의 글이면 null (남의 글인지 없는 글인지는 구분해 알려주지 않는다) */
	static PostDTO findOwnQna(long postId, long loginId) {
		PostDTO post = new PostDAO().selectOne(postId, PostDAO.TYPE_QNA);
		if (post == null || post.getWriterId() == null || post.getWriterId().longValue() != loginId) {
			return null;
		}
		return post;
	}
}