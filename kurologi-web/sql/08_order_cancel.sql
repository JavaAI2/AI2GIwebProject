-- ============================================================
-- 08_order_cancel.sql : 현지 반품신청(배송 취소 · 환불)을 위한 준비
-- ai2gi 계정으로 접속해서 위에서부터 하나씩 실행하세요.
--
-- 배송 중인 주문을 취소하면 BUY_ORDER.STATUS 가 'CANCELED' 로 바뀝니다.
-- STATUS 에 CHECK 제약이 걸려 있으면 'CANCELED' 를 넣을 수 없으므로, 제약을 다시 만들어 줍니다.
-- ============================================================

-- 1) 현재 STATUS 제약의 이름과 내용을 확인한다 (SEARCH_CONDITION 에 STATUS IN (...) 이 보이는 줄의 이름을 기억)
SELECT CONSTRAINT_NAME, SEARCH_CONDITION
  FROM USER_CONSTRAINTS
 WHERE TABLE_NAME = 'BUY_ORDER' AND CONSTRAINT_TYPE = 'C';

-- 2) STATUS 제약을 지운다.
--    1) 에서 확인한 이름이 BUY_ORDER_STATUS_CK 가 아니면 아래 이름을 그 이름으로 바꿔서 실행한다.
--    (STATUS 에 대한 제약이 아예 없었다면 이 문장은 건너뛴다)
ALTER TABLE BUY_ORDER DROP CONSTRAINT BUY_ORDER_STATUS_CK;

-- 3) 취소 상태(CANCELED)를 포함해서 다시 만든다
ALTER TABLE BUY_ORDER ADD CONSTRAINT BUY_ORDER_STATUS_CK
    CHECK (STATUS IN ('WAIT', 'SUBMIT', 'RECEIVED', 'BILLED', 'SHIPPED', 'DELIVERING', 'CANCELED'));

-- 4) 확인용 : 배송 중(출고 · 국내 배송 중)인 주문 목록
-- SELECT ORDER_ID, ORDER_NO, MEMBER_ID, STATUS, PAY_STATUS FROM BUY_ORDER WHERE STATUS IN ('SHIPPED', 'DELIVERING');
