<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="jp.kurologi.service.DashboardBoard" %>
<%@ page import="jp.kurologi.service.DashboardBoard.NoticeRow" %>
<%@ page import="jp.kurologi.service.DashboardBoard.QnaRow" %>
<%@ page import="jp.kurologi.service.DashboardBoard.FaqGroup" %>
<%@ page import="jp.kurologi.service.DashboardBoard.FaqRow" %>
<%@ page import="jp.kurologi.web.Html" %>
<%@ page import="jp.kurologi.web.Session" %>
<%
    String ctx = request.getContextPath();
    request.setAttribute("menu", "status");   // layout.jsp 주 메뉴에서 현재 메뉴 표시

    // 공지사항 · 나의 1:1 질문 · 자주하는 질문은 커뮤니티 DB(COMMUNITY_POST, COMMUNITY_FAQ)에서 읽는다.
    Long memberId = Session.memberId(request);
    List<NoticeRow> notices = DashboardBoard.notices(4);
    List<QnaRow> myQuestions = (memberId == null) ? new ArrayList<QnaRow>() : DashboardBoard.myQuestions(memberId, 4);
    List<FaqGroup> faqGroups = DashboardBoard.faqGroups(5);
    int shippingCount = (memberId == null) ? 0 : DashboardBoard.shippingCount(memberId);   // 현지 반품신청 버튼의 숫자
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>종합현황 | NIPPON BUY</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from dashboard.css */
/* ==========================================================================
   NIPPON BUY — 종합현황 (마이페이지 대시보드)

   바꾸고 싶은 값은 :root 한 곳만 고치면 됩니다.
   순수 CSS · Bootstrap 클래스 없음 · 데스크톱 고정폭
   ========================================================================== */

:root {
  --teal:      #159692;
  --teal-dark: #107a77;
  --blue:      #107abd;
  --purple:    #6f42c1;   /* 나의 정보 머리글 */
  --orange:    #f0801a;   /* 숫자 강조, 액션 버튼 */
  --orange-bg: #fdf3e7;   /* 추가 확인 칸 배경 */
  --green:     #28a745;
  --red:       #dd4b39;

  --ink:       #333333;
  --body:      #555555;
  --muted:     #888888;

  --line:      #e5e5e5;
  --line-soft: #eeeeee;
  --fill:      #f7f7f7;
  --fill-head: #f6f6f6;

  --container: 1360px;
  --gutter:    15px;
  --radius:    4px;
}

/* --------------------------------------------------------------- 리셋 */

*,
*::before,
*::after { box-sizing: border-box; }

html { font-size: 16px; }

body {
  margin: 0;
  font-family: 'Noto Sans KR', serif;
  font-size: 0.875rem;
  line-height: 1.5;
  color: var(--body);
  background: #fff;
}

