package jp.kurologi.model;

//COMMUNITY_FAQ 테이블의 한 행(자주묻는 질문 1개)을 담는 바구니(DTO)

public class FaqDTO {

	private long faqId;          // FAQ_ID — FAQ 번호(SEQ_COMMUNITY_FAQ)
	private String category;     // CATEGORY — 분류(회원/기타, 배송신청서, 입고/출고, 배송비 ...)
	private String question;     // QUESTION — 질문
	private String answer;       // ANSWER — 답변
	private int sortOrder;       // SORT_ORDER — 같은 분류 안에서 보여줄 순서(작을수록 먼저)
	private boolean visible;     // VISIBLE_YN — 화면 노출 여부(Y/N)
	private String createdAt;    // CREATED_AT — 등록일(문자열로 변환해서 받음)

	public long getFaqId() { return faqId; }
	public void setFaqId(long faqId) { this.faqId = faqId; }
	public String getCategory() { return category; }
	public void setCategory(String category) { this.category = category; }
	public String getQuestion() { return question; }
	public void setQuestion(String question) { this.question = question; }
	public String getAnswer() { return answer; }
	public void setAnswer(String answer) { this.answer = answer; }
	public int getSortOrder() { return sortOrder; }
	public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }
	public boolean isVisible() { return visible; }
	public void setVisible(boolean visible) { this.visible = visible; }
	public String getCreatedAt() { return createdAt; }
	public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}