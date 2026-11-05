<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="jp.kurologi.model.*" %>
<%@ page import="jp.kurologi.web.Html" %>
<%@ page import="jp.kurologi.web.Session" %>
<%
    String ctx = request.getContextPath();

    request.setAttribute("menu", "mypage");   // layout.jsp 주 메뉴에서 현재 메뉴 표시

    String field = (String) request.getAttribute("field");          // name | address
    String q = (String) request.getAttribute("q");                  // 검색어
    Page<Address> result = (Page<Address>) request.getAttribute("result");
    Map<String, String> errors = Html.errors(request);

    // 저장 실패로 다시 그릴 때는 회원이 입력한 값, 아니면 빈 주소 (국가 기본값 South Korea)
    Address f = (Address) request.getAttribute("form");
    if (f == null) f = new Address();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>주소관리 | NIPPON BUY</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>/* ==========================================================================
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

.page-body { padding: 24px 0 40px; }

:root {
  --orange: #ff7000;
  --navy:   #1e3354;
}

/* ============================================================
   주소관리 — 나의 주소록
   ============================================================ */

.sub-title {
  margin: 0 0 30px;
  font-size: 30px;
  font-weight: 700;
  color: var(--ink);
}

.sub-title__dash { display: none; }

/* 검색 줄 */
.addr-search {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 30px;
  padding: 20px;
  background: #f3f3f3;
  border: 1px solid var(--line);
}

.addr-search__label {
  font-size: 15px;
  font-weight: 700;
  color: var(--ink);
}

.addr-search__select,
.addr-search__input {
  padding: 10px 12px;
  font-family: inherit;
  font-size: 14px;
  color: var(--ink);
  background: #fff;
  border: 1px solid var(--line);
}

.addr-search__select { width: 190px; }
.addr-search__input { flex: 0 0 300px; }

.addr-search__select:focus,
.addr-search__input:focus { outline: none; border-color: var(--teal); }

.addr-search__btn {
  padding: 9px 13px;
  font-size: 15px;
  color: #fff;
  background: #b9b9b9;
  border: 0;
  cursor: pointer;
}