h1, h2, h3, h4 { margin: 0; color: #444; font-weight: 400; line-height: 1.5; }

img { max-width: 100%; height: auto; border: 0; }

a { color: var(--blue); text-decoration: none; }
a:hover { color: var(--teal); }

/* ------------------------------------------------------------- 레이아웃 */

.container {
  width: 100%;
  max-width: var(--container);
  margin: 0 auto;
  padding: 0 10px;
}

.row { display: flex; flex-wrap: wrap; margin: 0 calc(var(--gutter) * -1); }
.col { padding: 0 var(--gutter); }
.col--footer-logo { width: 16.6667%; }
.col--footer-info { width: 83.3333%; }

/* ------------------------------------------------------------- 상단 바 */

.topbar {
  border-bottom: 1px solid #c1c1c1;
  font-size: 13px;
  line-height: 44px;
}

.topbar__inner {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  min-height: 45px;
}

.topbar__links {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  margin: 0;
  padding: 0;
  list-style: none;
}

.topbar__links a {
  display: block;
  padding: 0 12px;
  height: 44px;
  line-height: 44px;
  font-size: 13px;
  color: #666;
}

.topbar__links a.kakao-btn { height: 44px; line-height: 44px; padding: 0 6px; }
.kakao-btn img { height: 35px; width: auto; padding-top: 5px; vertical-align: middle; }

/* -------------------------------------------------- 헤더 + 주 메뉴 */

.site-header {
  background: var(--teal);
  color: #eee;
  border-bottom: 1px solid rgba(255, 255, 255, .05);
}

.site-header__inner {
  display: flex;
  align-items: stretch;
  justify-content: space-between;
}

.site-header__logo { display: block; padding: 4px 0; }
.site-header__logo img { display: block; width: 250px; }

.main-nav { display: flex; align-items: stretch; }

.main-nav__list {
  display: flex;
  align-items: stretch;
  margin: 0;
  padding: 0;
  list-style: none;
}

.main-nav__item { position: relative; }

.main-nav__item > a {
  display: block;
  padding: 39px 10px;
  font-size: 16px;
  letter-spacing: -1px;
  color: #fff;
  white-space: nowrap;
}

.main-nav__item:hover { background: var(--teal-dark); }

.main-nav__submenu {
  display: none;
  position: absolute;
  top: 100%;
  left: 0;
  z-index: 100;
  width: 220px;
  margin: 0;
  padding: 10px;
  list-style: none;
  background: #fff;
  border: 1px solid var(--line-soft);
  border-top: 2px solid var(--blue);
  box-shadow: 0 13px 42px 11px rgba(0, 0, 0, .05);
}

.main-nav__item:hover .main-nav__submenu { display: block; }

.main-nav__submenu a {
  display: block;
  padding: 10px;
  font-size: 14px;
  font-family: 'Lato', sans-serif;
  color: #666;
  white-space: normal;
}

.main-nav__submenu a:hover { padding-left: 18px; color: var(--teal); }

/* ------------------------------------------------------- 페이지 제목 띠 */

.page-head {
  padding: 15px 0 13px;
  background: var(--fill-head);
  border-bottom: 1px solid var(--line-soft);
}

.page-head__inner { position: relative; min-height: 33px; }

.page-head__title {
  margin: 0;
  font-size: 22px;
  font-weight: 400;
  line-height: 1;
  letter-spacing: -2px;
  color: var(--ink);
}

.breadcrumb {
  position: absolute;
  top: 50%;
  right: 10px;
  margin: -10px 0 0;
  padding: 0;
  list-style: none;
  font-size: 13px;
  color: var(--muted);
}

.breadcrumb__item { display: inline-block; }
.breadcrumb__item + .breadcrumb__item::before { content: '/'; margin: 0 6px; color: #bbb; }
.breadcrumb__item a { color: #555; }
.breadcrumb__item.is-current { color: var(--muted); }

/* ------------------------------------------------------------------ 본문 */

.page-body { padding: 24px 0 40px; }

/* 공통 박스 */
.box {
  margin-bottom: 20px;
  background: #fff;
  border: 1px solid var(--line);
  border-radius: var(--radius);
}

.box__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 12px 16px;
  border-bottom: 1px solid var(--line);
}

.box__title {
  font-size: 17px;
  font-weight: 700;
  color: var(--ink);
  display: flex;
  align-items: center;
  gap: 8px;
}

.box__note { font-size: 13px; color: var(--body); font-weight: 400; }
.box__body { padding: 16px; }

/* ---------------------------------------------------- 요약 탭 + 우측 링크 */

.summary-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}

.summary-tabs { display: flex; gap: 0; }

.summary-tabs a {
  display: block;
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 700;
  color: #fff;
  background: #999;
}

.summary-tabs a:first-child { border-radius: var(--radius) 0 0 var(--radius); }
.summary-tabs a:last-child  { border-radius: 0 var(--radius) var(--radius) 0; }

.summary-tabs a.is-active               { background: var(--orange); }
.summary-tabs a.summary-tabs--teal      { background: var(--teal); }
.summary-tabs a.summary-tabs--green     { background: var(--green); }
.summary-tabs a.summary-tabs--blue      { background: var(--blue); }

/* 탭은 링크이므로 마우스를 올리면 살짝 어둡게 */
.summary-tabs a:hover { color: #fff; filter: brightness(.92); }

.summary-links {
  display: flex;
  gap: 18px;
  margin: 0;
  padding: 0;
  list-style: none;
  font-size: 13px;
  font-weight: 700;
}

.summary-links a { color: var(--ink); }
.summary-links a::before { content: '✓ '; color: var(--ink); font-weight: 400; }

/* ------------------------------------------------------- 현황판 (3열) */

.status-board { display: flex; gap: 0; }

.status-board__col { flex: 1 1 0; min-width: 0; }
.status-board__col + .status-board__col { border-left: 1px solid var(--line); }

.status-board__col--extra { background: var(--orange-bg); }

/* 열 제목 */
.status-group {
  margin: 0;
  padding: 8px 14px;
  font-size: 14px;
  font-weight: 700;
  color: var(--ink);
  background: #f2f2f2;
  border-bottom: 1px solid var(--line);
}

.status-board__col--extra .status-group {
  color: #fff;
  background: var(--orange);
}

/* 항목 줄 */
.status-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 10px 14px;
  font-size: 13px;
  border-bottom: 1px solid var(--line-soft);
}

.status-row:last-child { border-bottom: 0; }
.status-row__label { color: var(--body); }

.status-row__count {
  flex: 0 0 auto;
  font-size: 15px;
  font-weight: 700;
  color: var(--ink);
}

/* 0이 아닌 값만 주황색으로 강조 */
.status-row__count.is-active { color: var(--orange); }

/* 현황판 아래 액션 버튼 줄 */
.status-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding: 12px 16px;
  border-top: 1px solid var(--line);
}

