-- ============================================================
-- 03_stock.sql : 재고(물건등록) + 재고구매신청
-- 01_kuro_member.sql 을 먼저 실행해야 합니다 (회원 테이블을 참조)
-- ai2gi 계정으로 접속해서 전체 선택 후 F5(스크립트 실행)
-- ============================================================

CREATE SEQUENCE STOCK_ITEM_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE STOCK_ORDER_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

-- 재고 상품 (회원이 등록해 두는 물건)
CREATE TABLE STOCK_ITEM (
    STOCK_ID     NUMBER              NOT NULL,                 -- 재고 고유번호
    MEMBER_ID    NUMBER              NOT NULL,                 -- 등록한 회원 (KURO_MEMBER.ID)
    STOCK_NO     VARCHAR2(20)        NOT NULL,                 -- 화면에 보이는 재고번호 S000001
    ITEM_NAME    VARCHAR2(200 CHAR)  NOT NULL,                 -- 상품명
    OPTION_NAME  VARCHAR2(100 CHAR),                           -- 옵션
    QTY          NUMBER(7)           DEFAULT 0 NOT NULL,       -- 재고수량
    PRICE        NUMBER(12)          DEFAULT 0 NOT NULL,       -- 판매가(원)
    CREATED_AT   TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT STOCK_ITEM_PK        PRIMARY KEY (STOCK_ID),
    CONSTRAINT STOCK_ITEM_NO_UK     UNIQUE (STOCK_NO),
    CONSTRAINT STOCK_ITEM_MEMBER_FK FOREIGN KEY (MEMBER_ID) REFERENCES KURO_MEMBER (ID),
    CONSTRAINT STOCK_ITEM_QTY_CK    CHECK (QTY >= 0),            -- 재고가 마이너스가 되지 않게 DB 에서도 막는다
    CONSTRAINT STOCK_ITEM_PRICE_CK  CHECK (PRICE >= 0)
);

-- 재고구매신청 내역
CREATE TABLE STOCK_ORDER (
    SORDER_ID     NUMBER              NOT NULL,
    ORDER_NO      VARCHAR2(20)        NOT NULL,                -- 신청번호 SO20261026-00001
    STOCK_ID      NUMBER              NOT NULL,                -- 어떤 재고를 신청했는지
    MEMBER_ID     NUMBER              NOT NULL,
    RECV_NAME     VARCHAR2(60 CHAR)   NOT NULL,                -- 받는 사람
    MOBILE        VARCHAR2(30)        NOT NULL,                -- 휴대전화
    POSTCODE      VARCHAR2(10)        NOT NULL,
    ADDR1         VARCHAR2(200 CHAR)  NOT NULL,
    ADDR2         VARCHAR2(200 CHAR)  NOT NULL,
    DELIVER_NOTE  VARCHAR2(200 CHAR),                          -- 배송 요청사항
    QTY           NUMBER(7)           NOT NULL,                -- 신청 수량
    TOTAL_PRICE   NUMBER(14)          NOT NULL,                -- 예상 금액(원) = 판매가 x 신청수량
    CREATED_AT    TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT STOCK_ORDER_PK        PRIMARY KEY (SORDER_ID),
    CONSTRAINT STOCK_ORDER_NO_UK     UNIQUE (ORDER_NO),
    CONSTRAINT STOCK_ORDER_STOCK_FK  FOREIGN KEY (STOCK_ID)  REFERENCES STOCK_ITEM (STOCK_ID),
    CONSTRAINT STOCK_ORDER_MEMBER_FK FOREIGN KEY (MEMBER_ID) REFERENCES KURO_MEMBER (ID)
);

CREATE INDEX STOCK_ITEM_MEMBER_IDX  ON STOCK_ITEM (MEMBER_ID);
CREATE INDEX STOCK_ORDER_MEMBER_IDX ON STOCK_ORDER (MEMBER_ID);

COMMIT;

-- 확인용
-- SELECT * FROM STOCK_ITEM ORDER BY STOCK_ID DESC;
-- SELECT * FROM STOCK_ORDER ORDER BY SORDER_ID DESC;
