<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, jp.kurologi.model.Page, jp.kurologi.model.MessageDTO, jp.kurologi.web.Html, jp.kurologi.web.Session" %>
<%
    String ctx = request.getContextPath();
    request.setAttribute("menu", "community");   // layout.jsp 주 메뉴에서 현재 메뉴 표시
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>알림메세지 | KURO Logi</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from message.css */
/* ==========================================================================
   KURO Logi — 종합현황 (마이페이지 대시보드)

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


.page-body { padding: 24px 0 40px; }

:root {
  --orange: #ff7000;
  --navy:   #1e3354;
}


/* ============================================================
   목록형 페이지 공통 (툴바 · 표 · 페이지번호)
   ============================================================ */

.sub-title {
  margin: 0 0 24px;
  font-size: 28px;
  font-weight: 700;
  color: var(--ink);
}

.sub-title__dash {
  display: inline-block;
  width: 26px;
  height: 3px;
  margin-right: 10px;
  vertical-align: middle;
  background: var(--ink);
}

.pane-title {
  margin: 30px 0 12px;
  padding-left: 10px;
  font-size: 18px;
  font-weight: 700;
  color: var(--ink);
  border-left: 4px solid var(--orange);
}

/* 툴바 */
.pane-toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 14px;
  padding: 14px 16px;
  background: #f3f3f3;
  border: 1px solid var(--line);
}

.pane-toolbar__label { font-size: 14px; font-weight: 700; color: var(--ink); }

.pane-toolbar__select,
.pane-toolbar__input {
  padding: 8px 10px;
  font-family: inherit;
  font-size: 13px;
  color: var(--ink);
  background: #fff;
  border: 1px solid var(--line);
}

.pane-toolbar__select { width: 110px; }
.pane-toolbar__input { flex: 1 1 auto; max-width: 320px; }
.pane-toolbar__select:focus,
.pane-toolbar__input:focus { outline: none; border-color: var(--teal); }

