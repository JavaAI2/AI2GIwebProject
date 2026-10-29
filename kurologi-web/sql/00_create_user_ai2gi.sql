-- ============================================================
-- 00_create_user_ai2gi.sql : 프로젝트용 계정 ai2gi 만들기
-- 이 파일만 system 계정으로 접속해서 실행합니다. (01, 02 는 ai2gi 로 실행)
-- 이미 ai2gi 계정이 있으면(ORA-01920 오류) 이 파일은 건너뛰세요.
-- ============================================================

-- Oracle 18c / 21c XE 에서 ORA-65096 오류가 나면 아래 줄의 주석(--)을 풀고 먼저 실행하세요.
-- (11g XE 에서는 이 줄이 오류가 나므로 주석 그대로 두세요)
-- ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

-- 비밀번호가 숫자로 시작하면 큰따옴표로 감싸야 합니다
CREATE USER ai2gi IDENTIFIED BY "1234";

-- 접속(CONNECT) + 테이블/시퀀스 생성(RESOURCE) 권한
GRANT CONNECT, RESOURCE TO ai2gi;

-- 테이블 공간 사용 권한
GRANT UNLIMITED TABLESPACE TO ai2gi;
