-- ============================================================
-- 05_payment_waybill.sql : 결제 완료 시 만들어지는 운송장 (한국 / 일본)
-- ai2gi 계정으로 접속해서 문장을 하나씩 실행하세요. (한 번만 실행)
-- 이미 실행한 문장을 다시 실행하면 ORA-01430 오류가 나는데, 그 문장은 건너뛰면 됩니다.
-- ============================================================

-- 1) PAYMENT 테이블에 운송장 컬럼 4개 추가
ALTER TABLE PAYMENT ADD (
    KR_METHOD       VARCHAR2(10),    -- 한국 운송 방법 : AIR 도쿄에어 / SEA 후쿠오카 고속해상
    KR_WAYBILL_NO   VARCHAR2(30),    -- 한국 운송장번호
    JP_CARRIER      VARCHAR2(20),    -- 일본 택배사 : YAMATO SAGAWA AMAZON JAPANPOST SEINO FUKUTSU LASTONE MEITETSU
    JP_WAYBILL_NO   VARCHAR2(30)     -- 일본 운송장번호
);

-- 2) 운송장번호로 찾는 조회가 빠르도록 인덱스
CREATE INDEX PAYMENT_KR_WB_IDX ON PAYMENT (KR_WAYBILL_NO);
CREATE INDEX PAYMENT_JP_WB_IDX ON PAYMENT (JP_WAYBILL_NO);

COMMIT;

-- 3) 확인용
-- SELECT ID, STATUS, KR_METHOD, KR_WAYBILL_NO, JP_CARRIER, JP_WAYBILL_NO FROM PAYMENT ORDER BY ID DESC;
