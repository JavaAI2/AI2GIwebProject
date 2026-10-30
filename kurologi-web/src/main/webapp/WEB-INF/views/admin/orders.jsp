<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="jp.kurologi.web.Html,jp.kurologi.web.Session,jp.kurologi.model.BuyOrderDTO,jp.kurologi.model.BuyOrderItemDTO,jp.kurologi.service.OrderStatus,jp.kurologi.service.ServiceType,java.text.DecimalFormat,java.util.List,java.util.Map" %>
<%
    String ctx = request.getContextPath();
    request.setAttribute("menu", "buy");   // layout.jsp 주 메뉴에서 현재 메뉴 표시

    // 주소창에서 JSP 를 바로 열면 데이터가 없으므로 컨트롤러 주소로 보낸다
    List<BuyOrderDTO> orders = (List<BuyOrderDTO>) request.getAttribute("orders");
    if (orders == null) {
        response.sendRedirect(ctx + "/admin/orders");
        return;
    }
    Map<Long, List<BuyOrderItemDTO>> itemsByOrder = (Map<Long, List<BuyOrderItemDTO>>) request.getAttribute("itemsByOrder");
    Map<String, Integer> counts = (Map<String, Integer>) request.getAttribute("counts");
    String svc = (String) request.getAttribute("svcFilter");
    String st = (String) request.getAttribute("stFilter");
    int curPage = (Integer) request.getAttribute("page");
    int totalPages = (Integer) request.getAttribute("totalPages");
    DecimalFormat df = new DecimalFormat("#,##0.##");
    String csrf = Session.csrfToken(request);

    // 필터 탭의 { 값, 이름 }
    String[][] SVC_TABS = { { "all", "전체" }, { "BUY", "구매대행" }, { "SHIP", "배송대행" } };
    String[][] ST_TABS = { { "all", "전체" }, { "submit", "접수신청" }, { "received", "입고완료" }, { "billed", "배송비 대기" }, { "shipped", "출고완료" }, { "delivering", "국내 배송 중" }, { "unpaid", "미결제" } };
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>주문 관리 | KURO Logi</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from notice.css */
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

/* --------------------------------------------------------------- 관리자 화면에서 추가한 스타일 */
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

