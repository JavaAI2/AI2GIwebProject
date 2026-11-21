-- ============================================================
-- 01b_member_role.sql : 회원 권한(ROLE) 컬럼 추가 (일반 회원 / 관리자)
-- ai2gi 계정으로 접속해서 위에서부터 하나씩 실행하세요. (01_kuro_member.sql 다음에 실행)
--
-- AdminFilter / AdminDAO 가 KURO_MEMBER.ROLE 로 관리자를 판단합니다.
-- 이 컬럼이 없으면 /admin/* 화면을 쓸 수 없습니다.
-- 이미 컬럼 · 제약이 있어도 오류 없이 넘어가도록 만들었으므로 다시 실행해도 됩니다.
-- ============================================================

-- 1) ROLE 컬럼 추가 (기본값 USER)
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE KURO_MEMBER ADD (ROLE VARCHAR2(10) DEFAULT ''USER'' NOT NULL)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1430 THEN RAISE; END IF;   -- ORA-01430: 이미 있는 컬럼이면 넘어간다
END;
/

-- 2) USER / ADMIN 만 들어가도록 제약을 건다
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE KURO_MEMBER ADD CONSTRAINT CK_MEMBER_ROLE CHECK (ROLE IN (''USER'', ''ADMIN''))';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2264 THEN RAISE; END IF;   -- ORA-02264: 이미 있는 제약 이름이면 넘어간다
END;
/

-- 3) 관리자로 지정할 회원 (로그인 ID 를 바꿔서 실행)
-- UPDATE KURO_MEMBER SET ROLE = 'ADMIN' WHERE LOGIN_ID = '여기에_관리자_ID';
-- COMMIT;

-- 4) 확인용
-- SELECT LOGIN_ID, NAME, ROLE FROM KURO_MEMBER ORDER BY ID;
