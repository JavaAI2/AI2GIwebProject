-- ============================================================
-- 03_charge_payment.sql : 결제 대기건(CHARGE) + 결제(PAYMENT) 테이블 / 시퀀스
--
-- PaymentDAO · BuyOrderInsert · RefundDAO 가 쓰는 테이블입니다.
-- 05_payment_waybill.sql 이 PAYMENT 에 운송장 컬럼을 ALTER 로 붙이므로
-- 반드시 01_kuro_member.sql 다음, 05_payment_waybill.sql 보다 먼저 실행하세요.
--
-- 이미 CHARGE / PAYMENT 를 만들어 둔 DB 에서 실행해도 안전합니다.
-- (이미 있는 객체는 ORA-00955 를 무시하고 건너뜁니다 — 기존 데이터는 건드리지 않음)
-- ai2gi 계정으로 접속해서 전체 선택(Ctrl+A) 후 "스크립트 실행(F5)" 으로 실행하세요.
-- ============================================================

-- 1) 시퀀스
BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE PAYMENT_SEQ START WITH 1 INCREMENT BY 1 NOCACHE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE CHARGE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

-- 2) PAYMENT : 결제 1건 (운송장 컬럼 4개는 05_payment_waybill.sql 에서 추가)
BEGIN
    EXECUTE IMMEDIATE '
    CREATE TABLE PAYMENT (
        ID               NUMBER              NOT NULL,                 -- PAYMENT_SEQ
        MEMBER_ID        NUMBER              NOT NULL,                 -- KURO_MEMBER.ID
        SUMMARY          VARCHAR2(300 CHAR),                           -- 대표 항목명 외 N건
        TOTAL_AMOUNT     NUMBER              DEFAULT 0 NOT NULL,       -- 선택한 대기건 합계
        COUPON_DISCOUNT  NUMBER              DEFAULT 0 NOT NULL,
        DEPOSIT_USED     NUMBER              DEFAULT 0 NOT NULL,       -- 사용한 예치금
        PAY_AMOUNT       NUMBER              DEFAULT 0 NOT NULL,       -- 실제 입금/카드 결제 금액
        METHOD           VARCHAR2(20)        NOT NULL,                 -- BANK / CARD / DEPOSIT
        STATUS           VARCHAR2(20)        NOT NULL,                 -- AWAITING_DEPOSIT / AWAITING_CARD / PAID / CANCELED / REFUNDED
        DEPOSITOR_NAME   VARCHAR2(60 CHAR),                            -- 무통장 입금자명
        CREATED_AT       TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
        PAID_AT          TIMESTAMP,
        CONSTRAINT PAYMENT_PK        PRIMARY KEY (ID),
        CONSTRAINT PAYMENT_MEMBER_FK FOREIGN KEY (MEMBER_ID) REFERENCES KURO_MEMBER (ID),
        CONSTRAINT PAYMENT_METHOD_CK CHECK (METHOD IN (''BANK'', ''CARD'', ''DEPOSIT'')),
        CONSTRAINT PAYMENT_STATUS_CK CHECK (STATUS IN (''AWAITING_DEPOSIT'', ''AWAITING_CARD'', ''PAID'', ''CANCELED'', ''REFUNDED''))
    )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

-- 3) CHARGE : 내야 할 돈 한 줄 (PENDING 이면 결제 대기)
BEGIN
    EXECUTE IMMEDIATE '
    CREATE TABLE CHARGE (
        ID          NUMBER              NOT NULL,                      -- CHARGE_SEQ
        MEMBER_ID   NUMBER              NOT NULL,                      -- KURO_MEMBER.ID
        PAYMENT_ID  NUMBER,                                            -- 결제되면 PAYMENT.ID
        TITLE       VARCHAR2(200 CHAR),                                -- 비용결제 칸에 보이는 내용
        ORDER_NO    VARCHAR2(20),                                      -- BUY_ORDER.ORDER_NO
        AMOUNT      NUMBER              DEFAULT 0 NOT NULL,
        STATUS      VARCHAR2(20)        DEFAULT ''PENDING'' NOT NULL,  -- PENDING / IN_PAYMENT / PAID / REFUNDED
        CREATED_AT  TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT CHARGE_PK         PRIMARY KEY (ID),
        CONSTRAINT CHARGE_MEMBER_FK  FOREIGN KEY (MEMBER_ID)  REFERENCES KURO_MEMBER (ID),
        CONSTRAINT CHARGE_PAYMENT_FK FOREIGN KEY (PAYMENT_ID) REFERENCES PAYMENT (ID),
        CONSTRAINT CHARGE_STATUS_CK  CHECK (STATUS IN (''PENDING'', ''IN_PAYMENT'', ''PAID'', ''REFUNDED''))
    )';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

-- 4) 조회가 빠르도록 인덱스 (이미 있으면 건너뜀)
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX CHARGE_MEMBER_IX ON CHARGE (MEMBER_ID, STATUS)';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE NOT IN (-955, -1408) THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX CHARGE_ORDER_IX ON CHARGE (ORDER_NO)';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE NOT IN (-955, -1408) THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX PAYMENT_MEMBER_IX ON PAYMENT (MEMBER_ID)';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE NOT IN (-955, -1408) THEN RAISE; END IF;
END;
/

COMMIT;

-- 확인용
-- SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME IN ('CHARGE', 'PAYMENT');
-- SELECT SEQUENCE_NAME FROM USER_SEQUENCES WHERE SEQUENCE_NAME IN ('CHARGE_SEQ', 'PAYMENT_SEQ');
