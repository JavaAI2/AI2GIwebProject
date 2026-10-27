package jp.kurologi.model;

//COMMUNITY_COMMENT 테이블의 한 행(댓글/답글 1건)을 담는 바구니(DTO)
//1:1게시판에서는 관리자의 답변을 이 테이블에 저장한다 (WRITER_ID 가 NULL 이면 관리자)

public class CommentDTO {

	private long commentId;       // COMMENT_ID — 댓글 번호(SEQ_COMMUNITY_COMMENT)
	private long postId;          // POST_ID — 어느 글의 댓글인지
	private Long parentId;        // PARENT_ID — NULL 이면 댓글, 값이 있으면 그 댓글에 대한 답글
	private String content;       // CONTENT — 내용
	private Long writerId;        // WRITER_ID — 작성 회원 번호(KURO_MEMBER.ID). NULL = 관리자
	private String writerName;    // 화면용 — KURO_MEMBER.NAME (DAO 가 JOIN 으로 채움)
	private boolean deleted;      // DELETED_YN — 삭제 여부(Y/N), 삭제해도 행은 남기고 화면에서만 가린다
	private String createdAt;     // CREATED_AT — 등록일시(문자열로 변환해서 받음)

	public long getCommentId() { return commentId; }
	public void setCommentId(long commentId) { this.commentId = commentId; }
	public long getPostId() { return postId; }
	public void setPostId(long postId) { this.postId = postId; }
	public Long getParentId() { return parentId; }
	public void setParentId(Long parentId) { this.parentId = parentId; }
	public String getContent() { return content; }
	public void setContent(String content) { this.content = content; }
	public Long getWriterId() { return writerId; }
	public void setWriterId(Long writerId) { this.writerId = writerId; }
	public String getWriterName() { return writerName; }
	public void setWriterName(String writerName) { this.writerName = writerName; }
	public boolean isDeleted() { return deleted; }
	public void setDeleted(boolean deleted) { this.deleted = deleted; }
	public String getCreatedAt() { return createdAt; }
	public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}