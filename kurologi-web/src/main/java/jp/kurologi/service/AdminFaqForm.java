package jp.kurologi.service;

import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import jp.kurologi.model.FaqDTO;

/** 관리자 FAQ 등록/수정 폼 값 읽기 · 검사 (AdminFaqWrite, AdminFaqUpdate 가 같이 쓴다. 같은 패키지 안에서만 사용) */
final class AdminFaqForm {

	static final int CATEGORY_MAX = 50;          // COMMUNITY_FAQ.CATEGORY 는 50자
	static final int QUESTION_MAX = 300;         // QUESTION 은 300자
	static final int ANSWER_MAX_BYTES = 4000;    // ANSWER 는 4000바이트 (UTF-8 이라 한글 약 1,300자)
	static final int SORT_MAX = 99999;           // SORT_ORDER 는 NUMBER(5)

	private AdminFaqForm() {}

	/**
	 * 폼 값을 읽어 FaqDTO 로 만든다. (노출 체크박스는 체크했을 때만 "Y" 가 넘어온다)
	 * 표시 순서 입력값 원본은 request 의 "sortOrderText" 에 담아 둔다 (오류로 폼을 다시 보여줄 때 그대로 채우려고).
	 * 표시 순서가 0 ~ SORT_MAX 숫자가 아니면 sortOrder 를 -1 로 둔다.
	 */
	static FaqDTO read(HttpServletRequest request) {
		FaqDTO dto = new FaqDTO();
		dto.setCategory(CommunityUtil.param(request, "category"));
		dto.setQuestion(CommunityUtil.param(request, "question"));
		dto.setAnswer(CommunityUtil.param(request, "answer"));
		dto.setVisible("Y".equals(CommunityUtil.param(request, "visible")));

		String raw = CommunityUtil.param(request, "sortOrder");
		request.setAttribute("sortOrderText", raw);
		long n = CommunityUtil.parseLong(raw, -1);
		dto.setSortOrder(n < 0 || n > SORT_MAX ? -1 : (int) n);
		return dto;
	}

	/** 입력 검사. 문제가 없으면 빈 Map (Html.error 가 읽는 "errors" 와 같은 모양) */
	static Map<String, String> validate(FaqDTO dto) {
		Map<String, String> errors = new LinkedHashMap<>();

		if (dto.getCategory().isEmpty()) {
			errors.put("category", "분류를 입력해 주세요.");
		} else if (dto.getCategory().length() > CATEGORY_MAX) {
			errors.put("category", "분류는 " + CATEGORY_MAX + "자 이내로 입력해 주세요.");
		}

		if (dto.getQuestion().isEmpty()) {
			errors.put("question", "질문을 입력해 주세요.");
		} else if (dto.getQuestion().length() > QUESTION_MAX) {
			errors.put("question", "질문은 " + QUESTION_MAX + "자 이내로 입력해 주세요.");
		}

		if (dto.getAnswer().isEmpty()) {
			errors.put("answer", "답변을 입력해 주세요.");
		} else if (CommunityUtil.utf8Bytes(dto.getAnswer()) > ANSWER_MAX_BYTES) {
			errors.put("answer", "답변이 너무 깁니다. 한글 기준 약 1,300자 이내로 입력해 주세요.");
		}

		if (dto.getSortOrder() < 0) {
			errors.put("sortOrder", "표시 순서는 0 ~ " + SORT_MAX + " 사이의 숫자로 입력해 주세요.");
		}
		return errors;
	}
}