.admin-tabs { display: flex; gap: 4px; margin: 0 0 22px; padding: 0; list-style: none; border-bottom: 2px solid var(--ink); }
.admin-tabs a { display: block; padding: 10px 18px; font-size: 14px; color: var(--body); text-decoration: none; background: var(--fill); border: 1px solid var(--line); border-bottom: 0; }
.admin-tabs a:hover { color: var(--ink); background: #ececec; }
.admin-tabs a.is-current { color: #fff; background: var(--ink); border-color: var(--ink); }

.admin-stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 30px; }
.admin-stat { padding: 22px 16px; text-align: center; background: #fff; border: 1px solid var(--line); border-radius: var(--radius); }
.admin-stat__label { margin: 0 0 8px; font-size: 13px; color: var(--muted); }
.admin-stat__value { margin: 0; font-size: 30px; font-weight: 700; color: var(--ink); }
.admin-stat--alert { border-color: var(--orange); background: var(--orange-bg); }
.admin-stat--alert .admin-stat__value { color: var(--orange); }

/* ------------------------------------------------- 주문 관리 (구매대행 · 배송대행) */
.filter-row { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; margin: 0 0 10px; }
.filter-row__label { margin-right: 6px; font-size: 13px; font-weight: 700; color: var(--ink); }
.filter-row a { padding: 5px 12px; font-size: 13px; color: var(--body); text-decoration: none; background: #fff; border: 1px solid var(--line); border-radius: 16px; }
.filter-row a:hover { background: var(--orange-bg); }
.filter-row a.is-current { color: #fff; background: var(--navy); border-color: var(--navy); }
.state--wait { color: var(--muted); border: 1px solid #bbb; }
.state--submit { color: var(--teal); border: 1px solid var(--teal); }
.state--received { color: #8a5a00; border: 1px solid #d9a441; }
.state--shipped { color: #fff; background: var(--green); border: 1px solid var(--green); }
.state--billed { color: #b34700; border: 1px solid #e8a15c; }
.state--delivering { color: #fff; background: #1b6fb5; border: 1px solid #1b6fb5; }
/* 테스트용 단계 변경 (01 ~ 05) */
.step-test { margin-top: 6px; font-size: 11px; }
.step-test summary { cursor: pointer; color: var(--muted); }
.step-test__btns { margin-top: 4px; }
.step-test__btns .btn { margin: 2px; }
.state--unpaid { color: var(--red); border: 1px solid var(--red); }
.state--paid { color: var(--teal); border: 1px solid var(--teal); }
.order-sub { display: block; margin-top: 2px; font-size: 12px; color: var(--muted); }
.order-items summary { cursor: pointer; }
.order-items ul { margin: 6px 0 0 16px; padding: 0; font-size: 12px; text-align: left; list-style: disc; color: var(--body); }
.inline-form { display: inline; }
.act-col .btn { margin: 2px 0; white-space: nowrap; }
a.pager__item { text-decoration: none; margin: 0 2px; }
.pager__item.is-active { color: #fff; background: var(--orange); }
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">주문 관리</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item">관리자</li>
      <li class="breadcrumb__item is-current">주문 관리</li>
    </ol>
  </div>
</section>

<main class="page-body">
  <div class="container">

    <jsp:include page="../common/layout.jsp"><jsp:param name="part" value="flash" /></jsp:include>

    <jsp:include page="../common/admin_tabs.jsp"><jsp:param name="current" value="orders" /></jsp:include>

    <h1 class="sub-title"><span class="sub-title__dash"></span>주문 관리</h1>

    <div class="info-box">
      <p>접수신청된 구매대행 · 배송대행 주문을 처리합니다. <strong>입고 처리 → 결제 확인 → 출고 처리</strong> 순서이며, 출고는 입고완료(또는 배송비 대기) + 결제완료 주문만 할 수 있습니다. (접수대기 주문은 표시되지 않습니다)</p>
    </div>

    <div class="filter-row">
      <span class="filter-row__label">서비스</span>
<% for (String[] t : SVC_TABS) { %>
      <a href="<%= ctx %>/admin/orders?svc=<%= t[0] %>&st=<%= st %>"<%= t[0].equals(svc) ? " class=\"is-current\"" : "" %>><%= t[1] %></a>
<% } %>
    </div>
    <div class="filter-row">
      <span class="filter-row__label">상태</span>
<% for (String[] t : ST_TABS) { %>
      <a href="<%= ctx %>/admin/orders?svc=<%= svc %>&st=<%= t[0] %>"<%= t[0].equals(st) ? " class=\"is-current\"" : "" %>><%= t[1] %> <%= counts.get(t[0]) %></a>
<% } %>
    </div>

    <table class="data-table">
      <thead>
        <tr>
          <th>주문번호</th>
          <th>구분</th>
          <th>회원</th>
          <th>상품</th>
          <th>수량</th>
          <th>금액</th>
          <th>상태 / 결제</th>
          <th>처리</th>
        </tr>
      </thead>
      <tbody>
<% if (orders.isEmpty()) { %>
        <tr><td class="data-table__empty" colspan="8">해당하는 주문이 없습니다.</td></tr>
<% } %>
<% for (BuyOrderDTO o : orders) {
       List<BuyOrderItemDTO> its = itemsByOrder.get(o.getOrderId());
       String firstName = (its == null || its.isEmpty()) ? "" : its.get(0).getItemNameEn();
       int n = (its == null) ? 0 : its.size();
       boolean unpaid = !"PAID".equals(o.getPayStatus());
       boolean canReceive = "SUBMIT".equals(o.getStatus());
       boolean canShip = ("RECEIVED".equals(o.getStatus()) || "BILLED".equals(o.getStatus())) && !unpaid;
%>
        <tr>
          <td class="is-center"><%= Html.esc(o.getOrderNo()) %><span class="order-sub"><%= Html.esc(o.getCreatedAt()) %></span></td>
          <td class="is-center"><%= ServiceType.label(o.getServiceType()) %></td>
          <td class="is-center"><%= Html.esc(o.getMemberName()) %><span class="order-sub"><%= Html.esc(o.getMemberLoginId()) %></span></td>
          <td class="is-left">
            <details class="order-items">
              <summary><%= Html.esc(firstName) %><% if (n > 1) { %> 외 <%= n - 1 %>건<% } %></summary>
              <ul>
<% if (its != null) { for (BuyOrderItemDTO it : its) { %>
                <li><%= it.getItemNo() %>. <%= Html.esc(it.getItemNameEn()) %> x <%= it.getQty() %> · 트래킹 <%= (it.getTrackingNo() == null || it.getTrackingNo().isEmpty()) ? "(없음)" : Html.esc(it.getTrackingNo()) %><% if (it.getShopSite() != null && !it.getShopSite().isEmpty()) { %> · <%= Html.esc(it.getShopSite()) %><% } %></li>
<% } } %>
              </ul>
            </details>
          </td>
          <td class="is-center"><%= o.getTotalQty() %></td>
          <td class="is-right">¥<%= df.format(o.getTotalYen()) %><% if (o.getAppliedRate() != null) { %><span class="order-sub">₩<%= df.format(o.getTotalKrw()) %></span><% } %></td>
          <td class="is-center">
            <span class="state <%= OrderStatus.css(o.getStatus()) %>"><%= OrderStatus.label(o.getStatus()) %></span>
            <span class="state <%= unpaid ? "state--unpaid" : "state--paid" %>"><%= unpaid ? "미결제" : "결제완료" %></span>
          </td>
          <td class="is-center act-col">
<% if (canReceive) { %>
            <form class="inline-form" action="<%= ctx %>/admin/orders/action" method="post" onsubmit="return confirm('입고 처리할까요?');">
              <input type="hidden" name="_csrf" value="<%= csrf %>"><input type="hidden" name="id" value="<%= o.getOrderId() %>"><input type="hidden" name="action" value="receive">
              <input type="hidden" name="svc" value="<%= svc %>"><input type="hidden" name="st" value="<%= st %>"><input type="hidden" name="page" value="<%= curPage %>">
              <button class="btn btn--sm" type="submit">입고 처리</button>
            </form>
<% } %>
<% if (unpaid) { %>
            <form class="inline-form" action="<%= ctx %>/admin/orders/action" method="post" onsubmit="return confirm('결제(입금)를 확인했습니까?');">
              <input type="hidden" name="_csrf" value="<%= csrf %>"><input type="hidden" name="id" value="<%= o.getOrderId() %>"><input type="hidden" name="action" value="pay">
              <input type="hidden" name="svc" value="<%= svc %>"><input type="hidden" name="st" value="<%= st %>"><input type="hidden" name="page" value="<%= curPage %>">
              <button class="btn btn--sm" type="submit">결제 확인</button>
            </form>
<% } %>
<% if (canShip) { %>
            <form class="inline-form" action="<%= ctx %>/admin/orders/action" method="post" onsubmit="return confirm('출고 처리할까요?');">
              <input type="hidden" name="_csrf" value="<%= csrf %>"><input type="hidden" name="id" value="<%= o.getOrderId() %>"><input type="hidden" name="action" value="ship">
              <input type="hidden" name="svc" value="<%= svc %>"><input type="hidden" name="st" value="<%= st %>"><input type="hidden" name="page" value="<%= curPage %>">
              <button class="btn btn--navy btn--sm" type="submit">출고 처리</button>
            </form>
<% } %>
<% if ("SHIPPED".equals(o.getStatus()) || "DELIVERING".equals(o.getStatus())) { %>
            처리 완료
<% } %>
<%   int rowStep = OrderStatus.step(o.getStatus()); %>
            <details class="step-test">
              <summary>단계 변경(테스트)</summary>
              <div class="step-test__btns">
<% for (int k = 1; k <= OrderStatus.STEP_COUNT; k++) { %>
                <form class="inline-form" action="<%= ctx %>/admin/orders/action" method="post" onsubmit="return confirm('0<%= k %> <%= OrderStatus.stepName(k) %> 단계로 바꿀까요?');">
                  <input type="hidden" name="_csrf" value="<%= csrf %>"><input type="hidden" name="id" value="<%= o.getOrderId() %>"><input type="hidden" name="action" value="set"><input type="hidden" name="step" value="<%= k %>">
                  <input type="hidden" name="svc" value="<%= svc %>"><input type="hidden" name="st" value="<%= st %>"><input type="hidden" name="page" value="<%= curPage %>">
                  <button class="btn btn--sm<%= k == rowStep ? " btn--navy" : "" %>" type="submit">0<%= k %> <%= OrderStatus.stepName(k) %></button>
                </form>
<% } %>
              </div>
            </details>
          </td>
        </tr>
<% } %>
      </tbody>
    </table>

    <div class="pager">
<% if (curPage > 1) { %>
      <a class="pager__item" href="<%= ctx %>/admin/orders?svc=<%= svc %>&st=<%= st %>&page=<%= curPage - 1 %>" aria-label="이전">&lsaquo;</a>
<% } %>
<% for (int p = 1; p <= totalPages; p++) { %>
      <a class="pager__item<%= p == curPage ? " is-active" : "" %>" href="<%= ctx %>/admin/orders?svc=<%= svc %>&st=<%= st %>&page=<%= p %>"><%= p %></a>
<% } %>
<% if (curPage < totalPages) { %>
      <a class="pager__item" href="<%= ctx %>/admin/orders?svc=<%= svc %>&st=<%= st %>&page=<%= curPage + 1 %>" aria-label="다음">&rsaquo;</a>
<% } %>
    </div>

  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
