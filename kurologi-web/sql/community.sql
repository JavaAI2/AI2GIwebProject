--호에엥
SELECT 'TABLE' AS KIND, TABLE_NAME AS NAME FROM USER_TABLES
 WHERE TABLE_NAME IN ('COMMUNITY_POST', 'COMMUNITY_COMMENT')
UNION ALL
SELECT 'SEQUENCE', SEQUENCE_NAME FROM USER_SEQUENCES
 WHERE SEQUENCE_NAME IN ('SEQ_COMMUNITY_POST', 'SEQ_COMMUNITY_COMMENT');
 
 CREATE SEQUENCE SEQ_COMMUNITY_POST    START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_COMMUNITY_COMMENT START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE COMMUNITY_POST (
    POST_ID     NUMBER              CONSTRAINT PK_COMMUNITY_POST PRIMARY KEY,
    TITLE       VARCHAR2(200 CHAR)  NOT NULL,
    CONTENT     VARCHAR2(4000)      NOT NULL,   -- 바이트 기준: 한글 약 1,300자
    WRITER_ID   VARCHAR2(50),                   -- 로그인 연동 전: NULL, FK 없음
    VIEW_COUNT  NUMBER              DEFAULT 0 NOT NULL,
    LIKE_COUNT  NUMBER              DEFAULT 0 NOT NULL,
    CREATED_AT  DATE                DEFAULT SYSDATE NOT NULL,
    UPDATED_AT  DATE,
    CONSTRAINT CK_POST_VIEW CHECK (VIEW_COUNT >= 0),
    CONSTRAINT CK_POST_LIKE CHECK (LIKE_COUNT >= 0)
);

CREATE TABLE COMMUNITY_COMMENT (
    COMMENT_ID  NUMBER               CONSTRAINT PK_COMMUNITY_COMMENT PRIMARY KEY,
    POST_ID     NUMBER               NOT NULL,
    PARENT_ID   NUMBER,                          -- NULL=댓글, 값 있음=답글
    CONTENT     VARCHAR2(1000 CHAR)  NOT NULL,
    WRITER_ID   VARCHAR2(50),                    -- 로그인 연동 전: NULL, FK 없음
    DELETED_YN  CHAR(1)              DEFAULT 'N' NOT NULL,
    CREATED_AT  DATE                 DEFAULT SYSDATE NOT NULL,
    CONSTRAINT FK_COMMENT_POST FOREIGN KEY (POST_ID)
        REFERENCES COMMUNITY_POST (POST_ID) ON DELETE CASCADE,
    CONSTRAINT FK_COMMENT_PARENT FOREIGN KEY (PARENT_ID)
        REFERENCES COMMUNITY_COMMENT (COMMENT_ID) ON DELETE CASCADE,
    CONSTRAINT CK_COMMENT_DELETED CHECK (DELETED_YN IN ('Y', 'N'))
);

CREATE INDEX IDX_COMMENT_POST   ON COMMUNITY_COMMENT (POST_ID);
CREATE INDEX IDX_COMMENT_PARENT ON COMMUNITY_COMMENT (PARENT_ID);

COMMENT ON COLUMN COMMUNITY_POST.WRITER_ID IS '[미완성] 회원 테이블/로그인 연동 전 NULL. 연동 후 회원 ID 저장';
COMMENT ON COLUMN COMMUNITY_COMMENT.WRITER_ID IS '[미완성] 회원 테이블/로그인 연동 전 NULL. 연동 후 회원 ID 저장';

--추가 1 (확인용)
SELECT COUNT(*) AS POST_COUNT
FROM COMMUNITY_POST;
SELECT COUNT(*) AS COMMENT_COUNT
FROM COMMUNITY_COMMENT;




--회원가입 테이블

