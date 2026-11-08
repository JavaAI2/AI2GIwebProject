-- ============================================================
-- 09_order_delivery.sql : 출고 이후 단계 추가 (세관 통관 → 국내 배송 중 → 배송 완료)
-- ai2gi 계정으로 접속해서 위에서부터 하나씩 실행하세요. (한 번만 실행)
--
-- 주문의 흐름 (STATUS)
--   SUBMIT 접수신청 -> RECEIVED 입고완료 -> (BILLED 배송비 대기) -> SHIPPED 출고완료
--   -> DELIVERING 국내 배송 중 (세관 통관 완료, 한국 택배 인계) -> DELIVERED 배송 완료
--   SHIPPED -> DELIVERING, DELIVERING -> DELIVERED 는 관리자 주문 관리(/admin/orders)에서 버튼으로 처리한다.
-- ============================================================

-- 1) STATUS 제약에 배송 완료(DELIVERED)를 추가한다 (08_order_cancel.sql 까지 실행한 상태 기준)
ALTER TABLE BUY_ORDER DROP CONSTRAINT BUY_ORDER_STATUS_CK;
ALTER TABLE BUY_ORDER ADD CONSTRAINT BUY_ORDER_STATUS_CK
    CHECK (STATUS IN ('WAIT', 'SUBMIT', 'RECEIVED', 'BILLED', 'SHIPPED', 'DELIVERING', 'DELIVERED', 'CANCELED'));

-- 2) 단계별 처리 시각 (배송 추적 화면의 시간 표시용)
ALTER TABLE BUY_ORDER ADD (
    SHIPPED_AT    TIMESTAMP,    -- 출고 처리한 시각
    CUSTOMS_AT    TIMESTAMP,    -- 세관 통관 완료(국내 배송 시작) 처리한 시각
    DELIVERED_AT  TIMESTAMP     -- 배송 완료 처리한 시각
);

-- 3) 이미 출고 · 국내 배송 중이던 주문은 마지막 변경 시각을 그 단계의 시각으로 옮겨 둔다
UPDATE BUY_ORDER SET SHIPPED_AT = STATUS_UPDATED_AT WHERE STATUS = 'SHIPPED'    AND SHIPPED_AT IS NULL;
UPDATE BUY_ORDER SET CUSTOMS_AT = STATUS_UPDATED_AT WHERE STATUS = 'DELIVERING' AND CUSTOMS_AT IS NULL;

COMMIT;

-- 4) 확인용
-- SELECT ORDER_NO, STATUS, SHIPPED_AT, CUSTOMS_AT, DELIVERED_AT FROM BUY_ORDER ORDER BY ORDER_ID DESC;
