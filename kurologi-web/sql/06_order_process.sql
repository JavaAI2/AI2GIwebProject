-- ============================================================
-- 06_order_process.sql : 접수 이후 처리 (입고 / 결제 확인 / 출고)
-- 04_ship_and_rate.sql 을 먼저 실행한 뒤, ai2gi 계정으로 전체 선택 후 F5. 한 번만 실행하세요.
--
-- 주문의 흐름
--   STATUS     WAIT 접수대기 -> SUBMIT 접수신청 -> RECEIVED 입고완료 -> SHIPPED 출고완료   (입고 · 출고는 관리자가 처리)
--   PAY_STATUS UNPAID 미결제 -> PAID 결제완료                                            (예치금 자동결제 또는 관리자 결제 확인)
--   출고는 "입고완료 + 결제완료" 일 때만 할 수 있다.
-- ============================================================

-- 상태 값 확장 : 입고완료(RECEIVED), 출고완료(SHIPPED) 추가
ALTER TABLE BUY_ORDER DROP CONSTRAINT BUY_ORDER_STATUS_CK;
ALTER TABLE BUY_ORDER ADD CONSTRAINT BUY_ORDER_STATUS_CK CHECK (STATUS IN ('WAIT', 'SUBMIT', 'RECEIVED', 'SHIPPED'));

-- 결제 상태 + 마지막으로 상태가 바뀐 시각
ALTER TABLE BUY_ORDER ADD (
    PAY_STATUS         VARCHAR2(6)  DEFAULT 'UNPAID' NOT NULL,   -- UNPAID 미결제 / PAID 결제완료
    STATUS_UPDATED_AT  TIMESTAMP
);
ALTER TABLE BUY_ORDER ADD CONSTRAINT BUY_ORDER_PAY_CK CHECK (PAY_STATUS IN ('UNPAID', 'PAID'));

COMMIT;

-- 관리자 지정 (관리자 화면 /admin/orders 는 KURO_MEMBER.ROLE = 'ADMIN' 인 회원만 열린다)
-- ROLE 컬럼은 community.sql 에서 만든 것을 같이 쓴다. 이미 관리자가 있으면 건너뛰세요.
-- UPDATE KURO_MEMBER SET ROLE = 'ADMIN' WHERE LOGIN_ID = '내아이디';
-- COMMIT;

-- 확인용
-- SELECT ORDER_NO, SERVICE_TYPE, STATUS, PAY_STATUS FROM BUY_ORDER ORDER BY ORDER_ID DESC;