CREATE TABLE KURO_MEMBER (
    ID                      NUMBER(19)          PRIMARY KEY,       -- 회원 고유 번호 (Long)
    LOGIN_ID                VARCHAR2(50)        NOT NULL UNIQUE,   -- 로그인용 진짜 아이디
    PASSWORD_HASH           VARCHAR2(255)       NOT NULL,          -- 암호화된 비밀번호
    NAME                    VARCHAR2(50)        NOT NULL,          -- 한글 이름
    ENGLISH_NAME            VARCHAR2(50),                          -- 영문 이름
    MAILBOX_NO              VARCHAR2(30),                          -- 자동 발급 사서함 번호 (KR0000000)
    MEMBER_NO               VARCHAR2(30),                          -- 회원번호
    PHONE                   VARCHAR2(30),                          -- 휴대폰 번호
    EMAIL                   VARCHAR2(100),                         -- 이메일 주소
    SMS_REFUSE              CHAR(1)             DEFAULT 'N',       -- SMS 수신 거부 (Y/N)
    MEMBER_TYPE             VARCHAR2(20)        DEFAULT 'PERSONAL',-- 회원 유형 (PERSONAL / BUSINESS)
    GRADE                   VARCHAR2(20)        DEFAULT 'BASIC',   -- 회원 등급 (BASIC 등)
    POINTS                  NUMBER(19)          DEFAULT 0,         -- 보유 포인트
    REFERRAL_POINTS_PENDING NUMBER(19)          DEFAULT 0,         -- 추천 대기 포인트
    REFERRAL_CODE           VARCHAR2(50),                          -- 추천인 코드
    DEPOSIT                 NUMBER(19)          DEFAULT 0,         -- 예치금
    COUPONS                 NUMBER(10)          DEFAULT 0,         -- 쿠폰 개수
    LAST_LOGIN_AT           TIMESTAMP,                             -- 마지막 로그인 일시
    WITHDRAWN               CHAR(1)             DEFAULT 'N'        -- 탈퇴 여부 (Y/N)
);


-- 번호가 자동으로 1씩 증가하도록 시퀀스(Sequence) 생성 (회원번호 자동 발급용)
CREATE SEQUENCE MEMBER_SEQ START WITH 1 INCREMENT BY 1;

select * from KURO_MEMBER;
DELETE FROM KURO_MEMBER WHERE LOGIN_ID = 'java01';


ALTER TABLE KURO_MEMBER ADD (PW_QUIZ_ANSWER VARCHAR2(255));

COMMENT ON COLUMN KURO_MEMBER.PW_QUIZ_ANSWER IS '비밀번호 퀴즈 답 (BCrypt 해시)';

-- =====================================================================
-- KURO_MEMBER 에 ROLE(권한) 컬럼 추가 — 관리자 구분용
--
--   ★ 팀원이 같이 쓰는 회원 테이블을 바꾸므로, 실행 전에 팀원에게 알려 주세요.
--   ★ 컬럼을 "추가"만 하고 기본값이 'USER' 라서, 기존 회원/가입/로그인 SQL 은 그대로 동작합니다
--     (기존 INSERT 는 컬럼 이름을 직접 적고 있고 SELECT * 도 쓰지 않는 것을 확인했습니다).
--   ★ 팀원 PC / 발표용 PC 의 DB 에도 각각 한 번씩 실행해야 합니다.
--   ★ 문장을 하나씩 선택해서 실행하세요 (SQL Developer: Ctrl+Enter).
--     이미 실행한 문장을 다시 실행하면 오류(ORA-01430 등)가 나는데, 그 문장은 건너뛰면 됩니다.
-- =====================================================================

-- [0] 확인 : 현재 회원 수
SELECT COUNT(*) AS MEMBER_CNT FROM KURO_MEMBER;

-- [1] ROLE 컬럼 추가 (USER = 일반 회원, ADMIN = 관리자)
ALTER TABLE KURO_MEMBER ADD (ROLE VARCHAR2(10) DEFAULT 'USER' NOT NULL);

ALTER TABLE KURO_MEMBER ADD CONSTRAINT CK_MEMBER_ROLE CHECK (ROLE IN ('USER', 'ADMIN'));

COMMENT ON COLUMN KURO_MEMBER.ROLE IS '권한 (USER=일반 회원, ADMIN=관리자)';