.addr-search__btn:hover { background: #a5a5a5; }

.addr-search__add {
  margin-left: auto;
  padding: 12px 22px;
  font-family: inherit;
  font-size: 14px;
  font-weight: 700;
  color: #fff;
  background: var(--orange);
  border: 0;
  border-radius: var(--radius);
  cursor: pointer;
}

.addr-search__add:hover { background: #e06400; }

/* 주소 카드 */
.addr-list {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 30px;
}

.addr-card {
  padding: 16px;
  background: var(--fill);
  border: 1px solid var(--line);
}

.addr-card__name {
  margin: 0 0 12px;
  font-size: 15px;
  font-weight: 700;
  color: var(--ink);
}

.addr-card__line {
  margin: 0 0 3px;
  font-size: 13px;
  line-height: 1.6;
  color: var(--body);
  word-break: break-all;
}

.addr-card__actions { display: flex; gap: 4px; margin-top: 12px; }

/* 버튼 */
.btn {
  display: inline-block;
  padding: 8px 20px;
  font-family: inherit;
  font-size: 13px;
  font-weight: 700;
  color: #fff;
  background: #a5a5a5;
  border: 0;
  border-radius: var(--radius);
  cursor: pointer;
}

.btn:hover { background: #8f8f8f; }
.btn--white { color: var(--ink); background: #fff; border: 1px solid var(--line); }
.btn--white:hover { background: #f2f2f2; }

/* 페이지 번호 */
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

/* ==================== JSP 에서 추가한 스타일 ==================== */

/* ------------------------------------------------- 서버 알림 · 입력 오류 */

.flash {
  margin: 16px 0 0;
  padding: 12px 16px;
  font-size: 14px;
  color: #155724;
  background: #e8f5ec;
  border: 1px solid #c3e6cb;
  border-radius: var(--radius);
}

.flash--error { color: #8a1f11; background: #fdecea; border-color: #f5c6cb; }

.field-error { margin: 6px 0 0; font-size: 12px; color: var(--red); }

/* 복사 완료 알림 (common.js) */
.toast {
  position: fixed;
  left: 50%;
  bottom: 40px;
  z-index: 1000;
  padding: 10px 20px;
  font-size: 14px;
  color: #fff;
  background: rgba(0, 0, 0, .8);
  border-radius: var(--radius);
  transform: translateX(-50%);
  opacity: 0;
  transition: opacity .2s;
  pointer-events: none;
}

.toast.is-shown { opacity: 1; }

/* ------------------------------------------------ JSP 추가 */

.pager__item { margin: 0 2px; }
.pager__item.is-active { color: #fff; background: var(--orange); }

.addr-empty { margin: 0 0 30px; padding: 40px 0; text-align: center; color: var(--muted); border: 1px dashed var(--line); }

.addr-card__actions form { margin: 0; }

.input {
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
.input--short { width: 120px; }

/* 새주소추가 / 수정 대화상자 */
.addr-dialog {
  width: 600px;
  padding: 24px;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  box-shadow: 0 13px 42px 11px rgba(0, 0, 0, .1);
}

.addr-dialog::backdrop { background: rgba(0, 0, 0, .4); }

.addr-dialog__title { margin: 0 0 16px; font-size: 20px; font-weight: 700; color: var(--ink); }

.addr-dialog__table { width: 100%; border-collapse: collapse; }

.addr-dialog__table th,
.addr-dialog__table td {
  padding: 10px 12px;
  font-size: 14px;
  border: 1px solid var(--line);
  vertical-align: middle;
}

.addr-dialog__table th { width: 120px; text-align: left; color: var(--ink); background: var(--fill); }

.addr-dialog__actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }
.addr-dialog__actions .addr-search__add { margin-left: 0; }
</style>
</head>
<body>
<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>

<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">주소관리</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/mypage">마이페이지</a></li>
      <li class="breadcrumb__item is-current">주소관리</li>
    </ol>
  </div>
</section>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="flash" /></jsp:include>

<main class="page-body">
  <div class="container">

    <h1 class="sub-title"><span class="sub-title__dash"></span>나의 주소록</h1>

    <form class="addr-search" method="get" action="<%= ctx %>/mypage/address">
      <span class="addr-search__label">주소검색</span>
      <select class="addr-search__select" name="field" aria-label="검색 기준">
        <option value="name"<%= Html.selected("name".equals(field)) %>>이름</option>
        <option value="address"<%= Html.selected("address".equals(field)) %>>주소</option>
      </select>
      <input class="addr-search__input" type="text" name="q" value="<%= Html.esc(q) %>" aria-label="검색어">
      <button class="addr-search__btn" type="submit" aria-label="검색">🔍</button>
      <button class="addr-search__add" type="button" data-addr-new>새주소추가</button>
    </form>

    <div class="addr-list">
<%  for (Address a : result.items()) { %>
      <div class="addr-card">
        <p class="addr-card__name"><%= Html.esc(a.getName()) %></p>
        <p class="addr-card__line"><%= Html.esc(a.getFullAddress()) %></p>
        <p class="addr-card__line"><%= Html.esc(a.getCountry()) %></p>
        <p class="addr-card__line">전화 번호: <%= Html.esc(a.getPhone()) %></p>
        <p class="addr-card__line">개인 통관 부호: <%= Html.esc(a.getCustomsCode()) %></p>
        <div class="addr-card__actions">
          <button class="btn btn--sm" type="button" data-addr-edit
                  data-id="<%= a.getId() %>" data-name="<%= Html.esc(a.getName()) %>" data-zipcode="<%= Html.esc(a.getZipcode()) %>"
                  data-address1="<%= Html.esc(a.getAddress1()) %>" data-address2="<%= Html.esc(a.getAddress2()) %>"
                  data-country="<%= Html.esc(a.getCountry()) %>" data-phone="<%= Html.esc(a.getPhone()) %>"
                  data-customs-code="<%= Html.esc(a.getCustomsCode()) %>">수정</button>
          <form method="post" action="<%= ctx %>/mypage/address" data-confirm="이 주소를 삭제하시겠습니까?">
            <input type="hidden" name="_csrf" value="<%= Html.esc(session.getAttribute(Session.CSRF)) %>">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" value="<%= a.getId() %>">
            <button class="btn btn--sm btn--white" type="submit">삭제</button>
          </form>
        </div>
      </div>
<%  } %>
    </div>
<%  if (result.items().isEmpty()) { %>
    <p class="addr-empty"><%= q.isEmpty() ? "등록된 주소가 없습니다. 새주소추가 버튼으로 주소를 등록해 주세요." : "검색 결과가 없습니다." %></p>
<%  } %>

    <div class="pager">
<%  for (int n = 1; n <= result.getTotalPages(); n++) { %>
      <a class="pager__item<%= Html.cls(n == result.page(), "is-active") %>"
         href="<%= ctx %>/mypage/address?field=<%= field %>&amp;q=<%= Html.url(q) %>&amp;page=<%= n %>"><%= n %></a>
<%  } %>
    </div>

  </div>
</main>

<%-- 새주소추가 / 수정 대화상자 — 저장 실패 시 data-open 으로 다시 엽니다 --%>
<dialog class="addr-dialog" id="addrDialog"<%= errors.isEmpty() ? "" : " data-open" %>>
  <form method="post" action="<%= ctx %>/mypage/address" novalidate>
    <input type="hidden" name="_csrf" value="<%= Html.esc(session.getAttribute(Session.CSRF)) %>">
    <input type="hidden" name="action" value="save">
    <input type="hidden" name="id" value="<%= f.getId() %>">
    <h2 class="addr-dialog__title" data-dialog-title><%= f.getId() != 0 ? "주소 수정" : "새주소추가" %></h2>
    <table class="addr-dialog__table">
      <tbody>
        <tr>
          <th><label for="addrName">받는 사람</label></th>
          <td><input id="addrName" class="input" name="name" value="<%= Html.esc(f.getName()) %>" maxlength="30" required>
            <%= Html.error(errors, "name") %></td>
        </tr>
        <tr>
          <th><label for="addrZipcode">우편번호</label></th>
          <td><input id="addrZipcode" class="input input--short" name="zipcode" value="<%= Html.esc(f.getZipcode()) %>" maxlength="5" inputmode="numeric" required>
            <button class="btn btn--sm" type="button" data-zipcode-search>우편번호 검색</button>
            <%= Html.error(errors, "zipcode") %></td>
        </tr>
        <tr>
          <th><label for="addrAddress1">주소</label></th>
          <td><input id="addrAddress1" class="input" name="address1" value="<%= Html.esc(f.getAddress1()) %>" maxlength="200" required>
            <%= Html.error(errors, "address1") %></td>
        </tr>
        <tr>
          <th><label for="addrAddress2">상세주소</label></th>
          <td><input id="addrAddress2" class="input" name="address2" value="<%= Html.esc(f.getAddress2()) %>" maxlength="200"></td>
        </tr>
        <tr>
          <th><label for="addrCountry">국가</label></th>
          <td><input id="addrCountry" class="input" name="country" value="<%= Html.esc(f.getCountry()) %>" maxlength="50"></td>
        </tr>
        <tr>
          <th><label for="addrPhone">전화번호</label></th>
          <td><input id="addrPhone" class="input" type="tel" name="phone" value="<%= Html.esc(f.getPhone()) %>" placeholder="010-0000-0000" required>
            <%= Html.error(errors, "phone") %></td>
        </tr>
        <tr>
          <th><label for="addrCustomsCode">개인통관부호</label></th>
          <td><input id="addrCustomsCode" class="input" name="customsCode" value="<%= Html.esc(f.getCustomsCode()) %>" placeholder="P000000000000" maxlength="13" required>
            <%= Html.error(errors, "customsCode") %></td>
        </tr>
      </tbody>
    </table>
    <div class="addr-dialog__actions">
      <button class="btn btn--sm btn--white" type="button" data-dialog-close>취소</button>
      <button class="addr-search__add" type="submit">저장</button>
    </div>
  </form>
</dialog>

<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js" defer></script>
<script>
/* 주소관리 — 새주소추가/수정 대화상자 · 다음(카카오) 우편번호 검색 */
(function () {
  'use strict';

  var dialog = document.getElementById('addrDialog');
  if (!dialog) return;
  var form = dialog.querySelector('form');
  var fields = ['name', 'zipcode', 'address1', 'address2', 'country', 'phone', 'customsCode'];

  function clearErrors() {
    dialog.querySelectorAll('.field-error').forEach(function (p) { p.remove(); });
  }

  function open(data) {
    clearErrors();
    form.elements.id.value = data.id || 0;
    fields.forEach(function (f) { form.elements[f].value = data[f] || ''; });
    if (!form.elements.country.value) form.elements.country.value = 'South Korea';
    dialog.querySelector('[data-dialog-title]').textContent = data.id ? '주소 수정' : '새주소추가';
    dialog.showModal();
    form.elements.name.focus();
  }

  document.querySelector('[data-addr-new]').addEventListener('click', function () { open({}); });

  document.querySelectorAll('[data-addr-edit]').forEach(function (btn) {
    btn.addEventListener('click', function () { open(btn.dataset); });   // data-customs-code → customsCode
  });

  dialog.querySelector('[data-dialog-close]').addEventListener('click', function () { dialog.close(); });

  // 서버 검증 실패로 다시 그려진 경우 입력값을 유지한 채 다시 엽니다
  if (dialog.hasAttribute('data-open')) dialog.showModal();

  dialog.querySelector('[data-zipcode-search]').addEventListener('click', function () {
    if (!window.daum || !daum.Postcode) {
      alert('우편번호 검색을 불러오지 못했습니다. 직접 입력해 주세요.');
      return;
    }
    new daum.Postcode({
      oncomplete: function (d) {
        form.elements.zipcode.value = d.zonecode;
        form.elements.address1.value = d.roadAddress || d.jibunAddress;
        form.elements.address2.focus();
      }
    }).open();
  });
})();
</script>
<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
