package jp.kurologi.model;

/** STOCK_ITEM 테이블 1행 = 등록한 재고 상품 1개 */
public class StockItemDTO {

	private long stockId;   // STOCK_ID
	private long memberId;   // MEMBER_ID
	private String stockNo;   // STOCK_NO — 재고번호 S000001
	private String itemName;   // ITEM_NAME — 상품명
	private String optionName;   // OPTION_NAME — 옵션
	private int qty;   // QTY — 재고수량
	private long price;   // PRICE — 판매가(원)
	private String createdAt;   // 등록일(화면 표시용)

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

	public String getStockNo() {
		return stockNo;
	}

	public void setStockNo(String stockNo) {
		this.stockNo = stockNo;
	}

	public String getItemName() {
		return itemName;
	}

	public void setItemName(String itemName) {
		this.itemName = itemName;
	}

	public String getOptionName() {
		return optionName;
	}

	public void setOptionName(String optionName) {
		this.optionName = optionName;
	}

	public int getQty() {
		return qty;
	}

	public void setQty(int qty) {
		this.qty = qty;
	}

	public long getPrice() {
		return price;
	}

	public void setPrice(long price) {
		this.price = price;
	}

	public String getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(String createdAt) {
		this.createdAt = createdAt;
	}
}
