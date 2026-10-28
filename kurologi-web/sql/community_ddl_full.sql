-- =====================================================================
-- 커뮤니티 전체 설치 스크립트 (처음 설치용)
--
--   * 커뮤니티 테이블이 아직 없는 DB (팀원 PC, 발표용 PC 등)에서 "한 번만" 실행합니다.
--   * 이미 community_ddl_v2.sql 까지 적용한 DB 에서는 실행하지 마세요 (이미 있다는 오류가 납니다).
--   * 전제: KURO_MEMBER 테이블이 먼저 만들어져 있어야 합니다 (회원 연결 FK).
--   * DROP 문장은 없습니다. 문장을 하나씩 선택해서 실행하세요 (SQL Developer: Ctrl+Enter).
--
-- 만들어지는 것: 시퀀스 4개, 테이블 4개 (글 / 댓글 / 알림 / FAQ)
-- =====================================================================


-- ---------------------------------------------------------------------
-- [1] 시퀀스
-- ---------------------------------------------------------------------
CREATE SEQUENCE SEQ_COMMUNITY_POST    START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_COMMUNITY_COMMENT START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_COMMUNITY_MESSAGE START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_COMMUNITY_FAQ     START WITH 1 INCREMENT BY 1 NOCACHE;


-- ---------------------------------------------------------------------
-- [2] 게시글 (공지사항 + 1:1게시판 공용)
-- ---------------------------------------------------------------------
CREATE TABLE COMMUNITY_POST (
    POST_ID     NUMBER              CONSTRAINT PK_COMMUNITY_POST PRIMARY KEY,
    BOARD_TYPE  VARCHAR2(10)        DEFAULT 'QNA' NOT NULL,   -- NOTICE=공지사항, QNA=1:1게시판
    TITLE       VARCHAR2(200 CHAR)  NOT NULL,
    CONTENT     VARCHAR2(4000)      NOT NULL,                 -- 바이트 기준: 한글 약 1,300자
    WRITER_ID   NUMBER(19),                                   -- 작성 회원(KURO_MEMBER.ID), NULL = 관리자
    VIEW_COUNT  NUMBER              DEFAULT 0 NOT NULL,
    LIKE_COUNT  NUMBER              DEFAULT 0 NOT NULL,
    ANSWER_YN   CHAR(1)             DEFAULT 'N' NOT NULL,     -- 1:1게시판 답변 여부
    CREATED_AT  DATE                DEFAULT SYSDATE NOT NULL,
    UPDATED_AT  DATE,
    CONSTRAINT CK_POST_VIEW   CHECK (VIEW_COUNT >= 0),
    CONSTRAINT CK_POST_LIKE   CHECK (LIKE_COUNT >= 0),
    CONSTRAINT CK_POST_TYPE   CHECK (BOARD_TYPE IN ('NOTICE', 'QNA')),
    CONSTRAINT CK_POST_ANSWER CHECK (ANSWER_YN IN ('Y', 'N')),
    CONSTRAINT FK_POST_WRITER FOREIGN KEY (WRITER_ID) REFERENCES KURO_MEMBER (ID) ON DELETE SET NULL
);

COMMENT ON COLUMN COMMUNITY_POST.BOARD_TYPE IS 'NOTICE=공지사항, QNA=1:1게시판';
COMMENT ON COLUMN COMMUNITY_POST.ANSWER_YN  IS '1:1게시판 답변 여부 (Y/N)';
COMMENT ON COLUMN COMMUNITY_POST.WRITER_ID  IS '작성 회원 번호(KURO_MEMBER.ID). NULL = 관리자(운영자) 작성';


