package jp.kurologi.model;

import java.math.BigDecimal;

/** BUY_ORDER_ITEM 테이블 1행 = 주문서 안의 상품 1개 */
public class BuyOrderItemDTO {

	private long itemId;   // ITEM_ID
	private long orderId;   // ORDER_ID — 어느 주문서의 상품인지
	private int itemNo;   // ITEM_NO — 상품 순번(1~20)
	private String shopSite;   // SHOP_SITE — 쇼핑몰 사이트
	private String brand;   // BRAND — 브랜드
	private String shopOrderNo;   // SHOP_ORDER_NO — 쇼핑몰 오더번호
	private String trackingNo;   // TRACKING_NO — 트래킹번호
	private String itemNameEn;   // ITEM_NAME_EN — 상품명 영문
	private boolean nameEnDirect;   // NAME_EN_DIRECT — 영문명 직접 기재(Y/N)
	private int qty;   // QTY — 수량
	private BigDecimal unitPrice;   // UNIT_PRICE — 단가(엔)
	private String color;   // COLOR — 색상
	private String itemSize;   // ITEM_SIZE — 사이즈
	private String productUrl;   // PRODUCT_URL — 상품 URL
	private String imageUrl;   // IMAGE_URL — 이미지 URL
	private String marketName;   // MARKET_NAME — 오픈마켓 이름
	private String marketOrderNo;   // MARKET_ORDER_NO — 오픈마켓 주문번호
	private long marketPrice;   // MARKET_PRICE — 오픈마켓 판매금액
	private String hsCode;   // HS_CODE
	private String marketPay;   // MARKET_PAY — 오픈마켓 결제수단

	public long getItemId() {
		return itemId;
	}

	public void setItemId(long itemId) {
		this.itemId = itemId;
	}

	public long getOrderId() {
		return orderId;
	}

	public void setOrderId(long orderId) {
		this.orderId = orderId;
	}

	public int getItemNo() {
		return itemNo;
	}

	public void setItemNo(int itemNo) {
		this.itemNo = itemNo;
	}

	public String getShopSite() {
		return shopSite;
	}

	public void setShopSite(String shopSite) {
		this.shopSite = shopSite;
	}

	public String getBrand() {
		return brand;
	}

	public void setBrand(String brand) {
		this.brand = brand;
	}

	public String getShopOrderNo() {
		return shopOrderNo;
	}

	public void setShopOrderNo(String shopOrderNo) {
		this.shopOrderNo = shopOrderNo;
	}

	public String getTrackingNo() {
		return trackingNo;
	}

	public void setTrackingNo(String trackingNo) {
		this.trackingNo = trackingNo;
	}

	public String getItemNameEn() {
		return itemNameEn;
	}

	public void setItemNameEn(String itemNameEn) {
		this.itemNameEn = itemNameEn;
	}

	public boolean isNameEnDirect() {
		return nameEnDirect;
	}

	public void setNameEnDirect(boolean nameEnDirect) {
		this.nameEnDirect = nameEnDirect;
	}

	public int getQty() {
		return qty;
	}

	public void setQty(int qty) {
		this.qty = qty;
	}

	public BigDecimal getUnitPrice() {
		return unitPrice;
	}

	public void setUnitPrice(BigDecimal unitPrice) {
		this.unitPrice = unitPrice;
	}

	public String getColor() {
		return color;
	}

	public void setColor(String color) {
		this.color = color;
	}

	public String getItemSize() {
		return itemSize;
	}

	public void setItemSize(String itemSize) {
		this.itemSize = itemSize;
	}

	public String getProductUrl() {
		return productUrl;
	}

	public void setProductUrl(String productUrl) {
		this.productUrl = productUrl;
	}

	public String getImageUrl() {
		return imageUrl;
	}

	public void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}

	public String getMarketName() {
		return marketName;
	}

	public void setMarketName(String marketName) {
		this.marketName = marketName;
	}

	public String getMarketOrderNo() {
		return marketOrderNo;
	}

	public void setMarketOrderNo(String marketOrderNo) {
		this.marketOrderNo = marketOrderNo;
	}

	public long getMarketPrice() {
		return marketPrice;
	}

	public void setMarketPrice(long marketPrice) {
		this.marketPrice = marketPrice;
	}

	public String getHsCode() {
		return hsCode;
	}

	public void setHsCode(String hsCode) {
		this.hsCode = hsCode;
	}

	public String getMarketPay() {
		return marketPay;
	}

	public void setMarketPay(String marketPay) {
		this.marketPay = marketPay;
	}
}
