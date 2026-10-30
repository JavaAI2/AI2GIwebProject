package jp.kurologi.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/** BUY_ORDER 테이블 1행 = 구매대행 주문서 1건 (상품 목록 items 포함) 11*/
public class BuyOrderDTO {

	private long orderId;   // ORDER_ID — 주문 고유번호(BUY_ORDER_SEQ)
	private String orderNo;   // ORDER_NO — 화면에 보이는 주문번호
	private long memberId;   // MEMBER_ID — 주문한 회원(KURO_MEMBER.ID)
	private String status;   // STATUS — WAIT 접수대기 / SUBMIT 접수신청
	private String center;   // CENTER — 물류센터 및 운송방식
	private String recvNameKo;   // RECV_NAME_KO — 받는 사람 한글
	private String recvNameEn;   // RECV_NAME_EN — 받는 사람 영문
	private String postcode;   // POSTCODE — 우편번호
	private String addr1;   // ADDR1 — 주소
	private String addr2;   // ADDR2 — 상세주소
	private String bizNo;   // BIZ_NO — 사업자번호
	private String mobile;   // MOBILE — 휴대전화
	private String deliverNote;   // DELIVER_NOTE — 배송 요청사항
	private int totalQty;   // TOTAL_QTY — 총 수량
	private BigDecimal totalYen;   // TOTAL_YEN — 총 금액(엔)
	private String addonOptions;   // ADDON_OPTIONS — 부가서비스(쉼표 구분)
	private String logisticsNote;   // LOGISTICS_NOTE — 물류 요청사항
	private boolean autoPay;   // AUTO_PAY — 예치금 자동결제
	private List<BuyOrderItemDTO> items = new ArrayList<>();   // 주문 상품 목록 (BUY_ORDER_ITEM)

	public long getOrderId() {
		return orderId;
	}

	public void setOrderId(long orderId) {
		this.orderId = orderId;
	}

	public String getOrderNo() {
		return orderNo;
	}

	public void setOrderNo(String orderNo) {
		this.orderNo = orderNo;
	}

	public long getMemberId() {
		return memberId;
	}

	public void setMemberId(long memberId) {
		this.memberId = memberId;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getCenter() {
		return center;
	}

	public void setCenter(String center) {
		this.center = center;
	}

	public String getRecvNameKo() {
		return recvNameKo;
	}

	public void setRecvNameKo(String recvNameKo) {
		this.recvNameKo = recvNameKo;
	}

	public String getRecvNameEn() {
		return recvNameEn;
	}

	public void setRecvNameEn(String recvNameEn) {
		this.recvNameEn = recvNameEn;
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

	public String getBizNo() {
		return bizNo;
	}

	public void setBizNo(String bizNo) {
		this.bizNo = bizNo;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}

	public String getDeliverNote() {
		return deliverNote;
	}

	public void setDeliverNote(String deliverNote) {
		this.deliverNote = deliverNote;
	}

	public int getTotalQty() {
		return totalQty;
	}

	public void setTotalQty(int totalQty) {
		this.totalQty = totalQty;
	}

	public BigDecimal getTotalYen() {
		return totalYen;
	}

	public void setTotalYen(BigDecimal totalYen) {
		this.totalYen = totalYen;
	}

	public String getAddonOptions() {
		return addonOptions;
	}

	public void setAddonOptions(String addonOptions) {
		this.addonOptions = addonOptions;
	}

	public String getLogisticsNote() {
		return logisticsNote;
	}

	public void setLogisticsNote(String logisticsNote) {
		this.logisticsNote = logisticsNote;
	}

	public boolean isAutoPay() {
		return autoPay;
	}

	public void setAutoPay(boolean autoPay) {
		this.autoPay = autoPay;
	}

	public List<BuyOrderItemDTO> getItems() {
		return items;
	}

	public void setItems(List<BuyOrderItemDTO> items) {
		this.items = items;
	}

	// ---- 서비스 구분 · 적용 환율 (04_ship_and_rate.sql 로 추가한 컬럼) ----
	private String serviceType = "BUY";   // SERVICE_TYPE — BUY 구매대행 / SHIP 배송대행
	private BigDecimal appliedRate;       // APPLIED_RATE — 적용한 고시환율(원/100엔). 환율 정보가 없었으면 null
	private long totalKrw;                // TOTAL_KRW — 결제 예정 금액(원)

	public String getServiceType() {
		return serviceType;
	}

	public void setServiceType(String serviceType) {
		this.serviceType = serviceType;
	}

	public BigDecimal getAppliedRate() {
		return appliedRate;
	}

	public void setAppliedRate(BigDecimal appliedRate) {
		this.appliedRate = appliedRate;
	}

	public long getTotalKrw() {
		return totalKrw;
	}

	public void setTotalKrw(long totalKrw) {
		this.totalKrw = totalKrw;
	}

	// ---- 목록 화면 전용 (BUY_ORDER 테이블 컬럼은 아니고, 조회할 때 계산해서 담는 값) ----
	private int itemCount;          // 상품 개수
	private String firstItemName;   // 첫 번째 상품명
	private String createdAt;       // 접수 일시 (화면 표시용 문자열)

	public int getItemCount() {
		return itemCount;
	}

	public void setItemCount(int itemCount) {
		this.itemCount = itemCount;
	}

	public String getFirstItemName() {
		return firstItemName;
	}

	public void setFirstItemName(String firstItemName) {
		this.firstItemName = firstItemName;
	}

	public String getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(String createdAt) {
		this.createdAt = createdAt;
	}

	// ---- 접수 이후 처리 (06_order_process.sql) ----
	private String payStatus = "UNPAID";   // PAY_STATUS — UNPAID 미결제 / PAID 결제완료

	// ---- 관리자 목록 전용 (주문한 회원 정보. 조인해서 채움) ----
	private String memberLoginId;
	private String memberName;

	public String getPayStatus() {
		return payStatus;
	}

	public void setPayStatus(String payStatus) {
		this.payStatus = payStatus;
	}

	public String getMemberLoginId() {
		return memberLoginId;
	}

	public void setMemberLoginId(String memberLoginId) {
		this.memberLoginId = memberLoginId;
	}

	public String getMemberName() {
		return memberName;
	}

	public void setMemberName(String memberName) {
		this.memberName = memberName;
	}
}
