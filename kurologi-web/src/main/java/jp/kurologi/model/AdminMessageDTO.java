package jp.kurologi.model;

/**
 * 관리자 알림 발송 이력용 — MessageDTO 에 "받는 회원 표시"를 더한 것 (MessageDTO 는 그대로 둔다)
 */
public class AdminMessageDTO extends MessageDTO {

	private String memberText;   // 화면용 — "이름 (로그인아이디)", 회원이 삭제되어 없으면 null (DAO 가 JOIN 으로 채움)

	public String getMemberText() { return memberText; }
	public void setMemberText(String memberText) { this.memberText = memberText; }
}