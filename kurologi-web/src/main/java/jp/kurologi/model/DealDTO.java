package jp.kurologi.model;

//COMMUNITY_DEAL 테이블의 한 행(특가제품 1개)을 담는 바구니(DTO)

public class DealDTO {

	private long dealId;         // DEAL_ID — 특가제품 번호(SEQ_COMMUNITY_DEAL)
	private String name;         // NAME — 상품명
	private long priceJpy;       // PRICE_JPY — 가격(엔)
	private int minQty;          // MIN_QTY — 최소 주문 수량
	private String imagePath;    // IMAGE_PATH — 이미지 경로(없으면 null -> 화면에서 기본 아이콘)
	private boolean visible;     // VISIBLE_YN — 화면 노출 여부(Y/N)
	private String createdAt;    // CREATED_AT — 등록일(문자열로 변환해서 받음)

	public long getDealId() { return dealId; }
	public void setDealId(long dealId) { this.dealId = dealId; }
	public String getName() { return name; }
	public void setName(String name) { this.name = name; }
	public long getPriceJpy() { return priceJpy; }
	public void setPriceJpy(long priceJpy) { this.priceJpy = priceJpy; }
	public int getMinQty() { return minQty; }
	public void setMinQty(int minQty) { this.minQty = minQty; }
	public String getImagePath() { return imagePath; }
	public void setImagePath(String imagePath) { this.imagePath = imagePath; }
	public boolean isVisible() { return visible; }
	public void setVisible(boolean visible) { this.visible = visible; }
	public String getCreatedAt() { return createdAt; }
	public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}