.action-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  font-family: inherit;
  font-size: 13px;
  font-weight: 700;
  color: #fff;
  background: var(--orange);
  border: 0;
  border-radius: var(--radius);
  cursor: pointer;
}
.action-btn:hover { color: #fff; background: #d96f10; }
.action-btn__badge {
  display: inline-block;
  min-width: 18px;
  padding: 0 5px;
  font-size: 11px;
  line-height: 18px;
  text-align: center;
  color: var(--orange);
  background: #fff;
  border-radius: 9px;
}

/* ------------------------------------------------------ 현지 반품신청 팝업 */

.return-dialog {
  width: min(680px, 92vw);
  padding: 22px;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  box-shadow: 0 13px 42px 11px rgba(0, 0, 0, .12);
}
.return-dialog::backdrop { background: rgba(0, 0, 0, .4); }

.return-dialog__title { margin: 0 0 6px; font-size: 19px; font-weight: 700; color: var(--ink); }
.return-dialog__msg { margin: 0 0 12px; font-size: 13px; color: var(--muted); }

.return-list { max-height: 46vh; overflow-y: auto; margin: 0; padding: 0; list-style: none; border-top: 1px solid var(--line); }
.return-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 8px;
  font-size: 13px;
  color: var(--ink);
  border-bottom: 1px solid var(--line-soft);
  cursor: pointer;
}
.return-item:hover { background: var(--orange-bg); }
.return-item input { flex: 0 0 auto; }
.return-item__main { flex: 1 1 auto; min-width: 0; }
.return-item__no { display: block; font-weight: 700; }
.return-item__sub { display: block; margin-top: 2px; font-size: 12px; color: var(--muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.return-item__amount { flex: 0 0 auto; font-weight: 700; color: var(--orange); }

.return-note { margin: 12px 0 0; font-size: 12px; line-height: 1.7; color: var(--body); }

.return-dialog__foot { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }
.return-btn {
  padding: 10px 22px;
  font-family: inherit;
  font-size: 14px;
  font-weight: 700;
  color: #fff;
  background: #6f6f6f;
  border: 0;
  border-radius: var(--radius);
  cursor: pointer;
}
.return-btn:hover { background: #5c5c5c; }
.return-btn--danger { background: var(--red); }
.return-btn--danger:hover { background: #c23a2a; }
.return-btn:disabled { opacity: .5; cursor: not-allowed; }

/* ------------------------------------------------------------ 나의 정보 */

.info-table { width: 100%; border-collapse: collapse; }

.info-table th {
  padding: 12px 8px;
  font-size: 14px;
  font-weight: 700;
  color: #fff;
  text-align: center;
  background: var(--purple);
  border-right: 1px solid rgba(255, 255, 255, .25);
}
.info-table th:last-child { border-right: 0; }

.info-table td {
  padding: 18px 8px;
  font-size: 15px;
  font-weight: 700;
  color: var(--ink);
  text-align: center;
  background: var(--fill);
  border-right: 1px solid var(--line);
  border-top: 1px solid var(--line);
  vertical-align: middle;
}
.info-table td:last-child { border-right: 0; }

.info-table td .dim   { color: var(--muted); font-weight: 400; }
.info-table td .money { color: var(--orange); }
.info-table td .plain { font-weight: 400; font-size: 13px; line-height: 1.7; }

.info-link {
  display: inline-block;
  margin-top: 8px;
  padding: 4px 14px;
  font-size: 12px;
  font-weight: 400;
  color: var(--purple);
  border: 1px solid var(--purple);
  border-radius: 999px;
}

/* --------------------------------------------------- 하단 (공지 · 1:1 질문) */

.bottom-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0;
}

.bottom-col { padding: 0 16px; border-right: 1px solid var(--line); }
.bottom-col:last-child { border-right: 0; }
.bottom-col:first-child { padding-left: 0; }

.bottom-col__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--line);
}

.bottom-col__title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 15px;
  font-weight: 700;
  color: var(--ink);
}

