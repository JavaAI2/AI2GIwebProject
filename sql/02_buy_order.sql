-- ============================================================
-- 02_buy_order.sql : 구매대행 주문서 (주문 1건 + 상품 여러 개)
-- 01_kuro_member.sql 을 먼저 실행해야 합니다 (회원 테이블을 참조)
-- ============================================================

CREATE SEQUENCE BUY_ORDER_SEQ      START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE BUY_ORDER_ITEM_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

-- 주문서 (받는 사람 정보 + 부가서비스 + 결제 방식)
CREATE TABLE BUY_ORDER (
    ORDER_ID        NUMBER              NOT NULL,                 -- 주문 고유번호
    ORDER_NO        VARCHAR2(20)        NOT NULL,                 -- 화면에 보이는 주문번호 B20261026-00001
    MEMBER_ID       NUMBER              NOT NULL,                 -- 주문한 회원 (KURO_MEMBER.ID)
    STATUS          VARCHAR2(10)        DEFAULT 'WAIT' NOT NULL,  -- WAIT 접수대기 / SUBMIT 접수신청
    CENTER          VARCHAR2(100 CHAR),                           -- 물류센터 및 운송방식
    RECV_NAME_KO    VARCHAR2(60 CHAR)   NOT NULL,                 -- 받는 사람 한글
    RECV_NAME_EN    VARCHAR2(60),                                 -- 받는 사람 영문
    POSTCODE        VARCHAR2(10),                                 -- 우편번호
    ADDR1           VARCHAR2(200 CHAR),                           -- 주소
    ADDR2           VARCHAR2(200 CHAR),                           -- 상세주소
    BIZ_NO          VARCHAR2(10),                                 -- 사업자번호 (숫자 10자리)
    MOBILE          VARCHAR2(30),                                 -- 휴대전화
    DELIVER_NOTE    VARCHAR2(200 CHAR),                           -- 배송 요청사항
    TOTAL_QTY       NUMBER              DEFAULT 0 NOT NULL,       -- 총 수량
    TOTAL_YEN       NUMBER(14,2)        DEFAULT 0 NOT NULL,       -- 총 금액 (엔)
    ADDON_OPTIONS   VARCHAR2(1000 CHAR),                          -- 부가서비스 (쉼표로 구분)
    LOGISTICS_NOTE  VARCHAR2(1000 CHAR),                          -- 물류 요청사항
    AUTO_PAY        CHAR(1)             DEFAULT 'N' NOT NULL,     -- 예치금 자동결제 Y/N
    CREATED_AT      TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT BUY_ORDER_PK        PRIMARY KEY (ORDER_ID),
    CONSTRAINT BUY_ORDER_NO_UK     UNIQUE (ORDER_NO),
    CONSTRAINT BUY_ORDER_MEMBER_FK FOREIGN KEY (MEMBER_ID) REFERENCES KURO_MEMBER (ID),
    CONSTRAINT BUY_ORDER_STATUS_CK CHECK (STATUS IN ('WAIT','SUBMIT'))
);

-- 주문 상품 (주문서 1건에 최대 20개)
CREATE TABLE BUY_ORDER_ITEM (
    ITEM_ID          NUMBER              NOT NULL,
    ORDER_ID         NUMBER              NOT NULL,                -- 어느 주문서의 상품인지
    ITEM_NO          NUMBER(2)           NOT NULL,                -- 상품 순번 1~20
    SHOP_SITE        VARCHAR2(200 CHAR),                          -- 쇼핑몰 사이트
    BRAND            VARCHAR2(100 CHAR),                          -- 브랜드
    SHOP_ORDER_NO    VARCHAR2(100),                               -- 쇼핑몰 오더번호
    TRACKING_NO      VARCHAR2(100),                               -- 트래킹번호 (접수대기는 비워도 됨)
    ITEM_NAME_EN     VARCHAR2(300)       NOT NULL,                -- 상품명 영문
    NAME_EN_DIRECT   CHAR(1)             DEFAULT 'N' NOT NULL,    -- 영문명 직접 기재 Y/N
    QTY              NUMBER(5)           DEFAULT 1 NOT NULL,      -- 수량
    UNIT_PRICE       NUMBER(12,2)        DEFAULT 0 NOT NULL,      -- 단가 (엔)
    COLOR            VARCHAR2(100 CHAR),                          -- 색상
    ITEM_SIZE        VARCHAR2(100 CHAR),                          -- 사이즈 (SIZE 는 예약어라 ITEM_SIZE)
    PRODUCT_URL      VARCHAR2(1000),                              -- 상품 URL
    IMAGE_URL        VARCHAR2(1000),                              -- 이미지 URL
    MARKET_NAME      VARCHAR2(100 CHAR),                          -- 오픈마켓 이름
    MARKET_ORDER_NO  VARCHAR2(100),                               -- 오픈마켓 주문번호
    MARKET_PRICE     NUMBER(12)          DEFAULT 0 NOT NULL,      -- 오픈마켓 판매금액
    HS_CODE          VARCHAR2(30),                                -- HS CODE
    MARKET_PAY       VARCHAR2(100 CHAR),                          -- 오픈마켓 결제수단
    CONSTRAINT BUY_ORDER_ITEM_PK       PRIMARY KEY (ITEM_ID),
    CONSTRAINT BUY_ORDER_ITEM_ORDER_FK FOREIGN KEY (ORDER_ID)
        REFERENCES BUY_ORDER (ORDER_ID) ON DELETE CASCADE         -- 주문을 지우면 상품도 같이 삭제
);

CREATE INDEX BUY_ORDER_MEMBER_IDX ON BUY_ORDER (MEMBER_ID);
CREATE INDEX BUY_ORDER_ITEM_ORDER_IDX ON BUY_ORDER_ITEM (ORDER_ID);

COMMIT;

-- 확인용 (주문서 접수 후 조회해 보세요)
-- SELECT * FROM BUY_ORDER ORDER BY ORDER_ID DESC;
-- SELECT * FROM BUY_ORDER_ITEM ORDER BY ITEM_ID DESC;
-- 주문 + 상품 조인 (ANSI 방식)
-- SELECT o.ORDER_NO, o.STATUS, m.NAME, i.ITEM_NO, i.ITEM_NAME_EN, i.QTY, i.UNIT_PRICE
--   FROM BUY_ORDER o
--   JOIN KURO_MEMBER m ON m.ID = o.MEMBER_ID
--   JOIN BUY_ORDER_ITEM i ON i.ORDER_ID = o.ORDER_ID
--  ORDER BY o.ORDER_ID DESC, i.ITEM_NO;
