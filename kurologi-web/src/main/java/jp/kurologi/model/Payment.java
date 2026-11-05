package jp.kurologi.model;

import java.time.LocalDateTime;
import java.util.List;

import jp.kurologi.web.Formats;

/** 결제 1건 — 대기건 여러 개를 한 번에 결제할 수 있습니다. 결제내역 탭에 표시됩니다. */
public class Payment {

    public enum Method {
        BANK("무통장입금"), CARD("신용카드(토스)"), DEPOSIT("예치금");

        private final String label;
        Method(String label) { this.label = label; }
        public String getLabel() { return label; }
    }

    public enum Status {
        AWAITING_DEPOSIT("입금확인중"), AWAITING_CARD("카드결제 진행중"), PAID("결제완료"), CANCELED("취소"),
        REFUNDED("환불완료");   // 현지 반품신청(배송 취소)으로 환불된 결제

        private final String label;
        Status(String label) { this.label = label; }
        public String getLabel() { return label; }
    }

    private long id;
    private long memberId;
    private List<Long> chargeIds;
    private String summary;        // 대표 항목명 외 N건
    private Method method;
    private long totalAmount;      // 선택한 대기건 합계
    private long couponDiscount;
    private long depositUsed;
    private long payAmount;        // 실제 입금/카드 결제할 금액 = total - coupon - deposit
    private String depositorName;
    private Status status;
    private LocalDateTime createdAt;
    private LocalDateTime paidAt;

    // ---- 운송장 (결제가 완료될 때 무작위로 배정된다. 모델 : Waybill) ----
    private String krMethod;       // AIR / SEA
    private String krWaybillNo;    // 한국 운송장번호
    private String jpCarrier;      // YAMATO ... MEITETSU
    private String jpWaybillNo;    // 일본 운송장번호

    public String getCreatedAtText() { return Formats.dateTime(createdAt); }

    /** 결제내역에 보일 한국 운송 방법 이름 (도쿄에어 / 후쿠오카 고속해상) */
    public String getKrMethodLabel() { return Waybill.krLabel(krMethod); }

    /** 결제내역에 보일 일본 택배사 이름 */
    public String getJpCarrierLabel() { return Waybill.jpLabel(jpCarrier); }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public long getMemberId() { return memberId; }
    public void setMemberId(long memberId) { this.memberId = memberId; }
    public List<Long> getChargeIds() { return chargeIds; }
    public void setChargeIds(List<Long> chargeIds) { this.chargeIds = List.copyOf(chargeIds); }
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }
    public Method getMethod() { return method; }
    public void setMethod(Method method) { this.method = method; }
    public long getTotalAmount() { return totalAmount; }
    public void setTotalAmount(long totalAmount) { this.totalAmount = totalAmount; }
    public long getCouponDiscount() { return couponDiscount; }
    public void setCouponDiscount(long couponDiscount) { this.couponDiscount = couponDiscount; }
    public long getDepositUsed() { return depositUsed; }
    public void setDepositUsed(long depositUsed) { this.depositUsed = depositUsed; }
    public long getPayAmount() { return payAmount; }
    public void setPayAmount(long payAmount) { this.payAmount = payAmount; }
    public String getDepositorName() { return depositorName; }
    public void setDepositorName(String depositorName) { this.depositorName = depositorName; }
    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }
    public String getKrMethod() { return krMethod; }
    public void setKrMethod(String krMethod) { this.krMethod = krMethod; }
    public String getKrWaybillNo() { return krWaybillNo; }
    public void setKrWaybillNo(String krWaybillNo) { this.krWaybillNo = krWaybillNo; }
    public String getJpCarrier() { return jpCarrier; }
    public void setJpCarrier(String jpCarrier) { this.jpCarrier = jpCarrier; }
    public String getJpWaybillNo() { return jpWaybillNo; }
    public void setJpWaybillNo(String jpWaybillNo) { this.jpWaybillNo = jpWaybillNo; }
}