.pane-toolbar__search {
  padding: 8px 12px;
  font-size: 14px;
  color: #fff;
  background: #b9b9b9;
  border: 0;
  cursor: pointer;
}
.pane-toolbar__search:hover { background: #a5a5a5; }

.pane-toolbar__action {
  margin-left: auto;
  padding: 10px 18px;
  font-family: inherit;
  font-size: 13px;
  font-weight: 700;
  color: #fff;
  background: var(--orange);
  border: 0;
  border-radius: var(--radius);
  cursor: pointer;
}
.pane-toolbar__action:hover { background: #e06400; }

/* 표 */
.data-table {
  width: 100%;
  border-collapse: collapse;
  border-top: 2px solid var(--ink);
  margin-bottom: 20px;
}

.data-table th,
.data-table td {
  padding: 13px 10px;
  font-size: 13px;
  color: var(--ink);
  border-bottom: 1px solid var(--line);
  vertical-align: middle;
}

.data-table thead th {
  font-weight: 700;
  text-align: center;
  background: #f3f3f3;
}

.data-table__empty { padding: 34px 10px; text-align: center; color: var(--muted); }
.data-table .is-narrow { width: 60px; text-align: center; }
.data-table .is-center { text-align: center; }
.data-table .is-left { text-align: left; }

.badge--new {
  display: inline-block;
  margin-right: 6px;
  padding: 1px 5px;
  font-size: 10px;
  font-weight: 700;
  color: #fff;
  background: var(--orange);
  border-radius: 2px;
}

.state {
  display: inline-block;
  padding: 2px 10px;
  font-size: 12px;
  border-radius: 999px;
}
.state--done { color: var(--orange); border: 1px solid var(--orange); }

/* 페이지 번호 / 버튼 / 입력 / 안내 */
.pager { text-align: center; }

.pager__item {
  display: inline-block;
  width: 34px;
  height: 34px;
  font-size: 14px;
  line-height: 32px;
  color: var(--orange);
  border: 1px solid var(--orange);
}

.btn {
  display: inline-block;
  padding: 10px 20px;
  font-family: inherit;
  font-size: 13px;
  font-weight: 700;
  color: #fff;
  background: #6f6f6f;
  border: 0;
  border-radius: var(--radius);
  cursor: pointer;
}
.btn:hover { background: #5c5c5c; }
.btn--navy { background: var(--navy); }
.btn--navy:hover { background: #16263f; }
.btn--sm { padding: 8px 14px; font-size: 12px; }

.btn-row {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-top: 24px;
}

.input,
.select-like {
  width: 100%;
  padding: 8px 10px;
  font-family: inherit;
  font-size: 13px;
  color: #495057;
  background: #fff;
  border: 1px solid var(--line);
  border-radius: var(--radius);
}
.input:focus { outline: none; border-color: var(--teal); }

.info-box {
  margin: 0 0 22px;
  padding: 16px 18px;
  font-size: 13px;
  line-height: 1.9;
  color: var(--body);
  background: #f7fbfb;
  border: 1px solid #d9ecec;
  border-radius: var(--radius);
}
.info-box p { margin: 4px 0; }
.info-box p:first-child { margin-top: 0; }
.info-box p:last-child { margin-bottom: 0; }

.note-list { margin: 0; padding: 0; list-style: none; }
.note-list li {
  padding: 4px 0 4px 12px;
  font-size: 13px;
  line-height: 1.8;
  color: var(--body);
  text-indent: -12px;
}
.note-list li::before { content: '* '; color: var(--red); }

.form-table {
  width: 100%;
  margin-bottom: 24px;
  border-collapse: collapse;
}
.form-table th,
.form-table td {
  padding: 12px 14px;
  font-size: 13px;
  border: 1px solid var(--line);
  vertical-align: middle;
}
.form-table th {
  width: 15%;
  font-weight: 700;
  color: var(--ink);
  text-align: left;
  background: var(--fill);
}
.form-table td.is-readonly { color: var(--ink); }

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

/* --------------------------------------------------------------- DB 연결하면서 추가한 스타일 */
.flash {
  margin: 0 0 16px;
  padding: 12px 16px;
  font-size: 14px;
  color: #155724;
  background: #e8f5ec;
  border: 1px solid #c3e6cb;
  border-radius: var(--radius);
}
.flash--error { color: #8a1f11; background: #fdecea; border-color: #f5c6cb; }
.field-error { margin: 6px 0 0; font-size: 12px; color: var(--red); }

.state--wait { color: var(--muted); border: 1px solid #cfcfcf; }
a.pager__item { text-decoration: none; }
.pager__item.is-active { color: #fff; background: var(--orange); }
a.btn { text-decoration: none; }
a.btn:hover { color: #fff; }
.btn-row form { margin: 0; }
textarea.input { min-height: 240px; line-height: 1.7; resize: vertical; }

.view-box { margin-bottom: 8px; border-top: 2px solid var(--ink); }
.view-title { margin: 0; padding: 16px 14px; font-size: 18px; color: var(--ink); border-bottom: 1px solid var(--line); }
.view-meta { margin: 0; padding: 10px 14px; font-size: 12px; color: var(--muted); background: var(--fill); border-bottom: 1px solid var(--line); }
.view-meta span + span::before { content: '|'; margin: 0 10px; color: #ccc; }
.view-content { padding: 22px 14px; min-height: 160px; font-size: 14px; line-height: 1.9; color: var(--ink); border-bottom: 1px solid var(--line); word-break: break-word; }

.answer-box { margin-top: 24px; border: 1px solid var(--orange); border-radius: var(--radius); }
.answer-box__head { padding: 10px 14px; font-size: 13px; font-weight: 700; color: var(--orange); background: var(--orange-bg); }
.answer-box__body { padding: 16px 14px; font-size: 14px; line-height: 1.8; color: var(--ink); word-break: break-word; }
.answer-box__meta { margin-top: 8px; font-size: 12px; color: var(--muted); }

.deal-card__thumb img { max-width: 100%; max-height: 100%; object-fit: contain; }

.faq-table li { padding: 5px 0; text-indent: 0; }
.faq-table li::before { content: none; }
.faq-table summary { cursor: pointer; list-style: none; color: var(--body); }
.faq-table summary::-webkit-details-marker { display: none; }
.faq-table summary::before { content: '› '; color: var(--orange); }
.faq-table summary:hover { color: var(--teal); }
.faq-a { margin: 8px 0 4px 12px; padding: 12px 14px; font-size: 13px; line-height: 1.8; color: var(--ink); white-space: pre-line; background: var(--fill); border-radius: var(--radius); }

/* 알림메세지 : [선택 확인 / 선택 삭제] 버튼과 아래 페이지 번호 사이를 띄운다 */
.pager { margin-top: 44px; }
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">알림메세지</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/community/notice">커뮤니티</a></li>
      <li class="breadcrumb__item is-current">알림메세지</li>
    </ol>
  </div>
</section>


<main class="page-body">
  <div class="container">

<%
    Page<MessageDTO> pg = (Page<MessageDTO>) request.getAttribute("pageData");
    List<MessageDTO> items = (pg == null) ? new ArrayList<MessageDTO>() : pg.getItems();
    String searchType = (String) request.getAttribute("searchType");
    String keyword = (String) request.getAttribute("keyword");
    if (searchType == null) searchType = "all";
    if (keyword == null) keyword = "";
    int curPage = (pg == null) ? 1 : pg.getPage();
    request.setAttribute("pagerBase", ctx + "/community/message"
            + (keyword.isEmpty() ? "" : "?searchType=" + Html.url(searchType) + "&keyword=" + Html.url(keyword)));
%>
    <jsp:include page="../common/layout.jsp"><jsp:param name="part" value="flash" /></jsp:include>

    <h1 class="sub-title"><span class="sub-title__dash"></span>알림메세지</h1>

    <div class="info-box">
      <p>입고·출고·배송 상태 변경 시 발송된 알림 내역입니다.</p>
    </div>

    <form class="pane-toolbar" method="get" action="<%= ctx %>/community/message">
      <span class="pane-toolbar__label">검색</span>
      <select class="pane-toolbar__select" name="searchType" aria-label="검색 구분">
        <option value="all"<%= Html.selected("all".equals(searchType)) %>>전체</option>
        <option value="type"<%= Html.selected("type".equals(searchType)) %>>구분</option>
        <option value="content"<%= Html.selected("content".equals(searchType)) %>>내용</option>
      </select>
      <input class="pane-toolbar__input" type="text" name="keyword" value="<%= Html.esc(keyword) %>" placeholder="검색어" aria-label="검색어">
      <button class="pane-toolbar__search" type="submit" aria-label="검색">🔍</button>
    </form>

    <form method="post" action="<%= ctx %>/community/message/read">
      <input type="hidden" name="_csrf" value="<%= Html.esc(Session.csrfToken(request)) %>">
      <input type="hidden" name="page" value="<%= curPage %>">

      <table class="data-table">
        <thead>
          <tr>
            <th class="is-narrow"><input type="checkbox" aria-label="전체 선택" onclick="var c=this.form.querySelectorAll('input[name=ids]');for(var i=0;i<c.length;i++){c[i].checked=this.checked;}"></th>
            <th>구분</th>
            <th>내용</th>
            <th>발송일시</th>
            <th>확인</th>
          </tr>
        </thead>
        <tbody>
<%  if (items.isEmpty()) { %>
          <tr><td class="data-table__empty" colspan="5"><%= keyword.isEmpty() ? "수신한 알림메세지가 없습니다." : "검색 결과가 없습니다." %></td></tr>
<%  } %>
<%  for (MessageDTO m : items) { %>
          <tr>
            <td class="is-center"><input type="checkbox" name="ids" value="<%= m.getMessageId() %>" aria-label="알림 선택"></td>
            <td class="is-center"><%= Html.esc(m.getMsgType()) %></td>
            <td class="is-left"><%= m.isRead() ? Html.esc(m.getContent()) : "<strong>" + Html.esc(m.getContent()) + "</strong>" %></td>
            <td class="is-center"><%= Html.esc(m.getSentAt()) %></td>
            <td class="is-center"><% if (m.isRead()) { %><span class="state state--done">확인</span><% } else { %><span class="state state--wait">미확인</span><% } %></td>
          </tr>
<%  } %>
        </tbody>
      </table>

<%  if (!items.isEmpty()) { %>
      <div class="btn-row">
        <button class="btn btn--navy" type="submit" formaction="<%= ctx %>/community/message/read">선택 확인</button>
        <button class="btn" type="submit" formaction="<%= ctx %>/community/message/delete" onclick="return confirm('선택한 알림을 삭제하시겠습니까?');">선택 삭제</button>
      </div>
<%  } %>
    </form>

    <jsp:include page="../common/community_pager.jsp" />

  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
