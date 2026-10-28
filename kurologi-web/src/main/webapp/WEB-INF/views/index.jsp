<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jp.kurologi.model.Member" %>
<%@ page import="jp.kurologi.web.Html" %>
<%@ page import="jp.kurologi.web.Session" %>
<%
    String ctx = request.getContextPath();

    // 홈은 자기만의 헤더 · 푸터를 가진 독립 페이지입니다 (layout.jsp 를 쓰지 않음).
    // PageServlet 이 로그인한 회원이면 member 를, 아이디저장 쿠키가 있으면 savedId 를 넣어 줍니다.
    Member member = (Member) request.getAttribute("member");
    String savedId = (String) request.getAttribute("savedId");
    String mailboxNo = member == null ? "로그인후 확인 가능합니다." : member.getMailboxNo();

    // 로그인 상자 위에 보일 안내 (LoginServlet · AuthFilter · 탈퇴 후 돌아올 때)
    String loginMessage = null;
    if (request.getParameter("loginError") != null) loginMessage = "아이디 또는 비밀번호가 올바르지 않습니다.";
    else if (request.getParameter("login") != null) loginMessage = "로그인이 필요한 화면입니다. 로그인해 주세요.";
    else if (request.getParameter("withdrawn") != null) loginMessage = "탈퇴가 완료되었습니다. 이용해 주셔서 감사합니다.";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>일본 배대지 쿠로로지 (KURO Logi)</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from index.css */
/* ==========================================================================
   KURO Logi — 홈페이지 스타일 (순수 CSS)

   구조:  reset → 공통 요소 → 레이아웃 → 헤더 → 본문 섹션 → 푸터 → 팝업
   레이아웃: 데스크톱 전용 고정폭 (미디어쿼리 없음)   단위:  rem (1rem = 16px). 14px = 0.875rem, 14.4px = 0.9rem
   값 출처: 원본 사이트에서 계산된 스타일을 측정해 그대로 옮겼습니다.
   ========================================================================== */

/* ==========================================================================
   1. 색상 · 폭 (여기만 바꾸면 전체 톤이 바뀝니다)
   ========================================================================== */

:root {
  --teal:        #159692;   /* 헤더, 기본 버튼 */
  --teal-dark:   #107a77;   /* 호버 */
  --teal-tab:    #129692;   /* 선택된 탭 */
  --blue:        #107abd;   /* 링크, 포인트 */
  --kakao:       #fae100;   /* 카카오 버튼 */
  --red:         #dd4b39;   /* 경고, 강조 */
  --ink:         #333333;   /* 제목, 기본 링크 */
  --body:        #555555;   /* 본문 */
  --muted:       #666666;   /* 보조 텍스트 */
  --footer-text: #cccccc;   /* 푸터 본문 */

  --line:        #e5e5e5;
  --line-soft:   #eeeeee;
  --line-input:  #ced4da;
  --fill:        #f2f2f2;   /* 탭 기본 배경 */
  --fill-soft:   #f9f9f9;
  --fill-stripe: rgba(0, 0, 0, .05);

  --container:   1360px;    /* 원본 .container 폭 */
  --gutter:      15px;      /* 좌우 여백 */

  --radius:      4px;
  --shadow-menu: 0 13px 42px 11px rgba(0, 0, 0, .05);
}

/* ==========================================================================
   2. 기본 리셋
   ========================================================================== */

*,
*::before,
*::after { box-sizing: border-box; }

html { font-size: 16px; }

body {
  margin: 0;
  font-family: 'Noto Sans KR', serif;
  font-size: 0.875rem;          /* 14px */
  line-height: 1.5;
  color: var(--body);
  background: #fff;
}

h1, h2, h3, h4, h5, h6 {
  margin: 0;
  color: #444;
  font-weight: 400;
  line-height: 1.5;
}

h4 { font-size: 18px; }

img { max-width: 100%; height: auto; border: 0; }

a { color: var(--ink); text-decoration: none; }
a:hover { color: var(--teal); }

button { font: inherit; cursor: pointer; }

/* ==========================================================================
   3. 공통 요소
   ========================================================================== */

/* --- 텍스트 도우미 --- */
.text-center     { text-align: center; }
.text-red        { color: var(--red); }
.text-blue       { color: var(--blue); }
.text-bold       { font-weight: 700; }
.text-semibold   { font-weight: 600; }

.text-15 { font-size: 15px; }
.text-16 { font-size: 16px; }
.text-18 { font-size: 18px; }
.text-20 { font-size: 20px; }

/* --- 버튼 ---
   원본: padding .4rem .75rem, font-size .9rem, letter-spacing -.5px, border 없음 */

.btn {
  display: inline-block;
  padding: 0.4rem 0.75rem;
  border: 0;
  border-radius: var(--radius);
  font-size: 0.9rem;          /* 14.4px */
  font-weight: 400;
  letter-spacing: -0.5px;
  line-height: 1.5;
  text-align: center;
  white-space: nowrap;
  vertical-align: middle;
}