-- ---------------------------------------------------------------------
-- [3] 댓글 (1:1게시판에서는 관리자 답변을 저장)
-- ---------------------------------------------------------------------
CREATE TABLE COMMUNITY_COMMENT (
    COMMENT_ID  NUMBER               CONSTRAINT PK_COMMUNITY_COMMENT PRIMARY KEY,
    POST_ID     NUMBER               NOT NULL,
    PARENT_ID   NUMBER,                                       -- NULL = 댓글, 값 있음 = 답글
    CONTENT     VARCHAR2(1000 CHAR)  NOT NULL,
    WRITER_ID   NUMBER(19),                                   -- 작성 회원(KURO_MEMBER.ID), NULL = 관리자
    DELETED_YN  CHAR(1)              DEFAULT 'N' NOT NULL,
    CREATED_AT  DATE                 DEFAULT SYSDATE NOT NULL,
    CONSTRAINT FK_COMMENT_POST   FOREIGN KEY (POST_ID)   REFERENCES COMMUNITY_POST (POST_ID) ON DELETE CASCADE,
    CONSTRAINT FK_COMMENT_PARENT FOREIGN KEY (PARENT_ID) REFERENCES COMMUNITY_COMMENT (COMMENT_ID) ON DELETE CASCADE,
    CONSTRAINT FK_COMMENT_WRITER FOREIGN KEY (WRITER_ID) REFERENCES KURO_MEMBER (ID) ON DELETE SET NULL,
    CONSTRAINT CK_COMMENT_DELETED CHECK (DELETED_YN IN ('Y', 'N'))
);

CREATE INDEX IDX_COMMENT_POST   ON COMMUNITY_COMMENT (POST_ID);
CREATE INDEX IDX_COMMENT_PARENT ON COMMUNITY_COMMENT (PARENT_ID);

COMMENT ON COLUMN COMMUNITY_COMMENT.WRITER_ID IS '작성 회원 번호(KURO_MEMBER.ID). NULL = 관리자(운영자) 작성';


-- ---------------------------------------------------------------------
-- [4] 알림메세지
-- ---------------------------------------------------------------------
CREATE TABLE COMMUNITY_MESSAGE (
    MESSAGE_ID  NUMBER               CONSTRAINT PK_COMMUNITY_MESSAGE PRIMARY KEY,
    MEMBER_ID   NUMBER(19)           NOT NULL,                 -- 받는 회원 (KURO_MEMBER.ID)
    MSG_TYPE    VARCHAR2(30 CHAR)    NOT NULL,                 -- 구분 (입고 / 출고 / 배송 등)
    CONTENT     VARCHAR2(1000 CHAR)  NOT NULL,
    SENT_AT     DATE                 DEFAULT SYSDATE NOT NULL,
    READ_YN     CHAR(1)              DEFAULT 'N' NOT NULL,
    CONSTRAINT CK_MESSAGE_READ   CHECK (READ_YN IN ('Y', 'N')),
    CONSTRAINT FK_MESSAGE_MEMBER FOREIGN KEY (MEMBER_ID) REFERENCES KURO_MEMBER (ID) ON DELETE CASCADE
);

CREATE INDEX IDX_MESSAGE_MEMBER ON COMMUNITY_MESSAGE (MEMBER_ID, MESSAGE_ID);


-- ---------------------------------------------------------------------
-- [5] 자주묻는 질문
-- ---------------------------------------------------------------------
CREATE TABLE COMMUNITY_FAQ (
    FAQ_ID      NUMBER               CONSTRAINT PK_COMMUNITY_FAQ PRIMARY KEY,
    CATEGORY    VARCHAR2(50 CHAR)    NOT NULL,
    QUESTION    VARCHAR2(300 CHAR)   NOT NULL,
    ANSWER      VARCHAR2(4000)       NOT NULL,
    SORT_ORDER  NUMBER(5)            DEFAULT 0 NOT NULL,       -- 작을수록 먼저 (분류 순서도 이 값으로 정해짐)
    VISIBLE_YN  CHAR(1)              DEFAULT 'Y' NOT NULL,
    CREATED_AT  DATE                 DEFAULT SYSDATE NOT NULL,
    CONSTRAINT CK_FAQ_VISIBLE CHECK (VISIBLE_YN IN ('Y', 'N'))
);


-- ---------------------------------------------------------------------
-- [6] 설치 확인 : 테이블 4개 + 시퀀스 4개가 나와야 합니다
-- ---------------------------------------------------------------------
SELECT 'TABLE' AS KIND, TABLE_NAME AS NAME FROM USER_TABLES
 WHERE TABLE_NAME IN ('COMMUNITY_POST', 'COMMUNITY_COMMENT', 'COMMUNITY_MESSAGE', 'COMMUNITY_FAQ')
UNION ALL
SELECT 'SEQUENCE', SEQUENCE_NAME FROM USER_SEQUENCES
 WHERE SEQUENCE_NAME IN ('SEQ_COMMUNITY_POST', 'SEQ_COMMUNITY_COMMENT', 'SEQ_COMMUNITY_MESSAGE', 'SEQ_COMMUNITY_FAQ');