-- [2] 관리자 지정 : 작은따옴표 안을 관리자로 쓸 회원의 로그인 아이디로 바꿔서 실행
UPDATE KURO_MEMBER SET ROLE = 'ADMIN' WHERE LOGIN_ID = 'java1026';
COMMIT;

-- [3] 결과 확인 : 관리자 계정의 ROLE 이 ADMIN 으로 보이면 성공
SELECT ID, LOGIN_ID, NAME, ROLE FROM KURO_MEMBER ORDER BY ID;

-- (관리자를 다시 일반 회원으로 되돌릴 때)
-- UPDATE KURO_MEMBER SET ROLE = 'USER' WHERE LOGIN_ID = '아이디';
-- COMMIT;











-- 1. 청구 항목 테이블 (오류 수정 완료)
CREATE TABLE CHARGE (
    ID               NUMBER(19)         PRIMARY KEY,       -- 청구 번호
    MEMBER_ID        NUMBER(19)         NOT NULL,          -- 회원 번호
    PAYMENT_ID       NUMBER(19),                           -- 결제서 번호 (결제 전엔 NULL)
    TITLE            VARCHAR2(200)      NOT NULL,          -- 청구 내용
    ORDER_NO         VARCHAR2(50),                         -- 상세 링크 대상 주문번호
    AMOUNT           NUMBER(19)         NOT NULL,          -- 청구 금액
    STATUS           VARCHAR2(30)       DEFAULT 'PENDING', -- 상태 (PENDING, IN_PAYMENT, PAID)
    CREATED_AT       TIMESTAMP          NOT NULL,          -- 청구일시
    
    -- ★ REFERENCES 뒤의 테이블 이름을 MEMBER에서 KURO_MEMBER로 수정했습니다.
    CONSTRAINT FK_CHARGE_MEMBER FOREIGN KEY (MEMBER_ID) REFERENCES KURO_MEMBER(ID) ON DELETE CASCADE
);

CREATE SEQUENCE CHARGE_SEQ START WITH 1 INCREMENT BY 1;


-- 2. 나의 주소록 테이블 (KURO_MEMBER 반영)
CREATE TABLE ADDRESS (
    ID               NUMBER(19)         PRIMARY KEY,       -- 주소 고유 번호
    MEMBER_ID        NUMBER(19)         NOT NULL,          -- 소유자 회원 번호
    NAME             VARCHAR2(90)       NOT NULL,          -- 받는 사람 이름
    ZIPCODE          CHAR(5)            NOT NULL,          -- 우편번호
    ADDRESS1         VARCHAR2(300)      NOT NULL,          -- 기본 주소
    ADDRESS2         VARCHAR2(300),                        -- 상세 주소
    COUNTRY          VARCHAR2(50)       DEFAULT 'South Korea', -- 국가명
    PHONE            VARCHAR2(30)       NOT NULL,          -- 연락처
    CUSTOMS_CODE     CHAR(13)           NOT NULL,          -- 개인통관고유부호
    
    CONSTRAINT FK_ADDRESS_MEMBER FOREIGN KEY (MEMBER_ID) REFERENCES KURO_MEMBER(ID) ON DELETE CASCADE
);

CREATE SEQUENCE ADDRESS_SEQ START WITH 1 INCREMENT BY 1;


