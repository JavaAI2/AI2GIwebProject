package jp.kurologi.model;

//COMMUNITY_POST 테이블의 한 행(공지사항 1건 또는 1:1 문의 1건)을 담는 바구니(DTO)
//컬럼명 SNAKE_CASE -> 필드명 camelCase 로 1:1 대응시켰다
//날짜는 형변환이 귀찮으니 DAO 에서 to_char 로 바꿔 String 으로 받는다 (MemberDTO 와 같은 방식)

public class PostDTO {

	private long postId;          // POST_ID — 글 번호(SEQ_COMMUNITY_POST)
	private String boardType;     // BOARD_TYPE — NOTICE(공지사항) / QNA(1:1게시판)
	private String title;         // TITLE — 제목
	private String content;       // CONTENT — 내용
	private Long writerId;        // WRITER_ID — 작성 회원 번호(KURO_MEMBER.ID). NULL = 관리자 작성이라 long 이 아니라 Long
	private String writerName;    // 화면용 — KURO_MEMBER.NAME (DAO 가 JOIN 으로 채움, 관리자 글이면 null)
	private int viewCount;        // VIEW_COUNT — 조회수
	private int likeCount;        // LIKE_COUNT — 좋아요 수 (현재 5개 화면에서는 안 씀)
	private boolean answered;     // ANSWER_YN — 답변 완료 여부(Y/N), 1:1게시판에서만 의미 있음
	private String createdAt;     // CREATED_AT — 등록일(문자열로 변환해서 받음)
	private String updatedAt;     // UPDATED_AT — 수정일(없으면 null)
	private boolean newPost;      // 화면용 — 최근에 등록된 글이면 true (목록의 N 배지), DAO 가 계산

	public long getPostId() { return postId; }
	public void setPostId(long postId) { this.postId = postId; }
	public String getBoardType() { return boardType; }
	public void setBoardType(String boardType) { this.boardType = boardType; }
	public String getTitle() { return title; }
	public void setTitle(String title) { this.title = title; }
	public String getContent() { return content; }
	public void setContent(String content) { this.content = content; }
	public Long getWriterId() { return writerId; }
	public void setWriterId(Long writerId) { this.writerId = writerId; }
	public String getWriterName() { return writerName; }
	public void setWriterName(String writerName) { this.writerName = writerName; }
	public int getViewCount() { return viewCount; }
	public void setViewCount(int viewCount) { this.viewCount = viewCount; }
	public int getLikeCount() { return likeCount; }
	public void setLikeCount(int likeCount) { this.likeCount = likeCount; }
	public boolean isAnswered() { return answered; }
	public void setAnswered(boolean answered) { this.answered = answered; }
	public String getCreatedAt() { return createdAt; }
	public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
	public String getUpdatedAt() { return updatedAt; }
	public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
	public boolean isNewPost() { return newPost; }
	public void setNewPost(boolean newPost) { this.newPost = newPost; }
}