.bottom-col__title::before {
  content: '';
  width: 3px;
  height: 15px;
  background: var(--orange);
}

.bottom-col__more { font-size: 12px; color: var(--muted); }

/* 공지 목록 */
.notice-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 7px 0;
  font-size: 13px;
  border-bottom: 1px dashed var(--line);
}
.notice-item:last-child { border-bottom: 0; }
.notice-item__text {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: var(--body);
}
.notice-item__text a { color: var(--body); }
.notice-item__text a:hover { color: var(--teal); }
.notice-item__date { flex: 0 0 auto; font-size: 12px; color: #aaa; }

.badge-new {
  flex: 0 0 auto;
  margin-right: 4px;
  padding: 1px 5px;
  font-size: 10px;
  font-weight: 700;
  color: #fff;
  background: var(--orange);
  border-radius: 2px;
}

/* 1:1 질문 */
.q-item {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 8px;
  padding: 7px 0;
  font-size: 13px;
  border-bottom: 1px dashed var(--line);
}
.q-item:last-child { border-bottom: 0; }
.q-item__text { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: var(--body); }
.q-item__text a { color: var(--body); }
.q-item__text a:hover { color: var(--teal); }

.q-state {
  flex: 0 0 auto;
  padding: 1px 8px;
  font-size: 11px;
  color: var(--orange);
  border: 1px solid var(--orange);
  border-radius: 999px;
}
.q-state--wait { color: var(--muted); border-color: #cfcfcf; }

.empty-msg { margin: 0; padding: 18px 0; font-size: 13px; text-align: center; color: var(--muted); }

/* --------------------------------------------------------------- FAQ (DB) */

.faq-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 0;
}

.faq-col { padding: 0; border-right: 1px solid var(--line); }
.faq-col:last-child { border-right: 0; }

.faq-col__head {
  margin: 0;
  padding: 10px 12px;
  font-size: 13px;
  font-weight: 700;
  color: var(--ink);
  background: #f2f2f2;
  border-bottom: 1px solid var(--line);
}

.faq-col ul { margin: 0; padding: 8px 12px 12px; list-style: none; }
.faq-col li { padding: 5px 0; font-size: 13px; color: var(--body); }
.faq-col summary { cursor: pointer; list-style: none; color: var(--body); }
.faq-col summary::-webkit-details-marker { display: none; }
.faq-col summary::before { content: '› '; color: var(--orange); }
.faq-col summary:hover { color: var(--teal); }
.faq-a {
  margin: 8px 0 4px 12px;
  padding: 12px 14px;
  font-size: 13px;
  line-height: 1.8;
  color: var(--ink);
  white-space: pre-line;
  background: var(--fill);
  border-radius: var(--radius);
}

/* --------------------------------------------------------------- 푸터 */

.site-footer { margin-top: 10px; background: #333; color: #ccc; }
.site-footer__inner { padding-top: 50px; padding-bottom: 50px; }
.site-footer__logo { width: 120px; }

.footer-links { padding-top: 20px; margin-bottom: 20px; }

.footer-links a {
  display: inline-block;
  margin: 0 20px 0 0;
  font-size: 14px;
  color: #fff;
  border-bottom: 1px dotted rgba(255, 255, 255, .25);
}
.footer-links a:hover { color: #fff; border-bottom-style: solid; }

.site-footer__text {
  margin: 0;
  font-size: 13px;
  font-weight: 300;
  line-height: 28px;
  color: #ccc;
}

.copyright {
  margin: 0;
  padding: 20px 0;
  font-size: 13px;
  text-align: center;
  color: rgba(255, 255, 255, .5);
  background: rgba(0, 0, 0, .2);
}
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<!-- ===================== 페이지 제목 ===================== -->
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">종합현황</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item is-current">종합현황</li>
    </ol>
  </div>
</section>

<main class="page-body">
  <div class="container">

    <!-- ============ 1. 요약 탭 ============ -->
    <div class="summary-bar">
      <div class="summary-tabs">
        <a class="is-active" href="<%= ctx %>/shiporder/list">배송대행 조회</a>
        <a class="summary-tabs--teal" href="<%= ctx %>/buyorder/list">구매대행 조회</a>
        <a class="summary-tabs--blue" href="<%= ctx %>/mypage/payment">입고내역조회</a>
      </div>
      <ul class="summary-links">
        <li><a href="<%= ctx %>/mypage/address">나의 주소록</a></li>
        <li><a href="<%= ctx %>/mypage">나의 정보</a></li>
      </ul>
    </div>

    <!-- ============ 2. 현황판 ============ -->
    <div class="box">
      <div class="status-board">

        <!-- 1열: 주문 및 입고 / 배송비 결제 -->
        <div class="status-board__col">
          <p class="status-group">주문 및 입고</p>
          <div class="status-row"><span class="status-row__label">구매대행주문 완료</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">배송대행신청 (트래킹번호 미입력)</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">배송대행신청 완료</span><span class="status-row__count is-active">1</span></div>
          <div class="status-row"><span class="status-row__label">입고 대기 / 부분 도착</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">입고 완료</span><span class="status-row__count">0</span></div>

          <p class="status-group">배송비 결제</p>
          <div class="status-row"><span class="status-row__label">무게측정 대기  수동결제건</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">배송비 결제 대기 - 수동결제건</span><span class="status-row__count">0</span></div>
        </div>

        <!-- 2열: 출고 / 통관 및 현지 배송 -->
        <div class="status-board__col">
          <p class="status-group">출고</p>
          <div class="status-row"><span class="status-row__label">출고 대기 / 발송 준비</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">운송장 출력 / 항공사(선사) 인계예정</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">항공사(선사) 인계 / 항공사(선사) 배송 중</span><span class="status-row__count">0</span></div>

          <p class="status-group">통관 및 현지 배송</p>
          <div class="status-row"><span class="status-row__label">국내도착 (통관중)</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">통관 완료</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">현지 배송중</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">현지 배송 완료</span><span class="status-row__count is-active">24</span></div>
        </div>

        <!-- 3열: 추가 확인 (강조) -->
        <div class="status-board__col status-board__col--extra">
          <p class="status-group">추가 확인</p>
          <div class="status-row"><span class="status-row__label">배송대행신청 미작성 입고</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">사고주문 (특수포장)</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">관부가세 결제 대기</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">관부가세 결제 완료</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">추가 결제 대기</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">반품 현황</span><span class="status-row__count is-active">5</span></div>
          <div class="status-row"><span class="status-row__label">검수 사진</span><span class="status-row__count">0</span></div>
          <div class="status-row"><span class="status-row__label">보관료 발생 (예정)</span><span class="status-row__count">0</span></div>
        </div>

      </div>

      
    </div>

    <!-- ============ 3. 공지 / 1:1 (커뮤니티 DB) ============ -->
    <div class="box">
      <div class="box__body">
        <div class="bottom-grid">

          <!-- 공지사항 -->
          <div class="bottom-col">
            <div class="bottom-col__head">
              <p class="bottom-col__title">공지사항</p>
              <a class="bottom-col__more" href="<%= ctx %>/community/notice">더보기</a>
            </div>
<%  for (NoticeRow n : notices) { %>
            <div class="notice-item">
              <span class="notice-item__text"><% if (n.fresh()) { %><span class="badge-new">N</span><% } %><a href="<%= ctx %>/community/notice/view?id=<%= n.postId() %>"><%= Html.esc(n.title()) %></a></span>
              <span class="notice-item__date"><%= Html.esc(n.date()) %></span>
            </div>
<%  } %>
<%  if (notices.isEmpty()) { %>
            <p class="empty-msg">등록된 공지사항이 없습니다.</p>
<%  } %>
          </div>

          <!-- 나의 1:1 질문 -->
          <div class="bottom-col">
            <div class="bottom-col__head">
              <p class="bottom-col__title">나의 1:1 질문</p>
              <a class="bottom-col__more" href="<%= ctx %>/community/qna/write">1:1 문의하기 ›</a>
            </div>
<%  for (QnaRow qa : myQuestions) { %>
            <div class="q-item">
              <span class="q-item__text">· <a href="<%= ctx %>/community/qna/view?id=<%= qa.postId() %>"><%= Html.esc(qa.title()) %></a></span>
<%      if (qa.answered()) { %>
              <span class="q-state">답변완료</span>
<%      } else { %>
              <span class="q-state q-state--wait">답변대기</span>
<%      } %>
            </div>
<%  } %>
<%  if (memberId == null) { %>
            <p class="empty-msg">로그인 후 확인할 수 있습니다.</p>
<%  } else if (myQuestions.isEmpty()) { %>
            <p class="empty-msg">등록하신 1:1 문의가 없습니다.</p>
<%  } %>
          </div>

        </div>
      </div>
    </div>

    <!-- ============ 4. 자주하는 질문 (커뮤니티 DB) ============ -->
    <div class="box">
      <div class="box__head">
        <p class="box__title">자주하는 질문</p>
        <p class="box__note">★ 질문을 클릭하시면 아래에 답변이 펼쳐집니다. &nbsp;<a href="<%= ctx %>/community/faq">전체보기 ›</a></p>
      </div>
      <div class="box__body" style="padding:0">
<%  if (faqGroups.isEmpty()) { %>
        <p class="empty-msg">등록된 질문이 없습니다.</p>
<%  } else { %>
        <div class="faq-grid">
<%      for (FaqGroup g : faqGroups) { %>
          <div class="faq-col">
            <p class="faq-col__head"><%= Html.esc(g.category()) %></p>
            <ul>
<%          for (FaqRow f : g.items()) { %>
              <li>
                <details>
                  <summary><%= Html.esc(f.question()) %></summary>
                  <div class="faq-a"><%= Html.esc(f.answer()) %></div>
                </details>
              </li>
<%          } %>
            </ul>
          </div>
<%      } %>
        </div>
<%  } %>
      </div>
    </div>

  </div>
</main>

<!-- ============ 현지 반품신청 팝업 : 배송 중인 물품을 골라 취소하면 예치금으로 환불 ============ -->
<dialog class="return-dialog" id="returnDialog">
  <h2 class="return-dialog__title">현지 반품신청 (배송 취소 · 환불)</h2>
  <p class="return-dialog__msg" id="returnMsg"></p>
  <ul class="return-list" id="returnList"></ul>
  <p class="return-note">※ 취소하면 결제하신 금액이 예치금으로 환불됩니다. 취소한 주문은 되돌릴 수 없습니다.</p>
  <div class="return-dialog__foot">
    <button class="return-btn" type="button" id="returnClose">닫기</button>
    <button class="return-btn return-btn--danger" type="button" id="returnCancel" disabled>취소하기</button>
  </div>
</dialog>

<script>
/* 현지 반품신청 : 배송 중인 물품 목록을 받아 팝업에 보여 주고, 고른 물품을 취소 · 환불한다. */
(function () {
  var CTX = '<%= ctx %>';
  var CSRF = '<%= Html.esc(Session.csrfToken(request)) %>';

  var dlg = document.getElementById('returnDialog');
  var list = document.getElementById('returnList');
  var msg = document.getElementById('returnMsg');
  var btnCancel = document.getElementById('returnCancel');
  if (!dlg || typeof dlg.showModal !== 'function') return;

  function won(n) { return '₩' + Number(n).toLocaleString('ko-KR'); }

  function checkedIds() {
    var ids = [];
    var boxes = list.querySelectorAll('input[type="checkbox"]:checked');
    for (var i = 0; i < boxes.length; i++) ids.push(boxes[i].value);
    return ids;
  }

  function refreshButton() { btnCancel.disabled = checkedIds().length === 0; }

  function line(cls, text) {
    var s = document.createElement('span');
    s.className = cls;
    s.textContent = text;
    return s;
  }

  // 팝업 열기 : 배송 중인 물품 목록 불러오기
  document.getElementById('btnReturn').addEventListener('click', function () {
    list.innerHTML = '';
    msg.textContent = '불러오는 중...';
    btnCancel.disabled = true;
    dlg.showModal();

    fetch(CTX + '/status/return', { credentials: 'same-origin' })
      .then(function (r) { return r.json(); })
      .then(function (j) {
        if (!j.ok) { msg.textContent = j.message; return; }
        if (!j.items.length) { msg.textContent = '출고 이후에는 환불(취소)할 수 없습니다.'; return; }
        msg.textContent = '취소할 물품을 선택해 주세요. (보유 예치금 ' + won(j.deposit) + ')';
        j.items.forEach(function (it) {
          var li = document.createElement('li');
          var label = document.createElement('label');
          label.className = 'return-item';

          var cb = document.createElement('input');
          cb.type = 'checkbox';
          cb.value = it.id;
          cb.addEventListener('change', refreshButton);

          var main = document.createElement('span');
          main.className = 'return-item__main';
          main.appendChild(line('return-item__no', it.orderNo + ' · ' + it.service));
          main.appendChild(line('return-item__sub', it.summary + ' · ' + it.status));

          label.appendChild(cb);
          label.appendChild(main);
          label.appendChild(line('return-item__amount', '환불 ' + won(it.amount)));
          li.appendChild(label);
          list.appendChild(li);
        });
      })
      .catch(function () {
        msg.textContent = '불러오지 못했습니다. 로그인 상태를 확인해 주세요.';
      });
  });

  document.getElementById('returnClose').addEventListener('click', function () { dlg.close(); });

  // 취소하기 : 고른 물품의 배송을 취소하고 예치금으로 환불
  btnCancel.addEventListener('click', function () {
    var ids = checkedIds();
    if (!ids.length) return;
    if (!confirm(ids.length + '건의 배송을 취소하고 결제 금액을 예치금으로 환불받으시겠습니까?')) return;

    btnCancel.disabled = true;
    var body = '_csrf=' + encodeURIComponent(CSRF);
    for (var i = 0; i < ids.length; i++) body += '&id=' + encodeURIComponent(ids[i]);

    fetch(CTX + '/status/return/cancel', {
      method: 'POST',
      credentials: 'same-origin',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body
    })
      .then(function (r) { return r.json(); })
      .then(function (j) {
        alert(j.message);
        if (j.ok) location.reload();   // 목록 · 숫자를 새로 불러온다
        else refreshButton();
      })
      .catch(function () {
        alert('취소하지 못했습니다. 잠시 후 다시 시도해 주세요.');
        refreshButton();
      });
  });
})();
</script>

<!-- ===================== 푸터 (+ </body></html>) ===================== -->
<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
