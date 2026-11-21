package jp.kurologi.model;

//COMMUNITY_MESSAGE 테이블의 한 행(알림메세지 1건)을 담는 바구니(DTO)

public class MessageDTO {

	private long messageId;   // MESSAGE_ID — 알림 번호(SEQ_COMMUNITY_MESSAGE)
	private long memberId;    // MEMBER_ID — 받는 회원 번호(KURO_MEMBER.ID)
	private String msgType;   // MSG_TYPE — 구분(입고 / 출고 / 배송 등)
	private String content;   // CONTENT — 내용
	private String sentAt;    // SENT_AT — 발송일시(문자열로 변환해서 받음)
	private boolean read;     // READ_YN — 확인(읽음) 여부(Y/N)

	public long getMessageId() { return messageId; }
	public void setMessageId(long messageId) { this.messageId = messageId; }
	public long getMemberId() { return memberId; }
	public void setMemberId(long memberId) { this.memberId = memberId; }
	public String getMsgType() { return msgType; }
	public void setMsgType(String msgType) { this.msgType = msgType; }
	public String getContent() { return content; }
	public void setContent(String content) { this.content = content; }
	public String getSentAt() { return sentAt; }
	public void setSentAt(String sentAt) { this.sentAt = sentAt; }
	public boolean isRead() { return read; }
	public void setRead(boolean read) { this.read = read; }
}