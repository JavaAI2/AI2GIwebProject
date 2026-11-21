-- =====================================================================
-- 커뮤니티 DDL v2
--   기존 COMMUNITY_POST / COMMUNITY_COMMENT 는 그대로 두고 보완하고,
--   알림메세지 · FAQ 테이블 2개를 새로 만듭니다.
--
-- ★ DROP 문장은 하나도 없습니다.
-- ★ 문장을 "하나씩" 선택해서 실행하세요 (SQL Developer: 문장에 커서 두고 Ctrl+Enter).
-- ★ 이미 실행된 문장을 다시 실행하면 오류(ORA-01430, ORA-00955, ORA-02264 등)가 납니다.
--   그 문장은 이미 적용된 것이니 건너뛰고 다음 문장으로 가면 됩니다.
--
-- 순서: [0] 확인 -> [1] 기존 테이블 보완 -> [2] 새 테이블 -> [3] 회원 연결(FK) -> [4] 결과 확인
-- =====================================================================


-- ---------------------------------------------------------------------
-- [0] 실행 전 확인 (먼저 이 문장부터)
--     POST_ROWS / COMMENT_ROWS : 현재 글/댓글 개수
--     DB_CHARSET               : AL32UTF8 이면 한글 1글자 = 3바이트, KO16MSWIN949 이면 2바이트
-- ---------------------------------------------------------------------
SELECT 'POST_ROWS' AS ITEM, TO_CHAR(COUNT(*)) AS VAL FROM COMMUNITY_POST
UNION ALL
SELECT 'COMMENT_ROWS', TO_CHAR(COUNT(*)) FROM COMMUNITY_COMMENT
UNION ALL
SELECT 'DB_CHARSET', VALUE FROM NLS_DATABASE_PARAMETERS WHERE PARAMETER = 'NLS_CHARACTERSET';


-- ---------------------------------------------------------------------
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
CREATE SEQUENCE SEQ_COMMUNITY_FAQ     START WITH 1 INCREMENT BY 1 NOCACHE;

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

-- 2-2. 자주묻는 질문 (faq.jsp)
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
 WHERE TABLE_NAME IN ('COMMUNITY_POST', 'COMMUNITY_COMMENT', 'COMMUNITY_MESSAGE', 'COMMUNITY_FAQ')
 ORDER BY TABLE_NAME, COLUMN_ID;

-- 4-2. 테이블 / 시퀀스 존재 확인 (테이블 4개 + 시퀀스 4개가 나와야 합니다)
SELECT 'TABLE' AS KIND, TABLE_NAME AS NAME FROM USER_TABLES
 WHERE TABLE_NAME IN ('COMMUNITY_POST', 'COMMUNITY_COMMENT', 'COMMUNITY_MESSAGE', 'COMMUNITY_FAQ')
UNION ALL
SELECT 'SEQUENCE', SEQUENCE_NAME FROM USER_SEQUENCES
 WHERE SEQUENCE_NAME IN ('SEQ_COMMUNITY_POST', 'SEQ_COMMUNITY_COMMENT', 'SEQ_COMMUNITY_MESSAGE', 'SEQ_COMMUNITY_FAQ');