-- 3. 결제 이력 테이블 (KURO_MEMBER 반영)
CREATE TABLE PAYMENT (
    ID               NUMBER(19)         PRIMARY KEY,       -- 결제 번호
    MEMBER_ID        NUMBER(19)         NOT NULL,          -- 회원 번호
    SUMMARY          VARCHAR2(300)      NOT NULL,          -- 결제 요약
    TOTAL_AMOUNT     NUMBER(19)         NOT NULL,          -- 총 청구금액
    COUPON_DISCOUNT  NUMBER(19)         DEFAULT 0,         -- 쿠폰 할인액
    DEPOSIT_USED     NUMBER(19)         DEFAULT 0,         -- 사용한 예치금
    PAY_AMOUNT       NUMBER(19)         NOT NULL,          -- 최종 실결제 금액
    METHOD           VARCHAR2(20)       NOT NULL,          -- 결제수단 (DEPOSIT, CARD, BANK)
    STATUS           VARCHAR2(30)       NOT NULL,          -- 상태
    DEPOSITOR_NAME   VARCHAR2(50),                         -- 무통장 입금자명
    CREATED_AT       TIMESTAMP          NOT NULL,          -- 결제 요청 일시
    PAID_AT          TIMESTAMP,                            -- 결제 완료 일시
    
    CONSTRAINT FK_PAYMENT_MEMBER FOREIGN KEY (MEMBER_ID) REFERENCES KURO_MEMBER(ID) ON DELETE CASCADE
);

CREATE SEQUENCE PAYMENT_SEQ START WITH 1 INCREMENT BY 1;




--확인문 0번
SELECT 'POST_ROWS' AS ITEM, TO_CHAR(COUNT(*)) AS VAL FROM COMMUNITY_POST
UNION ALL
SELECT 'COMMENT_ROWS', TO_CHAR(COUNT(*)) FROM COMMUNITY_COMMENT
UNION ALL
SELECT 'DB_CHARSET', VALUE FROM NLS_DATABASE_PARAMETERS WHERE PARAMETER = 'NLS_CHARACTERSET';

- ---------------------------------------------------------------------
-- [1] 기존 테이블 보완
-- ---------------------------------------------------------------------
 
-- 1-1. 게시글 종류(공지 / 1:1문의) 와 답변 여부 컬럼 추가
ALTER TABLE COMMUNITY_POST ADD (
    BOARD_TYPE VARCHAR2(10) DEFAULT 'QNA' NOT NULL,   -- NOTICE=공지사항, QNA=1:1게시판
    ANSWER_YN  CHAR(1)      DEFAULT 'N'   NOT NULL    -- 1:1게시판 답변 여부 (Y/N)
);
 
ALTER TABLE COMMUNITY_POST ADD CONSTRAINT CK_POST_TYPE   CHECK (BOARD_TYPE IN ('NOTICE', 'QNA'));
ALTER TABLE COMMUNITY_POST ADD CONSTRAINT CK_POST_ANSWER CHECK (ANSWER_YN IN ('Y', 'N'));
 
-- 1-2. 작성자 컬럼을 "회원 번호(KURO_MEMBER.ID)" 와 같은 숫자 타입으로 변경
--      (로그인 세션이 숫자 회원 번호를 들고 있고, CHARGE / ADDRESS / PAYMENT 도 같은 방식입니다)
--      작성자 값이 전부 NULL 이어야 타입 변경이 됩니다. 지금은 NULL 이므로 가능합니다.
--      (ORA-01439 가 나면 WRITER_ID 에 값이 들어 있는 것이니 알려주세요)
ALTER TABLE COMMUNITY_POST    MODIFY (WRITER_ID NUMBER(19));
ALTER TABLE COMMUNITY_COMMENT MODIFY (WRITER_ID NUMBER(19));
 
COMMENT ON COLUMN COMMUNITY_POST.BOARD_TYPE    IS 'NOTICE=공지사항, QNA=1:1게시판';
COMMENT ON COLUMN COMMUNITY_POST.ANSWER_YN     IS '1:1게시판 답변 여부 (Y/N)';
COMMENT ON COLUMN COMMUNITY_POST.WRITER_ID     IS '작성 회원 번호(KURO_MEMBER.ID). NULL = 관리자(운영자) 작성';
COMMENT ON COLUMN COMMUNITY_COMMENT.WRITER_ID  IS '작성 회원 번호(KURO_MEMBER.ID). NULL = 관리자(운영자) 작성';
 
 
-- ---------------------------------------------------------------------
-- [2] 새 테이블 3개 (시퀀스 포함)
-- ---------------------------------------------------------------------
 
