package jp.kurologi.model;

/** STOCK_ORDER 테이블 1행 = 재고구매신청 1건 */
public class StockOrderDTO {

	private long sorderId;   // SORDER_ID
	private String orderNo;   // ORDER_NO — 신청번호
	private long stockId;   // STOCK_ID
	private long memberId;   // MEMBER_ID
	private String recvName;   // RECV_NAME — 받는 사람
	private String mobile;   // MOBILE — 휴대전화
	private String postcode;   // POSTCODE
	private String addr1;   // ADDR1 — 주소
	private String addr2;   // ADDR2 — 상세주소
	private String deliverNote;   // DELIVER_NOTE — 배송 요청사항
	private int qty;   // QTY — 신청 수량
	private long totalPrice;   // TOTAL_PRICE — 예상 금액(원)
	private String createdAt;   // 신청일(화면 표시용)
	private String itemName;   // 신청한 상품명(목록 조회 때 조인으로 채움)

	public long getSorderId() {
		return sorderId;
	}

	public void setSorderId(long sorderId) {
		this.sorderId = sorderId;
	}

	public String getOrderNo() {
		return orderNo;
	}

	public void setOrderNo(String orderNo) {
		this.orderNo = orderNo;
	}

	public long getStockId() {
		return stockId;
	}

	public void setStockId(long stockId) {
		this.stockId = stockId;
	}

	public long getMemberId() {
		return memberId;
	}

	public void setMemberId(long memberId) {
		this.memberId = memberId;
	}

	public String getRecvName() {
		return recvName;
	}

	public void setRecvName(String recvName) {
		this.recvName = recvName;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}

	public String getPostcode() {
		return postcode;
	}

	public void setPostcode(String postcode) {
		this.postcode = postcode;
	}

	public String getAddr1() {
		return addr1;
	}

	public void setAddr1(String addr1) {
		this.addr1 = addr1;
	}

	public String getAddr2() {
		return addr2;
	}

	public void setAddr2(String addr2) {
		this.addr2 = addr2;
	}

	public String getDeliverNote() {
		return deliverNote;
	}

	public void setDeliverNote(String deliverNote) {
		this.deliverNote = deliverNote;
	}

	public int getQty() {
		return qty;
	}

	public void setQty(int qty) {
		this.qty = qty;
	}

	public long getTotalPrice() {
		return totalPrice;
	}

	public void setTotalPrice(long totalPrice) {
		this.totalPrice = totalPrice;
	}

	public String getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(String createdAt) {
		this.createdAt = createdAt;
	}

	public String getItemName() {
		return itemName;
	}

	public void setItemName(String itemName) {
		this.itemName = itemName;
	}
}
