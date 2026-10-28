-- ============================================================
-- 04_ship_and_rate.sql : 배송대행 구분 + 환율 테이블
-- 02_buy_order.sql 을 먼저 실행한 뒤, ai2gi 계정으로 전체 선택 후 F5(스크립트 실행)
-- 이 파일은 "수정(ALTER)" 이라서 한 번만 실행하세요. (두 번 실행하면 이미 있다는 오류가 납니다)
-- ============================================================

-- 1) 구매대행 / 배송대행 구분 + 접수 때 적용한 환율 · 원화 금액
--    같은 테이블(BUY_ORDER)을 두 서비스가 같이 쓴다. 기존 주문은 모두 'BUY' 로 채워진다.
ALTER TABLE BUY_ORDER ADD (
    SERVICE_TYPE  VARCHAR2(4)   DEFAULT 'BUY' NOT NULL,   -- BUY 구매대행 / SHIP 배송대행
    APPLIED_RATE  NUMBER(10,2),                           -- 적용한 고시환율 (원 / 100엔)
    TOTAL_KRW     NUMBER(14)                              -- 결제 예정 금액(원) = 총 엔화 금액 x 고시환율 / 100
);

ALTER TABLE BUY_ORDER ADD CONSTRAINT BUY_ORDER_SVC_CK CHECK (SERVICE_TYPE IN ('BUY', 'SHIP'));

CREATE INDEX BUY_ORDER_SVC_IDX ON BUY_ORDER (MEMBER_ID, SERVICE_TYPE);

-- 2) 환율 테이블 : 하루에 1행. 서버가 하루 한 번 외부 환율 API 에서 받아 저장한다.
CREATE TABLE EXCHANGE_RATE (
    RATE_DATE    DATE            NOT NULL,                    -- 기준일 (한국 시간)
    BASE_RATE    NUMBER(10,2)    NOT NULL,                    -- 기준환율 (원 / 100엔) = 시장 환율
    SEND_RATE    NUMBER(10,2)    NOT NULL,                    -- 송금환율 (원 / 100엔) = 기준환율 + 1.0%
    NOTICE_RATE  NUMBER(10,2)    NOT NULL,                    -- 고시환율 (원 / 100엔) = 기준환율 + 2.5%  <- 결제에 적용
    JPY_USD      NUMBER(12,8)    NOT NULL,                    -- 1엔이 몇 달러인지 (세관 신고용 $ 금액 계산)
    SOURCE       VARCHAR2(30),                                -- API : 자동 수집 / SEED : 처음 넣어 둔 값 / MANUAL : 직접 입력
    FETCHED_AT   TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT EXCHANGE_RATE_PK PRIMARY KEY (RATE_DATE)
);

-- 처음 한 번은 기존 메인 화면에 고정으로 적혀 있던 값을 넣어 둔다.
-- (서버가 처음 실행되어 오늘 환율을 받아 오면 자동으로 최신 값으로 바뀝니다)
INSERT INTO EXCHANGE_RATE (RATE_DATE, BASE_RATE, SEND_RATE, NOTICE_RATE, JPY_USD, SOURCE)
VALUES (DATE '2026-10-03', 854.58, 862.95, 876.31, 0.00666667, 'SEED');

COMMIT;

-- 확인용
-- SELECT * FROM EXCHANGE_RATE ORDER BY RATE_DATE DESC;
-- 환율을 직접 넣고 싶을 때(예: API 가 안 될 때) : 오늘 날짜 행을 넣거나 고치면 그 값이 쓰입니다.
-- INSERT INTO EXCHANGE_RATE (RATE_DATE, BASE_RATE, SEND_RATE, NOTICE_RATE, JPY_USD, SOURCE)
-- VALUES (TRUNC(SYSDATE), 900.00, 909.00, 922.50, 0.00650000, 'MANUAL');
-- COMMIT;