CREATE SEQUENCE SEQ_COMMUNITY_MESSAGE START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_COMMUNITY_DEAL    START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_COMMUNITY_FAQ     START WITH 1 INCREMENT BY 1 NOCACHE;

--시퀀스 생성 안돼서 다시 생성
CREATE SEQUENCE SEQ_COMMUNITY_POST    START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_COMMUNITY_COMMENT START WITH 1 INCREMENT BY 1 NOCACHE;
 
-- 2-1. 알림메세지 (message.jsp)
CREATE TABLE COMMUNITY_MESSAGE (
    MESSAGE_ID  NUMBER               CONSTRAINT PK_COMMUNITY_MESSAGE PRIMARY KEY,
    MEMBER_ID   NUMBER(19)           NOT NULL,                 -- 받는 회원 (KURO_MEMBER.ID)
    MSG_TYPE    VARCHAR2(30 CHAR)    NOT NULL,                 -- 구분 (입고 / 출고 / 배송 등)
    CONTENT     VARCHAR2(1000 CHAR)  NOT NULL,                 -- 내용
    SENT_AT     DATE                 DEFAULT SYSDATE NOT NULL, -- 발송일시
    READ_YN     CHAR(1)              DEFAULT 'N' NOT NULL,     -- 확인(읽음) 여부
    CONSTRAINT CK_MESSAGE_READ CHECK (READ_YN IN ('Y', 'N'))
);
 
CREATE INDEX IDX_MESSAGE_MEMBER ON COMMUNITY_MESSAGE (MEMBER_ID, MESSAGE_ID);
 
-- 2-2. 특가제품안내 (deals.jsp)
CREATE TABLE COMMUNITY_DEAL (
    DEAL_ID     NUMBER               CONSTRAINT PK_COMMUNITY_DEAL PRIMARY KEY,
    NAME        VARCHAR2(200 CHAR)   NOT NULL,                 -- 상품명
    PRICE_JPY   NUMBER(10)           DEFAULT 0 NOT NULL,       -- 가격 (엔)
    MIN_QTY     NUMBER(5)            DEFAULT 1 NOT NULL,       -- 최소 주문 수량
    IMAGE_PATH  VARCHAR2(300),                                 -- 이미지 경로 (없으면 기본 아이콘)
    VISIBLE_YN  CHAR(1)              DEFAULT 'Y' NOT NULL,     -- 화면 노출 여부
    CREATED_AT  DATE                 DEFAULT SYSDATE NOT NULL,
    CONSTRAINT CK_DEAL_PRICE   CHECK (PRICE_JPY >= 0),
    CONSTRAINT CK_DEAL_QTY     CHECK (MIN_QTY >= 1),
    CONSTRAINT CK_DEAL_VISIBLE CHECK (VISIBLE_YN IN ('Y', 'N'))
);
 
