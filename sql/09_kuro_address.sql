-- ============================================================
-- 09_kuro_address.sql : 나의 주소록 테이블 + 시퀀스
-- 마이페이지 "주소관리"가 DB 를 쓰도록 바뀌면서 필요하다. (전에는 메모리라 서버를 재시작하면 사라졌다)
-- SQL Developer 에서 DBmanager 와 같은 계정으로 접속해 전체 선택(Ctrl+A) 후 "스크립트 실행(F5)" 으로 실행하세요.
-- ============================================================

CREATE SEQUENCE ADDRESS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE KURO_ADDRESS (
    ID            NUMBER              NOT NULL,                       -- 주소 번호 (ADDRESS_SEQ)
    MEMBER_ID     NUMBER              NOT NULL,                       -- 주인 회원 (KURO_MEMBER.ID)
    NAME          VARCHAR2(90 CHAR)   NOT NULL,                       -- 받는 사람 이름
    ZIPCODE       VARCHAR2(10)        NOT NULL,                       -- 우편번호 5자리
    ADDRESS1      VARCHAR2(300 CHAR)  NOT NULL,                       -- 기본 주소
    ADDRESS2      VARCHAR2(300 CHAR),                                 -- 상세 주소
    COUNTRY       VARCHAR2(60)        DEFAULT 'South Korea' NOT NULL, -- 국가
    PHONE         VARCHAR2(30)        NOT NULL,                       -- 전화번호
    CUSTOMS_CODE  VARCHAR2(20)        NOT NULL,                       -- 개인통관고유부호 P + 12자리
    CREATED_AT    TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT KURO_ADDRESS_PK PRIMARY KEY (ID)
);

CREATE INDEX KURO_ADDRESS_MEMBER_IX ON KURO_ADDRESS (MEMBER_ID);

COMMIT;

-- 확인용
-- SELECT * FROM KURO_ADDRESS;
