-- ============================================================
-- 05_drop_stock.sql : 재고구매신청 기능을 뺐으므로 03_stock.sql 로 만든 테이블 정리 (선택)
-- 03_stock.sql 을 이미 실행했다면 ai2gi 접속에서 실행하세요. 안 해도 동작에는 영향이 없습니다.
-- 03_stock.sql 을 실행한 적이 없다면 이 파일도 실행하지 마세요. (없는 테이블이라 오류가 납니다)
-- ============================================================

DROP TABLE STOCK_ORDER;       -- STOCK_ITEM 을 참조하므로 먼저 지운다
DROP TABLE STOCK_ITEM;
DROP SEQUENCE STOCK_ORDER_SEQ;
DROP SEQUENCE STOCK_ITEM_SEQ;