-- 2-3. 자주묻는 질문 (faq.jsp)
CREATE TABLE COMMUNITY_FAQ (
    FAQ_ID      NUMBER               CONSTRAINT PK_COMMUNITY_FAQ PRIMARY KEY,
    CATEGORY    VARCHAR2(50 CHAR)    NOT NULL,                 -- 회원/기타, 배송신청서, 입고/출고, 배송비 ...
    QUESTION    VARCHAR2(300 CHAR)   NOT NULL,
    ANSWER      VARCHAR2(4000)       NOT NULL,                 -- 바이트 기준 (한글 약 1,300자)
    SORT_ORDER  NUMBER(5)            DEFAULT 0 NOT NULL,       -- 같은 분류 안에서 보여줄 순서
    VISIBLE_YN  CHAR(1)              DEFAULT 'Y' NOT NULL,
    CREATED_AT  DATE                 DEFAULT SYSDATE NOT NULL,
    CONSTRAINT CK_FAQ_VISIBLE CHECK (VISIBLE_YN IN ('Y', 'N'))
);
 
 
-- ---------------------------------------------------------------------
-- [3] 회원 연결 (FK)
--     로그인한 회원이 실제로 KURO_MEMBER 테이블에 있는 것을 확인한 뒤에 실행하세요.
--     (확인: SELECT ID, LOGIN_ID FROM KURO_MEMBER;  에 로그인에 쓰는 계정이 보이면 OK)
--     회원이 삭제되면 글/댓글은 남기고 작성자만 NULL, 알림은 함께 삭제됩니다.
-- ---------------------------------------------------------------------
ALTER TABLE COMMUNITY_POST    ADD CONSTRAINT FK_POST_WRITER    FOREIGN KEY (WRITER_ID) REFERENCES KURO_MEMBER (ID) ON DELETE SET NULL;
ALTER TABLE COMMUNITY_COMMENT ADD CONSTRAINT FK_COMMENT_WRITER FOREIGN KEY (WRITER_ID) REFERENCES KURO_MEMBER (ID) ON DELETE SET NULL;
ALTER TABLE COMMUNITY_MESSAGE ADD CONSTRAINT FK_MESSAGE_MEMBER FOREIGN KEY (MEMBER_ID) REFERENCES KURO_MEMBER (ID) ON DELETE CASCADE;
 
 
-- ---------------------------------------------------------------------
-- [4] 결과 확인 (이 두 문장의 결과를 그대로 알려주세요)
-- ---------------------------------------------------------------------
 
-- 4-1. 컬럼 목록
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
  FROM USER_TAB_COLUMNS
 WHERE TABLE_NAME IN ('COMMUNITY_POST', 'COMMUNITY_COMMENT', 'COMMUNITY_MESSAGE', 'COMMUNITY_DEAL', 'COMMUNITY_FAQ')
 ORDER BY TABLE_NAME, COLUMN_ID;
 
-- 4-2. 테이블 / 시퀀스 존재 확인 (테이블 5개 + 시퀀스 5개가 나와야 합니다)
SELECT 'TABLE' AS KIND, TABLE_NAME AS NAME FROM USER_TABLES
 WHERE TABLE_NAME IN ('COMMUNITY_POST', 'COMMUNITY_COMMENT', 'COMMUNITY_MESSAGE', 'COMMUNITY_DEAL', 'COMMUNITY_FAQ')
UNION ALL
SELECT 'SEQUENCE', SEQUENCE_NAME FROM USER_SEQUENCES
 WHERE SEQUENCE_NAME IN ('SEQ_COMMUNITY_POST', 'SEQ_COMMUNITY_COMMENT', 'SEQ_COMMUNITY_MESSAGE', 'SEQ_COMMUNITY_DEAL', 'SEQ_COMMUNITY_FAQ');
 
SELECT CONSTRAINT_NAME, TABLE_NAME FROM USER_CONSTRAINTS
 WHERE CONSTRAINT_NAME IN ('FK_POST_WRITER', 'FK_COMMENT_WRITER', 'FK_MESSAGE_MEMBER');

SELECT SEQUENCE_NAME FROM USER_SEQUENCES WHERE SEQUENCE_NAME LIKE 'SEQ_COMMUNITY%';
 
 
 
 
 
 
 
 
 
 
 
 
 -- =====================================================================
-- 커뮤니티 화면 확인용 테스트 데이터 (공지 2건 · FAQ 4건 · 특가 2건)
-- 모두 "[테스트]" 로 시작해서 나중에 골라서 지울 수 있습니다.
-- 문장을 한 번에 실행(SQL Developer: F5) 해도 되고, 마지막에 COMMIT 까지 실행하세요.
-- =====================================================================

INSERT INTO COMMUNITY_POST (POST_ID, BOARD_TYPE, TITLE, CONTENT, WRITER_ID)
VALUES (SEQ_COMMUNITY_POST.NEXTVAL, 'NOTICE', '[테스트] 공지사항 첫 번째 글', '테스트 공지 내용입니다.', NULL);

INSERT INTO COMMUNITY_POST (POST_ID, BOARD_TYPE, TITLE, CONTENT, WRITER_ID)
VALUES (SEQ_COMMUNITY_POST.NEXTVAL, 'NOTICE', '[테스트] 공지사항 두 번째 글', '두 번째 테스트 공지 내용입니다.', NULL);

