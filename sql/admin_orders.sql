-- ============================================================
-- 07_order_status_steps.sql : 주문 진행 5단계용 상태값 추가
--   ai2gi 계정으로 접속 -> 전체 선택(Ctrl+A) -> 스크립트 실행(F5)
--   * 여러 번 실행해도 안전합니다. 기존 주문 데이터는 바뀌지 않습니다.
--   * 새 컬럼/테이블은 없고, BUY_ORDER.STATUS 에 넣을 수 있는 값만 늘립니다.
--
--   단계  STATUS 값     화면 이름
--   01    SUBMIT        신청 완료
--   02    RECEIVED      현지 창고 입고
--   03    BILLED        배송비 대기      (신규)
--   04    SHIPPED       결제 완료 / 출고
--   05    DELIVERING    국내 배송 중     (신규)
--   (WAIT 접수대기는 신청서를 저장만 한 상태로 그대로 유지)
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE BUY_ORDER DROP CONSTRAINT BUY_ORDER_STATUS_CK';
EXCEPTION WHEN OTHERS THEN NULL;   -- 제약이 없으면 무시
END;
/

ALTER TABLE BUY_ORDER ADD CONSTRAINT BUY_ORDER_STATUS_CK
    CHECK (STATUS IN ('WAIT', 'SUBMIT', 'RECEIVED', 'BILLED', 'SHIPPED', 'DELIVERING'));

COMMIT;

-- 확인 : 제약 조건에 6개 값이 모두 보이면 성공
SELECT CONSTRAINT_NAME, SEARCH_CONDITION
  FROM USER_CONSTRAINTS
 WHERE CONSTRAINT_NAME = 'BUY_ORDER_STATUS_CK';
