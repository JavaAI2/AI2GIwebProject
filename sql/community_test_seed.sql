-- =====================================================================
-- 커뮤니티 화면 확인용 테스트 데이터 (공지 2건 · FAQ 4건 · 특가 2건)
-- 모두 "[테스트]" 로 시작해서 나중에 골라서 지울 수 있습니다.
-- 문장을 한 번에 실행(SQL Developer: F5) 해도 되고, 마지막에 COMMIT 까지 실행하세요.
-- =====================================================================

INSERT INTO COMMUNITY_POST (POST_ID, BOARD_TYPE, TITLE, CONTENT, WRITER_ID)
VALUES (SEQ_COMMUNITY_POST.NEXTVAL, 'NOTICE', '[테스트] 공지사항 첫 번째 글', '테스트 공지 내용입니다.', NULL);

INSERT INTO COMMUNITY_POST (POST_ID, BOARD_TYPE, TITLE, CONTENT, WRITER_ID)
VALUES (SEQ_COMMUNITY_POST.NEXTVAL, 'NOTICE', '[테스트] 공지사항 두 번째 글', '두 번째 테스트 공지 내용입니다.', NULL);

INSERT INTO COMMUNITY_FAQ (FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER)
VALUES (SEQ_COMMUNITY_FAQ.NEXTVAL, '회원/기타', '[테스트] 회원가입은 어떻게 하나요?', '테스트 답변입니다.', 10);

INSERT INTO COMMUNITY_FAQ (FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER)
VALUES (SEQ_COMMUNITY_FAQ.NEXTVAL, '회원/기타', '[테스트] 회원정보는 어떻게 변경하나요?', '테스트 답변입니다.', 11);

INSERT INTO COMMUNITY_FAQ (FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER)
VALUES (SEQ_COMMUNITY_FAQ.NEXTVAL, '배송비', '[테스트] 배송비는 어떻게 계산되나요?', '테스트 답변입니다.', 20);

INSERT INTO COMMUNITY_FAQ (FAQ_ID, CATEGORY, QUESTION, ANSWER, SORT_ORDER)
VALUES (SEQ_COMMUNITY_FAQ.NEXTVAL, '배송비', '[테스트] 무게 측정은 언제 하나요?', '테스트 답변입니다.', 21);

INSERT INTO COMMUNITY_DEAL (DEAL_ID, NAME, PRICE_JPY, MIN_QTY)
VALUES (SEQ_COMMUNITY_DEAL.NEXTVAL, '[테스트] 특가 상품 A', 1280, 3);

INSERT INTO COMMUNITY_DEAL (DEAL_ID, NAME, PRICE_JPY, MIN_QTY)
VALUES (SEQ_COMMUNITY_DEAL.NEXTVAL, '[테스트] 특가 상품 B', 3500, 1);

COMMIT;

-- ---------------------------------------------------------------------
-- 테스트가 끝나면 아래로 테스트 데이터만 지웁니다 (필요할 때 실행)
-- ---------------------------------------------------------------------
-- DELETE FROM COMMUNITY_POST WHERE TITLE LIKE '[테스트]%';
-- DELETE FROM COMMUNITY_FAQ  WHERE QUESTION LIKE '[테스트]%';
-- DELETE FROM COMMUNITY_DEAL WHERE NAME LIKE '[테스트]%';
-- COMMIT;
