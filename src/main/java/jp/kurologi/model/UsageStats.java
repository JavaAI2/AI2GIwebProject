package jp.kurologi.model;

/** 이용실적 — 실제로는 화물(shipment) 테이블에서 월별로 집계합니다. */
public record UsageStats(int lastMonth, int thisMonth, int total) {

    public static final UsageStats EMPTY = new UsageStats(0, 0, 0);

    public int getLastMonth() { return lastMonth; }
    public int getThisMonth() { return thisMonth; }
    public int getTotal() { return total; }
}
