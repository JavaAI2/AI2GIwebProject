-- ============================================================
-- 07_backfill_pay_status.sql : 이미 결제를 끝낸 주문을 "결제완료"로 맞추기
--
-- 배경 : 결제 화면에서 결제를 끝내도 주문(BUY_ORDER)의 PAY_STATUS 가 UNPAID 로 남아
--        구매대행 / 배송대행 주문내역에 "미결제"로 보이는 문제가 있었다.
--        이제 결제하면 서버가 PAY_STATUS 를 PAID 로 바꾸지만(PaymentService),
--        코드를 고치기 전에 이미 결제한 주문은 이 SQL 로 한 번만 맞춰 주면 된다.
-- ai2gi 계정으로 접속해서 위에서부터 하나씩 실행하세요.
-- ============================================================

-- 1) 확인 : 결제는 끝났는데 주문이 미결제로 남은 건 (결과가 있으면 아래 2)를 실행)
SELECT o.ORDER_NO, o.STATUS, o.PAY_STATUS, c.STATUS AS CHARGE_STATUS
  FROM BUY_ORDER o JOIN CHARGE c ON c.ORDER_NO = o.ORDER_NO
 WHERE c.STATUS = 'PAID' AND o.PAY_STATUS = 'UNPAID';

-- 2) 맞추기
UPDATE BUY_ORDER o
   SET o.PAY_STATUS = 'PAID', o.STATUS_UPDATED_AT = SYSTIMESTAMP
 WHERE o.PAY_STATUS = 'UNPAID'
   AND o.STATUS <> 'WAIT'
   AND EXISTS (SELECT 1 FROM CHARGE c WHERE c.ORDER_NO = o.ORDER_NO AND c.STATUS = 'PAID');

COMMIT;

-- 3) 다시 확인 : 아무 줄도 나오지 않으면 성공
SELECT o.ORDER_NO, o.STATUS, o.PAY_STATUS
  FROM BUY_ORDER o JOIN CHARGE c ON c.ORDER_NO = o.ORDER_NO
 WHERE c.STATUS = 'PAID' AND o.PAY_STATUS = 'UNPAID';
