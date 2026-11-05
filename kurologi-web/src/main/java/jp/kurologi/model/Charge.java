package jp.kurologi.model;

import java.time.LocalDateTime;

import jp.kurologi.web.Formats;

/** 결제 대기건 1개 (배송비 · 관부가세 · 추가 결제 · 보관료 …). */
public class Charge {

    /** PENDING 결제 대기 / IN_PAYMENT 입금확인중 / PAID 결제완료 / REFUNDED 환불됨(배송 취소) */
    public enum Status { PENDING, IN_PAYMENT, PAID, REFUNDED }

    private long id;
    private long memberId;
    private String title;          // 비용결제 칸에 보이는 내용
    private String orderNo;        // 상세 링크 대상 주문번호
    private long amount;
    private LocalDateTime createdAt;
    private Status status = Status.PENDING;
    private Long paymentId;

    public String getCreatedAtText() { return Formats.date(createdAt); }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public long getMemberId() { return memberId; }
    public void setMemberId(long memberId) { this.memberId = memberId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getOrderNo() { return orderNo; }
    public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
    public long getAmount() { return amount; }
    public void setAmount(long amount) { this.amount = amount; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }
    public Long getPaymentId() { return paymentId; }
    public void setPaymentId(Long paymentId) { this.paymentId = paymentId; }
}