INSERT INTO COMMUNITY_FAQ (FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER)
VALUES (SEQ_COMMUNITY_FAQ.NEXTVAL, '회원/기타', '[테스트] 회원가입은 어떻게 하나요?', '테스트 답변입니다.', 10);

INSERT INTO COMMUNITY_FAQ (FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER)
VALUES (SEQ_COMMUNITY_FAQ.NEXTVAL, '회원/기타', '[테스트] 회원정보는 어떻게 변경하나요?', '테스트 답변입니다.', 11);

INSERT INTO COMMUNITY_FAQ (FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER)
VALUES (SEQ_COMMUNITY_FAQ.NEXTVAL, '배송비', '[테스트] 배송비는 어떻게 계산되나요?', '테스트 답변입니다.', 20);

INSERT INTO COMMUNITY_FAQ (FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER)
VALUES (SEQ_COMMUNITY_FAQ.NEXTVAL, '배송비', '[테스트] 무게 측정은 언제 하나요?', '테스트 답변입니다.', 21);

INSERT INTO COMMUNITY_DEAL (DEAL_ID, NAME, PRICE_JPY, MIN_QTY)
VALUES (SEQ_COMMUNITY_DEAL.NEXTVAL, '[테스트] 특가 상품 A', 1280, 3);

INSERT INTO COMMUNITY_DEAL (DEAL_ID, NAME, PRICE_JPY, MIN_QTY)
VALUES (SEQ_COMMUNITY_DEAL.NEXTVAL, '[테스트] 특가 상품 B', 3500,  1);

COMMIT;



-- 알림 테스트 (내 계정으로 1건)
INSERT INTO COMMUNITY_MESSAGE (MESSAGE_ID, MEMBER_ID, MSG_TYPE, CONTENT)
VALUES (SEQ_COMMUNITY_MESSAGE.NEXTVAL, (SELECT ID FROM KURO_MEMBER WHERE LOGIN_ID = 'java1026'), '입고', '[테스트] 입고가 완료되었습니다.');

-- 관리자 답변 테스트 (4번에서 쓴 글 번호)
INSERT INTO COMMUNITY_COMMENT (COMMENT_ID, POST_ID, CONTENT)
VALUES (SEQ_COMMUNITY_COMMENT.NEXTVAL, 4, '[테스트] 답변드립니다.');
UPDATE COMMUNITY_POST SET ANSWER_YN = 'Y' WHERE POST_ID = 4;
COMMIT;

-- ---------------------------------------------------------------------
-- 테스트가 끝나면 아래로 테스트 데이터만 지웁니다 (필요할 때 실행)
-- ---------------------------------------------------------------------
-- DELETE FROM COMMUNITY_POST WHERE TITLE LIKE '[테스트]%';
-- DELETE FROM COMMUNITY_FAQ  WHERE QUESTION LIKE '[테스트]%';
-- DELETE FROM COMMUNITY_DEAL WHERE NAME LIKE '[테스트]%';
-- COMMIT;
 
 --DELETE FROM COMMUNITY_POST    WHERE TITLE LIKE '[테스트]%';
--DELETE FROM COMMUNITY_FAQ     WHERE QUESTION LIKE '[테스트]%';
--DELETE FROM COMMUNITY_DEAL    WHERE NAME LIKE '[테스트]%';
--DELETE FROM COMMUNITY_MESSAGE WHERE CONTENT LIKE '[테스트]%';
--COMMIT;
--화면 확인 때 직접 쓴 1:1문의는 제목이 [테스트]가 아닐 수 있음. 
--그 글은 화면에서 삭제하거나 SELECT POST_ID, TITLE FROM COMMUNITY_POST WHERE BOARD TYPE = 'QNA'; 로 확인한 뒤 번호로 지워야 함
--관리자 답변은 글이 지워질 떄 같이 삭제됨
 