.btn--dark    { color: #fff; background: #343a40; }
.btn--dark:hover { color: #fff; background: #23272b; }

.btn--primary { color: #fff; background: var(--teal); }
.btn--primary:hover { color: #fff; background: var(--teal-dark); }

.btn--block { display: block; width: 100%; }

/* 큰 버튼 (운송장 조회) */
.btn--lg {
  padding: 0.5rem 1rem;
  font-size: 1.25rem;
  border-radius: 0.3rem;
}

/* 버튼 묶음 */
.btn-row { display: flex; }
.btn-row--split > .btn { flex: 1 1 0; border-radius: 0; }
.btn-row--split > .btn:first-child { border-radius: var(--radius) 0 0 var(--radius); }
.btn-row--split > .btn:last-child  { border-radius: 0 var(--radius) var(--radius) 0; }
.btn-row--spaced { margin-top: 20px; gap: 4px; }
.btn-row--spaced > .btn { border-radius: var(--radius); }

/* --- 입력 필드 ---
   원본: padding .375rem .75rem, font-size .9rem, border-radius 0 */

.field {
  width: 100%;
  padding: 0.375rem 0.75rem;
  font-family: inherit;
  font-size: 0.9rem;          /* 14.4px */
  line-height: 1.5;
  color: #495057;
  background: #fff;
  border: 1px solid var(--line-input);
  border-radius: 0;           /* 원본은 모서리를 둥글리지 않습니다 */
}

.field:focus { outline: none; border-color: var(--teal); }

.field--block { display: block; margin-bottom: 5px; }
.field--sm    { padding: 0.25rem 0.5rem; font-size: 12px; height: 30px; }
.field--lg {
  height: calc(1.5em + 1rem + 2px);
  padding: 0.5rem 1rem;
  font-size: 1.25rem;
  border-radius: 0.3rem;
}

.checkbox {
  display: block;
  margin: 6px 0;
  font-size: 13px;
  color: var(--muted);
  cursor: pointer;
}
.checkbox input { margin-right: 4px; vertical-align: middle; }

/* --- 표 ---
   원본: padding 8px, font-size 14px, color #212529, vertical-align middle */

.table {
  width: 100%;
  border-collapse: collapse;
}

.table th,
.table td {
  padding: 0.5rem;
  font-size: 14px;
  color: #212529;
  text-align: left;
  vertical-align: middle;
  border-top: 1px solid #dee2e6;
}

.table th { font-weight: 700; white-space: nowrap; width: 90px; }
.table--striped tbody tr:nth-child(odd) { background: var(--fill-stripe); }

/* --- 카드 ---
   원본은 border-radius 0 이고, 안쪽 .card__body 가 10px 패딩을 가집니다 */

.card {
  background: #fff;
  border: 1px solid rgba(0, 0, 0, .125);
  border-radius: 0;
}

.card__body { padding: 10px; }

/* 테두리 안쪽에 20px 여백을 한 번 더 주는 카드 (원본 .card.padding20) */
.card--pad { padding: 20px; }

.card--blue   { background: #e7f2f7; }
.card--yellow { background: #f3f0e4; }

/* 이미지가 카드 전체를 채우는 형태 (신청서 자동편집기) */
.card__image-link { display: block; }
.card__image { display: block; width: 100%; }

/* --- 작은 라벨 (공지 날짜 / 새글) --- */

.badge {
  display: inline-block;
  padding: 0.25em 0.4em;
  border-radius: var(--radius);
  font-size: 75%;
  font-weight: 700;
  line-height: 1;
  white-space: nowrap;
  vertical-align: baseline;
}

.badge--info { color: #fff; background: #17a2b8; }

/* 날짜: 알약 모양, 원본 computed padding 6.3px / 2.6px */
.badge--date {
  padding: 0.25em 0.6em;
  border-radius: 10rem;
  color: #212529;
  background: #f8f9fa;
}

/* --- 카카오 상담 버튼 (이미지) --- */

.kakao-btn img {
  height: 35px;
  width: auto;
  padding-top: 5px;
  vertical-align: middle;
}

/* --- 세로로 쌓이는 버튼 줄 --- */

.stack { margin-top: 20px; }
.stack--tight > * { margin-right: 2px; }
.stack--tight { margin-top: 12px; }

/* --- 경고 박스 (나의 일본주소) --- */

.alert {
  margin: 0;
  padding: 0.75rem 1.25rem;
  font-size: 14px;
  line-height: 24px;
  color: #721c24;
  background: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: var(--radius);
}

.caret { font-style: normal; font-size: 10px; margin-left: 4px; }

/* --- 섹션 제목 ---
   원본 .fancy-title.title-border: 제목 뒤로 1px 선이 지나갑니다 */

.panel-title {
  position: relative;
  margin-bottom: 20px;
  font-size: 18px;
  font-weight: 500;
  color: #444;
  display: inline-block;
  background: #fff;
  padding-right: 10px;
}

/* 제목 뒤 가로선 */
.panel-title--line::before {
  content: '';
  position: absolute;
  top: 49%;
  right: -10px;
  width: 100vw;
  border-top: 1px solid var(--line-soft);
  z-index: -1;
}

/* 제목 줄 안의 "더보기" */
.panel-title__more {
  position: absolute;
  right: 0;
  top: 3px;
  font-size: 13px;
  font-weight: 400;
  background: #fff;
  padding-left: 10px;
}

/* --- 탭 (배송센터 안내) ---
   원본 ul.tab-nav: 선택된 탭은 청록 배경에 흰 글자입니다 */

.tabs { position: relative; margin: 20px 0 30px; }

.tabs__nav {
  display: flex;
  flex-wrap: wrap;
  margin: 0;
  padding: 0;
  list-style: none;
  border-bottom: 1px solid #ddd;
}

.tabs__item {
  height: 41px;
  text-align: center;
  border: 1px solid #ddd;
  border-bottom: 0;
  border-left: 0;
}

.tabs__item:first-child { margin-left: 15px; border-left: 1px solid #ddd; }

.tabs__item a {
  display: block;
  height: 40px;
  padding: 0 7px;
  font-size: 13px;
  font-weight: 700;
  line-height: 40px;
  text-align: center;
  color: #444;
  background: var(--fill);
}

.tabs__item.is-active a { color: #fff; background: var(--teal-tab); }

/* 탭 내용 */
.tabs__pane { display: none; }
.tabs__pane.is-active { display: block; }

/* ==========================================================================
   4. 레이아웃
   ========================================================================== */

.container {
  width: 100%;
  max-width: var(--container);
  margin: 0 auto;
  padding: 0 10px;
}

.row {
  display: flex;
  flex-wrap: wrap;
  margin: 0 calc(var(--gutter) * -1);
}

.col {
  position: relative;
  width: 100%;
  padding: 0 var(--gutter);
  margin-bottom: 30px;
}

/* 열 폭 (데스크톱 고정 레이아웃) */
.col--two-thirds   { width: 66.6667%; }
.col--half         { width: 50%; }
.col--one-third    { width: 33.3333%; }
.col--footer-logo  { width: 16.6667%; }
.col--footer-info  { width: 83.3333%; }

.section { padding-top: 30px; }

/* ==========================================================================
   5. 상단 바
   ========================================================================== */

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
  color: var(--muted);
}

.topbar__links a.kakao-btn { height: 44px; line-height: 44px; padding: 0 6px; }

/* "나의 일본주소" 드롭다운 */
.topbar__links--left .has-menu { position: relative; }

.address-menu {
  display: none;
  position: absolute;
  top: 44px;
  left: 0;
  z-index: 100;
  width: 400px;
  padding: 10px;
  background: #fff;
  border: 1px solid rgba(0, 0, 0, .15);
  border-radius: var(--radius);
  box-shadow: 0 0 5px -1px rgba(0, 0, 0, .2);
}

.topbar__links--left .has-menu:hover .address-menu { display: block; }

.address-menu__title { margin: 10px; font-size: 14px; color: var(--body); }

/* ==========================================================================
   6. 헤더 + 주 메뉴
   ========================================================================== */

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

/* --- 주 메뉴 --- */

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
  padding: 39px 10px;         /* 헤더 높이를 만드는 값 */
  font-size: 16px;
  font-weight: 400;
  letter-spacing: -1px;
  color: #fff;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.main-nav__item:hover { background: var(--teal-dark); }

/* 하위 메뉴 */
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
  box-shadow: var(--shadow-menu);
}

.main-nav__item:hover .main-nav__submenu { display: block; }

.main-nav__submenu a {
  display: block;
  padding: 10px;
  font-size: 14px;
  font-family: 'Lato', sans-serif;
  color: var(--muted);
  white-space: normal;
}

.main-nav__submenu a:hover { padding-left: 18px; color: var(--teal); }

/* 오른쪽 끝 메뉴는 화면 밖으로 나가지 않게 오른쪽 정렬 */
.main-nav__item:nth-last-child(-n+2) .main-nav__submenu { left: auto; right: 0; }

/* ==========================================================================
   8. 배너 슬라이더
   ========================================================================== */

.hero {
  position: relative;
  height: 540px;
  overflow: hidden;
  background: url('<%= ctx %>/images/banner1.png') center / 100% 100% no-repeat;
}

.hero__link { position: absolute; inset: 0; z-index: 1; }

.hero__arrow {
  position: absolute;
  top: 50%;
  z-index: 2;
  width: 40px;
  height: 40px;
  margin-top: -20px;
  font-size: 26px;
  color: #fff;
  background: transparent;
  border: 0;
  opacity: .6;
}
.hero__arrow:hover { opacity: 1; }
.hero__arrow--prev { left: 12px; }
.hero__arrow--next { right: 12px; }

.hero__dots {
  position: absolute;
  bottom: 20px;
  z-index: 2;
  width: 100%;
  text-align: center;
}
.hero__dots span {
  display: inline-block;
  width: 10px;
  height: 10px;
  margin: 0 4px;
  border: 1px solid #fff;
  border-radius: 50%;
}
.hero__dots span.is-active { background: #fff; }

/* ==========================================================================
   9. 운송장 조회
   ========================================================================== */

.search-bar { display: flex; flex-wrap: wrap; }

/* 이어 붙는 컨트롤은 모서리를 없애고 양 끝만 둥글게 */
.search-bar > * { border-radius: 0; }
.search-bar > *:first-child { border-radius: 0.3rem 0 0 0.3rem; }
.search-bar > *:last-child  { border-radius: 0 0.3rem 0.3rem 0; }
.search-bar .field { flex: 1 1 120px; min-width: 0; }

/* ==========================================================================
   10. 공지사항
   ========================================================================== */

.notice-list { margin: 0; padding: 0; list-style: none; }

.notice-list__item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 12px 0;
}

.notice-list__title {
  width: 80%;
  margin: 0;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}

.notice-list__title a { color: var(--body); }

/* ==========================================================================
   11. 센터 출고 현황
   ========================================================================== */

.center-status { width: 100%; border-collapse: collapse; }

.center-status__cell {
  padding: 6px 4px;
  font-size: 14px;
  text-align: center;
  vertical-align: middle;
  border-right: 1px dotted #ccc;   /* 세 칸을 나누는 점선 */
}

.center-status__cell--last { border-right: 0; }
.center-status__cell img { display: block; width: 60px; margin: 0 auto; }
.center-status__status { margin-top: 4px; }
.center-status__name { word-break: auto-phrase; }

/* ==========================================================================
   12. 환율 · 계좌
   ========================================================================== */

.exchange { margin: 0; }

.exchange--main {
  margin: 20px 0 25px;
  font-size: 24px;
}

.exchange__flag { width: 16px; margin-top: -7px; margin-right: 4px; vertical-align: middle; }
.exchange__value { padding-left: 20px; }

.bank-logo { margin-bottom: 20px; }

/* ==========================================================================
   13. 푸터
   ========================================================================== */

.site-footer {
  margin-top: 10px;
  background: #333;
  color: var(--footer-text);
}

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
  color: var(--footer-text);
}

.copyright {
  margin: 0;
  padding: 20px 0;
  font-size: 13px;
  text-align: center;
  color: rgba(255, 255, 255, .5);
  background: rgba(0, 0, 0, .2);
}

/* ==========================================================================
   14. 긴급 안내 팝업
   ========================================================================== */

.popup {
  position: fixed;
  inset: 0;
  z-index: 300;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
}
.popup.is-hidden { display: none; }

.popup__backdrop { position: absolute; inset: 0; background: rgba(0, 0, 0, .5); }

.popup__panel {
  position: relative;
  display: flex;
  flex-direction: column;
  width: 100%;
  max-width: 560px;
  max-height: 90vh;
  background: #fff;
  border: 1px solid rgba(0, 0, 0, .2);
  border-radius: 0.3rem;
  box-shadow: 0 10px 40px rgba(0, 0, 0, .3);
  overflow: auto;
}

.popup__body { padding: 20px 24px 10px; text-align: center; }

.popup__label {
  display: inline-block;
  margin: 0 0 8px;
  padding: 4px 14px;
  border-radius: 10rem;
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 1px;
  color: #fff;
  background: var(--red);
}

.popup__title {
  margin: 10px 0 12px;
  font-size: 26px;
  font-weight: 700;
  line-height: 1.25;
  color: #222;
}

.popup__lead { margin: 0 0 16px; font-size: 14px; }

.popup__note {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 0 0 16px;
  padding: 12px;
  font-size: 12px;
  text-align: left;
  background: #fdf3e7;
  border-radius: var(--radius);
}

.popup__note-mark {
  flex: 0 0 26px;
  width: 26px;
  height: 26px;
  display: grid;
  place-items: center;
  border-radius: 50%;
  font-weight: 700;
  color: #fff;
  background: var(--red);
}

.popup__foot {
  padding: 8px;
  font-size: 12px;
  text-align: right;
  color: #fff;
  background: #a3a3a3;
}

.popup__mute { cursor: pointer; }
.popup__mute input { margin-right: 4px; vertical-align: middle; }

/* --- 변경 전 / 변경 후 비교 박스 --- */

.compare {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin-bottom: 14px;
}

.compare__item {
  flex: 1;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  overflow: hidden;
}

.compare__head {
  display: block;
  padding: 6px;
  font-size: 12px;
  font-weight: 700;
  color: #fff;
}

.compare__name { display: block; padding: 12px 6px; font-size: 17px; font-weight: 700; }

.compare__item--before .compare__head { background: #999; }
.compare__item--before .compare__name { color: #444; }

.compare__item--after { border-color: var(--red); }
.compare__item--after .compare__head { background: var(--red); }
.compare__item--after .compare__name { color: var(--red); }

.compare__arrow { font-size: 20px; color: #444; }

/* JSP — 로그인 상자 안내 */
.login-message { margin: 0 0 10px; padding: 8px 10px; font-size: 13px; color: #8a1f11; background: #fdecea; border-radius: 4px; }
.login-welcome { margin: 0 0 14px; font-size: 14px; line-height: 1.8; color: #333; }
.topbar__welcome { display: block; padding: 0 12px 0 20px; height: 44px; line-height: 44px; font-size: 13px; color: #444; white-space: nowrap; }
.topbar__welcome strong { color: #159692; font-weight: 700; }
</style>
</head>
<body>

<!-- ==================================================================
     긴급 안내 팝업
     ================================================================== -->
<div class="popup" id="emergencyPopup">
  <div class="popup__backdrop" data-close-popup></div>
  <div class="popup__panel" role="dialog" aria-label="긴급 안내">
    <div class="popup__body">
      <p class="popup__label">! 긴급 ㅅㅅ</p>
      <h2 class="popup__title">-
        스마트스토어<br><span class="text-red">택배사 설정 변경</span> 부탁드립니다!
      </h2>
      <p class="popup__lead">
        최근 통관사 변경후, <strong>스마트스토어의 트래킹이 되지 않은</strong><br>문제가 발생하고 있습니다.
      </p>

      <div class="compare">
        <div class="compare__item compare__item--before">
          <span class="compare__head">변경 전 (현재 설정)</span>
          <span class="compare__name">롯데글로벌로지스</span>
        </div>
        <span class="compare__arrow" aria-hidden="true">➜</span>
        <div class="compare__item compare__item--after">
          <span class="compare__head">변경 후 (설정 부탁)</span>
          <span class="compare__name">CJ대한통운</span>
        </div>
      </div>

      <p class="popup__note">
        <span class="popup__note-mark">!</span>
        금일부터 연휴로 스마트스토어 측에서 대응이 안되고 있는 상황입니다.<br>
        <strong class="text-red">연휴 끝나는 대로 빠르게 개선하겠습니다.</strong>
      </p>

      <a class="btn btn--primary" href="#">자세히 보기 ›</a>
    </div>
    <div class="popup__foot">
      <label class="popup__mute"><input type="checkbox"> 일주일동안 보이지 않음</label>
    </div>
  </div>
</div>

<!-- ==================================================================
     상단 바
     ================================================================== -->
<div class="topbar">
  <div class="container topbar__inner">

    <ul class="topbar__links topbar__links--left">
      <li><a href="#">즐겨찾기추가</a></li>
      <li><a href="<%= ctx %>/community/qna">1:1게시판</a></li>
      <li class="has-menu">
        <a href="#">나의 일본주소 <i class="caret">▾</i></a>
        <div class="address-menu">
          <p class="address-menu__title">배송센터 안내</p>
          <table class="table table--striped">
            <colgroup><col style="width:130px"><col></colgroup>
            <tbody>
              <tr>
                <th>배송센터</th>
                <td>
                  <select class="field field--sm" aria-label="배송센터">
                    <option>항공-도쿄(JP)</option>
                    <option>해상-후쿠오카 제1센터(JP)</option>
                    <option>해상-후쿠오카 제2센터(JP)</option>
                  </select>
                </td>
              </tr>
              <tr><th>우편번호</th><td>187-0011</td></tr>
              <tr><th>주소</th><td>東京都小平市鈴木町1-466-19-3F</td></tr>
              <tr><th>나의 사서함번호</th><td class="text-blue text-bold"><%= Html.esc(mailboxNo) %></td></tr>
              <tr><th>Telephone</th><td>042-401-0754</td></tr>
              <tr><th>수취인</th><td>회원님 영문 성함(또는 회원사명)</td></tr>
            </tbody>
          </table>
          <p class="alert">
            주의사항<br>
            - 원활한 배송을 위해서 위의 모든 정보를 정확히 기입바랍니다.<br>
            - 주소 기입시 [주소+나의사서함번호]를 반드시 기입해주세요. 입고시 「나의사서함 번호」로 회원님의 화물을 식별합니다.<br>
            - 수취인은 한글 사용 불가 (영문, 한자 사용 바랍니다)
          </p>
        </div>
      </li>
    </ul>

    <ul class="topbar__links topbar__links--right">
      <li><a href="#">언어 선택 <i class="caret">▾</i></a></li>
<%  boolean topIn = member != null || Session.memberId(request) != null;
    String topName = member != null ? member.getName() : (String) session.getAttribute("loginMemberName");
    if (topName == null || topName.trim().isEmpty()) topName = "회원";
    if (topIn) { %>
      <li><span class="topbar__welcome"><strong><%= Html.esc(topName) %></strong>님 환영합니다.</span></li>
      <li><a href="<%= ctx %>/logout">로그아웃</a></li>
      <li><a href="<%= ctx %>/mypage">마이페이지</a></li>
<%  } else { %>
      <li><a href="<%= ctx %>/member/login">로그인</a></li>
      <li><a href="<%= ctx %>/member/join">회원가입</a></li>
<%  } %>
    </ul>

  </div>
</div>

<!-- ==================================================================
     헤더 + 주 메뉴
     ================================================================== -->
<header class="site-header">
  <div class="container site-header__inner">

    <a class="site-header__logo" href="<%= ctx %>/">
      <img src="<%= ctx %>/images/logo.png" alt="Kuro Logi 물류시스템">
    </a>

    <nav class="main-nav">
      <ul class="main-nav__list">
        <li class="main-nav__item">
          <a href="<%= ctx %>/service/info_company">서비스 안내</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/service/info_company">KURO Logi 소개</a></li>
            <li><a href="<%= ctx %>/service/info_grade">회원등급, 수수료 안내</a></li>
            <li><a href="<%= ctx %>/service/weightchart2">국제배송비 안내</a></li>
            <li><a href="<%= ctx %>/service/info_regulation">검수규정,보상규정</a></li>
            <li><a href="<%= ctx %>/service/clearance_policy">통관불가 품목</a></li>
            <li><a href="<%= ctx %>/service/listpass_help">목록통관 품목안내</a></li>
            <li><a href="<%= ctx %>/service/manual">KURO 사용메뉴얼</a></li>
          </ul>
        </li>
        <li class="main-nav__item">
          <a href="<%= ctx %>/status/dashboard">종합현황</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/status/dashboard">종합현황</a></li>
            <li><a href="<%= ctx %>/status/tracking">트레킹입력</a></li>
            <li><a href="<%= ctx %>/status/nodata">노데이터 확인</a></li>
            <li><a href="<%= ctx %>/status/storage">보관현황</a></li>
          </ul>
        </li>
        <li class="main-nav__item">
          <a href="<%= ctx %>/mypage">마이페이지</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/mypage">마이페이지</a></li>
            <li><a href="<%= ctx %>/mypage/account">계정관리</a></li>
            <li><a href="<%= ctx %>/mypage/payment">결제방법</a></li>
            <li><a href="<%= ctx %>/mypage/address">주소관리</a></li>
          </ul>
        </li>
        <li class="main-nav__item">
          <a href="<%= ctx %>/buy/order_form">구매대행</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/buy/order_form">주문서등록</a></li>
            <li><a href="<%= ctx %>/stock/form">재고구매신청등록</a></li>
            <li><a href="<%= ctx %>/buyorder/list">구매대행 주문내역</a></li>
          </ul>
        </li>
        <li class="main-nav__item">
          <a href="<%= ctx %>/ship/order_form">배송대행</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/ship/order_form">주문서등록</a></li>
          </ul>
        </li>
        <li class="main-nav__item">
          <a href="<%= ctx %>/community/notice">커뮤니티</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/community/notice">공지사항</a></li>
            <li><a href="<%= ctx %>/community/qna">1:1게시판</a></li>
            <li><a href="<%= ctx %>/community/message">알림메세지</a></li>
            <li><a href="<%= ctx %>/community/faq">자주묻는 질문</a></li>
          </ul>
        </li>
      </ul>
    </nav>


  </div>
</header>

<main>

  <!-- ================================================================
       1) 배너 슬라이더 + 로그인 / 배송센터
       ================================================================ -->
  <section class="section">
    <div class="container">
      <div class="row">

        <div class="col col--two-thirds">
          <div class="hero">
            <a class="hero__link" href="#" aria-label="배너 자세히 보기"></a>
            <button class="hero__arrow hero__arrow--prev" type="button" aria-label="이전">‹</button>
            <button class="hero__arrow hero__arrow--next" type="button" aria-label="다음">›</button>
            <div class="hero__dots">
              <span class="is-active"></span><span></span><span></span>
            </div>
          </div>
        </div>

        <div class="col col--one-third">

          <!-- 로그인 -->
          <div class="card">
            <div class="card__body">
<%  if (member == null) { %>
             <form id="loginForm" method="post" action="<%= ctx %>/member/login">
                <input type="hidden" name="_csrf" value="<%= Html.esc(Session.csrfToken(request)) %>">
<%      if (loginMessage != null) { %>
                <p class="login-message"><%= loginMessage %></p>
<%      } %>
                <input class="field field--block" type="text" name="loginId" value="<%= Html.esc(savedId) %>" maxlength="20" placeholder="ID" aria-label="ID" required>
                <input class="field field--block" type="password" name="password" maxlength="30" placeholder="PASSWORD" aria-label="PASSWORD" required>
                <button class="btn btn--primary btn--block" type="submit">로그인</button>
                <label class="checkbox"><input type="checkbox" name="saveId" value="Y" tabindex="-1"<%= Html.checked(savedId != null) %>> 아이디저장</label>
                <div class="btn-row btn-row--split">
                  <a class="btn btn--dark" href="${pageContext.request.contextPath}/member/join">회원가입</a>
                  <a class="btn btn--dark" href="${pageContext.request.contextPath}/member/find/id">ID/pw 찾기</a>
                </div>
              </form>
<%  } else { %>
              <div id="loginForm">
                <p class="login-welcome"><strong><%= Html.esc(member.getName()) %></strong>님 환영합니다.<br>나의 사서함 <strong><%= Html.esc(member.getMailboxNo()) %></strong></p>
                <div class="btn-row btn-row--split">
                  <a class="btn btn--primary" href="<%= ctx %>/mypage">마이페이지</a>
                  <a class="btn btn--dark" href="<%= ctx %>/logout">로그아웃</a>
                </div>
              </div>
<%  } %>
            </div>
          </div>

          <!-- 배송센터 안내 탭 -->
          <div class="tabs">
            <ul class="tabs__nav">
              <li class="tabs__item is-active" data-pane="center-air"><a href="#">항공-도쿄(JP)</a></li>
              <li class="tabs__item" data-pane="center-sea1"><a href="#">해상-후쿠오카 제1센터(JP)</a></li>
              <li class="tabs__item" data-pane="center-sea2"><a href="#">해상-후쿠오카 제2센터(JP)</a></li>
            </ul>

            <div class="tabs__pane is-active" id="center-air">
              <table class="table">
                <tbody>
                  <tr><th>주소</th><td>東京都小平市鈴木町1-466-19-3F</td></tr>
                  <tr><th>사서함번호</th><td><%= Html.esc(mailboxNo) %></td></tr>
                  <tr><th>우편번호</th><td>187-0011</td></tr>
                  <tr><th>전화번호</th><td>042-401-0754</td></tr>
                </tbody>
              </table>
            </div>

            <div class="tabs__pane" id="center-sea1">
              <table class="table">
                <tbody>
                  <tr><th>주소</th><td>福岡県 福岡市 博多区 昭南町 2-3-8-3F</td></tr>
                  <tr><th>사서함번호</th><td><%= Html.esc(mailboxNo) %></td></tr>
                  <tr><th>우편번호</th><td>812-0876</td></tr>
                  <tr><th>전화번호</th><td>070-9293-9189</td></tr>
                </tbody>
              </table>
            </div>

            <div class="tabs__pane" id="center-sea2">
              <table class="table">
                <tbody>
                  <tr><th>주소</th><td>福岡県糟屋郡粕屋町仲原２７７４−６ KURO</td></tr>
                  <tr><th>사서함번호</th><td><%= Html.esc(mailboxNo) %></td></tr>
                  <tr><th>우편번호</th><td>811-2304</td></tr>
                  <tr><th>전화번호</th><td>070-9285-4145</td></tr>
                </tbody>
              </table>
            </div>
          </div>

          <div class="btn-row btn-row--split btn-row--spaced">
            <a class="btn btn--dark" href="#">배송대행 신청</a>
            <a class="btn btn--dark" href="#">구매대행 신청</a>
          </div>

        </div>
      </div>
    </div>
  </section>

  <!-- ================================================================
       2) 운송장 조회
       ================================================================ -->
  <section class="section">
    <div class="container">
      <div class="row">

        <div class="col col--half">
          <h4 class="panel-title panel-title--line">한국 운송장조회</h4>
          <div class="card card--blue">
            <div class="card__body">
              <div class="search-bar">
                <a class="btn btn--dark btn--lg" href="#">한국</a>
                <select class="field field--lg" aria-label="배송방법">
                  <option value="AIR">도쿄에어</option>
                  <option value="SEA">후쿠오카 고속해상</option>
                </select>
                <input class="field field--lg" type="text" placeholder="운송장번호 입력" aria-label="운송장번호">
                <a class="btn btn--dark btn--lg" href="#">검색</a>
              </div>
            </div>
          </div>
        </div>

        <div class="col col--half">
          <h4 class="panel-title panel-title--line">일본 운송장조회</h4>
          <div class="card card--yellow">
            <div class="card__body">
              <div class="search-bar">
                <a class="btn btn--dark btn--lg" href="#">일본</a>
                <select class="field field--lg" aria-label="택배사">
                  <option value="YAMATO" selected>야마토</option>
                  <option value="SAGAWA">사가와</option>
                  <option value="AMAZON">Amazon</option>
                  <option value="JAPANPOST">우체국</option>
                  <option value="SEINO">세이노</option>
                  <option value="FUKUTSU">후쿠야마</option>
                  <option value="LASTONE">라스트원</option>
                  <option value="MEITETSU">메이테츠</option>
                </select>
                <input class="field field--lg" type="text" placeholder="트레킹넘버 입력" aria-label="운송장번호">
                <a class="btn btn--dark btn--lg" href="#">검색</a>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  </section>

  <!-- ================================================================
       3) 공지사항 / 센터 현황 / 계좌정보
       ================================================================ -->
  <section class="section">
    <div class="container">
      <div class="row">

        <div class="col col--one-third">
          <h4 class="panel-title panel-title--line">
            공지사항
            <a class="panel-title__more" href="#">더보기 +</a>
          </h4>
          <div class="card card--pad">
            <ul class="notice-list">
              <li class="notice-list__item">
                <p class="notice-list__title">
                  <span class="badge badge--info">새글</span>&nbsp;&nbsp;<a href="#">[긴급!] 스마트스토어 발송처리시 -&gt; CJ대한통운 임시 설정 부탁! </a>
                </p>
                <span class="badge badge--date">2026-10-03</span>
              </li>
              <li class="notice-list__item">
                <p class="notice-list__title"><a href="#">[중요!!] 해상 대형화물 옵션 수수료 차감 안내</a></p>
                <span class="badge badge--date">2026-10-01</span>
              </li>
              <li class="notice-list__item">
                <p class="notice-list__title"><a href="#">[중요!] 항공 통관시스템 변경에 따른 오픈마켓 택배사 선택 변경요</a></p>
                <span class="badge badge--date">2026-09-24</span>
              </li>
              <li class="notice-list__item">
                <p class="notice-list__title"><a href="#">[중요!] 해상 리드타임 단축 &amp; 재고 보관비무료 이벤트!</a></p>
                <span class="badge badge--date">2026-09-21</span>
              </li>
            </ul>
          </div>
        </div>

        <div class="col col--one-third">
          <h4 class="panel-title panel-title--line">센터별 현재 출고상황</h4>
          <div class="card card--pad">
            <table class="center-status">
              <tbody>
                <tr>
                  <td class="center-status__cell"><img src="<%= ctx %>/images/center_air.png" alt="항공-도쿄"></td>
                  <td class="center-status__cell"><img src="<%= ctx %>/images/center_sea1.png" alt="해상-후쿠오카 제1센터"></td>
                  <td class="center-status__cell center-status__cell--last"><img src="<%= ctx %>/images/center_sea2.png" alt="해상-후쿠오카 제2센터"></td>
                </tr>
                <tr>
                  <td class="center-status__cell center-status__name">항공-도쿄(JP)</td>
                  <td class="center-status__cell center-status__name">해상-후쿠오카 제1센터(JP)</td>
                  <td class="center-status__cell center-status__cell--last center-status__name">해상-후쿠오카 제2센터(JP)</td>
                </tr>
                <tr>
                  <td class="center-status__cell"><img class="center-status__status" src="<%= ctx %>/images/status_outday.png" alt="당일 입고분 출고중"></td>
                  <td class="center-status__cell"><img class="center-status__status" src="<%= ctx %>/images/status_outday.png" alt="당일 입고분 출고중"></td>
                  <td class="center-status__cell center-status__cell--last"><img class="center-status__status" src="<%= ctx %>/images/status_outday.png" alt="당일 입고분 출고중"></td>
                </tr>
                <tr>
                  <td class="center-status__cell">당일 입고분 출고중</td>
                  <td class="center-status__cell">당일 입고분 출고중</td>
                  <td class="center-status__cell center-status__cell--last">당일 입고분 출고중</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="col col--one-third">
          <h4 class="panel-title panel-title--line">계좌정보</h4>
          <div class="card card--pad">
            <div class="card__body">
              <p class="text-16 bank-logo"><img src="<%= ctx %>/images/img_bank.png" alt="SBI SUMISHIN NET BANK"></p>
              <p class="text-16">SBI SUMISHIN NET BANK, LTD.</p>
              <p class="text-16">예금주명: USPbrain Co., Ltd</p>
              <p class="text-20 text-blue">1537388 (JAPANESE YEN)/NTSSJPJT</p>
            </div>
          </div>
        </div>

      </div>
    </div>
  </section>

  <!-- ================================================================
       4) 고객센터 / 환율정보
       ================================================================ -->
  <section class="section">
    <div class="container">
      <div class="row">

        <div class="col col--one-third">
          <h4 class="panel-title panel-title--line">고객센터</h4>
          <div class="card card--pad">
            <div class="card__body">
              <p class="text-18">Tel : <span class="text-blue text-18">(+81) 042-401-0754 / 일본</span></p>
              <p class="text-16">평일 9:30~17:30</p>
              <p class="text-16 text-red text-semibold">일요일휴무, 토요일/공휴일 정상근무(일본기준)</p>
              <p class="text-16">email : support@kurologi.jp</p>

              <div class="stack">
                <a class="btn btn--dark" href="#">자주묻는질문</a>
                <a class="btn btn--dark" href="#">사용메뉴얼</a>
              </div>
            </div>
          </div>
        </div>

        <div class="col col--one-third">
          <h4 class="panel-title panel-title--line">환율정보(100엔)</h4>
          <div class="card card--pad">
            <div class="card__body text-center">
              <p class="text-15">환율 기준일 :  2026.10.03</p>
              <p class="exchange exchange--main">
                <img class="exchange__flag" src="<%= ctx %>/images/flag_jp.png" alt="JP"> 고시환율(원)<span class="exchange__value text-red">876.31</span>
              </p>
              <p class="exchange text-16">기준환율(원)<span class="exchange__value text-blue">854.58</span></p>
              <p class="exchange text-16">송금환율(원)<span class="exchange__value text-blue">862.95</span></p>
            </div>
          </div>
        </div>

      </div>
    </div>
  </section>

</main>

<!-- ==================================================================
     푸터
     ================================================================== -->
<footer class="site-footer">
  <div class="container site-footer__inner">
    <div class="row">

      <div class="col col--footer-logo">
        <img class="site-footer__logo" src="<%= ctx %>/images/logo.png" alt="Kuro Logi 물류시스템">
      </div>

      <div class="col col--footer-info">
        <div class="footer-links">
          <a href="#">이용약관</a>
          <a href="#">개인정보처리방침</a>
          <a href="#">이메일무단수집거부</a>
          <a href="#">特定商取引法に基づく表示</a>
          <a href="#">個人情報保護方針</a>
        </div>
        <p class="site-footer__text">
          KURO Logi ( USPbrain Co., Ltd ) / WTKOREA <br>
          3F, 1-466-19,  Suzukicho, Kodaira Shi, Tokyo To, 187-0011, Japan<br>
          Tel(일본) : (+81) 042-401-0754<br><br>
          Kuro Logi 물류시스템 에서 운영하는 배송대행은 관세법등 관련규정을 준수합니다.
          불법물건을 취급하지 않으며, 분할배송 및 가격허위신고 등 고객의 불법사항 요청에는<br>
          협조하지 않습니다. 고객님의 허위신고로 인한 불이익에는 책임지지 않습니다.
        </p>
      </div>

    </div>
  </div>
  <p class="copyright">ⓒ 2023 All Rights Reserved by KUROLogi.</p>
</footer>

<script>
(function () {
  /* ---- 배송센터 탭 ---- */
  var tabItems = document.querySelectorAll('.tabs__item');
  tabItems.forEach(function (item) {
    item.querySelector('a').addEventListener('click', function (e) {
      e.preventDefault();
      tabItems.forEach(function (other) { other.classList.remove('is-active'); });
      item.classList.add('is-active');
      document.querySelectorAll('.tabs__pane').forEach(function (pane) {
        pane.classList.toggle('is-active', pane.id === item.dataset.pane);
      });
    });
  });

  /* ---- 팝업 ---- */
  var popup = document.getElementById('emergencyPopup');
  document.querySelectorAll('[data-close-popup]').forEach(function (el) {
    el.addEventListener('click', function () { popup.classList.add('is-hidden'); });
  });
  /* 일주일 동안 보지 않기 */
  var HIDE_KEY = 'kuroPopupHideUntil';
  try {
    var until = parseInt(localStorage.getItem(HIDE_KEY), 10);
    if (until && until > Date.now()) popup.classList.add('is-hidden');
    else if (until) localStorage.removeItem(HIDE_KEY);
  } catch (err) {}

  popup.querySelector('.popup__mute input').addEventListener('change', function (e) {
    if (e.target.checked) {
      try { localStorage.setItem(HIDE_KEY, String(Date.now() + 7 * 24 * 60 * 60 * 1000)); } catch (err) {}
      popup.classList.add('is-hidden');
    }
  });
})();
</script>
</body>
</html>
