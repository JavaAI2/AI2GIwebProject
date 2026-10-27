-- ============================================================
-- 01_kuro_member.sql : 회원 테이블 + 시퀀스
-- 실행 순서 : 00_create_user_ai2gi.sql(system, 계정이 없을 때만) -> 이 파일(01) -> 02_buy_order.sql
-- SQL Developer 에서 DBmanager 와 같은 계정(ai2gi / 1234)으로 접속해서
-- 전체 선택(Ctrl+A) 후 "스크립트 실행(F5)" 으로 실행하세요.
-- ============================================================

-- 회원번호를 자동으로 1씩 증가시키는 시퀀스 (MemberDAO.nextId 가 사용)
CREATE SEQUENCE MEMBER_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE KURO_MEMBER (
    ID                       NUMBER              NOT NULL,                  -- 회원 고유번호 (MEMBER_SEQ)
    LOGIN_ID                 VARCHAR2(20)        NOT NULL,                  -- 로그인 아이디
    PASSWORD_HASH            VARCHAR2(100)       NOT NULL,                  -- BCrypt 암호화 비밀번호(60자)
    NAME                     VARCHAR2(60 CHAR)   NOT NULL,                  -- 한글 이름
    ENGLISH_NAME             VARCHAR2(50),                                  -- 영문 이름
    MAILBOX_NO               VARCHAR2(20)        NOT NULL,                  -- 사서함번호 KR0000001
    MEMBER_NO                VARCHAR2(20)        NOT NULL,                  -- 회원번호 0000001
    PHONE                    VARCHAR2(30),                                  -- 휴대폰
    EMAIL                    VARCHAR2(100),                                 -- 이메일
    SMS_REFUSE               CHAR(1)             DEFAULT 'N' NOT NULL,      -- SMS 수신거부 Y/N
    MEMBER_TYPE              VARCHAR2(20)        DEFAULT 'PERSONAL' NOT NULL, -- PERSONAL / BUSINESS
    GRADE                    VARCHAR2(20)        DEFAULT 'BASIC' NOT NULL,  -- BASIC / PARTNER / FAMILY / ROYAL_FAMILY
    POINTS                   NUMBER              DEFAULT 0 NOT NULL,        -- 포인트
    REFERRAL_POINTS_PENDING  NUMBER              DEFAULT 0 NOT NULL,        -- 추천 대기 포인트
    REFERRAL_CODE            VARCHAR2(30),                                  -- 추천인 코드
    DEPOSIT                  NUMBER              DEFAULT 0 NOT NULL,        -- 예치금
    COUPONS                  NUMBER              DEFAULT 0 NOT NULL,        -- 쿠폰 개수
    LAST_LOGIN_AT            TIMESTAMP,                                     -- 마지막 로그인
    WITHDRAWN                CHAR(1)             DEFAULT 'N' NOT NULL,      -- 탈퇴 여부 Y/N
    PW_QUIZ_ANSWER           VARCHAR2(100),                                 -- 비밀번호 퀴즈 답(BCrypt)
    CREATED_AT               TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT KURO_MEMBER_PK        PRIMARY KEY (ID),
    CONSTRAINT KURO_MEMBER_LOGIN_UK  UNIQUE (LOGIN_ID),
    CONSTRAINT KURO_MEMBER_MAILBOX_UK UNIQUE (MAILBOX_NO),
    CONSTRAINT KURO_MEMBER_TYPE_CK   CHECK (MEMBER_TYPE IN ('PERSONAL','BUSINESS')),
    CONSTRAINT KURO_MEMBER_GRADE_CK  CHECK (GRADE IN ('BASIC','PARTNER','FAMILY','ROYAL_FAMILY'))
);

COMMIT;

-- 확인용 (회원가입 후 조회해 보세요)
-- SELECT ID, LOGIN_ID, NAME, MAILBOX_NO, MEMBER_NO FROM KURO_MEMBER;
