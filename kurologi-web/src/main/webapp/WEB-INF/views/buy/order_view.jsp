<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="jp.kurologi.service.OrderStatus,jp.kurologi.web.Html,jp.kurologi.model.BuyOrderDTO,jp.kurologi.model.BuyOrderItemDTO,java.text.DecimalFormat,java.util.List" %>
<%
    String ctx = request.getContextPath();
    // 구매대행(BUY) / 배송대행(SHIP) : 컨트롤러가 request 에 담아 준다.
    // 주소창에서 /buy/... JSP 를 바로 열면 값이 없으므로 구매대행으로 본다.
    String svc = (String) request.getAttribute("svc");
    boolean ship = "SHIP".equals(svc);
    String base = ship ? "/shiporder" : "/buyorder";   // 이 서비스의 컨트롤러 주소
    String svcName = ship ? "배송대행" : "구매대행";
    request.setAttribute("menu", ship ? "ship" : "buy");   // layout.jsp 주 메뉴에서 현재 메뉴 표시
    // 주소창에서 /buy/order_view 로 직접 들어오면 데이터가 없으므로 컨트롤러 주소로 보낸다
    BuyOrderDTO o = (BuyOrderDTO) request.getAttribute("order");
    if (o == null) {
        response.sendRedirect(ctx + base + "/list");
        return;
    }
    boolean wait = "WAIT".equals(o.getStatus());
    DecimalFormat df = new DecimalFormat("#,##0.##");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= ship ? "배송대행 신청상세" : "구매대행 주문상세" %> | KURO Logi</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from stock-order.css */
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

/* ------------------------------------------------- 구매대행 주문내역 (목록 · 상세) */
.flash { margin: 16px 0 0; padding: 12px 16px; font-size: 14px; color: #155724; background: #e8f5ec; border: 1px solid #c3e6cb; border-radius: 4px; }
.flash--error { color: #8a1f11; background: #fdecea; border-color: #f5c6cb; }
.state--wait { color: var(--muted); border: 1px solid #bbb; }
.state--submit { color: var(--teal); border: 1px solid var(--teal); }
.state--received { color: #8a5a00; border: 1px solid #d9a441; }
.state--shipped { color: #fff; background: #37b149; border: 1px solid #37b149; }
.list-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; font-size: 13px; color: var(--body); }
.list-top strong { color: var(--orange); }
a.pager__item { text-decoration: none; margin: 0 2px; }
a.pager__item:hover { background: var(--orange-bg); }
.pager__item.is-active { color: #fff; background: var(--orange); }
.mini-thumb { display: block; width: 56px; height: 56px; object-fit: cover; border: 1px solid var(--line); border-radius: 3px; }
.mini-thumb--none { display: grid; place-items: center; font-size: 20px; color: #bbb; background: var(--fill); }
.item-sub { display: block; margin-top: 3px; font-size: 12px; color: var(--muted); }
.item-sub a { color: var(--blue); }
.data-table .is-right { text-align: right; }
.sum-row td { font-weight: 700; background: #f8f8f8; }
.inline-form { display: inline; }
.btn--danger { background: var(--red); }
.btn--danger:hover { background: #c23a2a; }
.view-head { display: flex; flex-wrap: wrap; gap: 18px; align-items: center; margin-bottom: 18px; padding: 14px 16px; background: #f3f3f3; border: 1px solid var(--line); font-size: 14px; }
.view-head strong { font-size: 16px; color: var(--ink); }
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title"><%= ship ? "배송대행 신청상세" : "구매대행 주문상세" %></h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %><%= base %>/list"><%= ship ? "배송대행 신청내역" : "구매대행 주문내역" %></a></li>
      <li class="breadcrumb__item is-current">주문상세</li>
    </ol>
  </div>
</section>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="flash" /></jsp:include>

<main class="page-body">
  <div class="container">

    <h1 class="sub-title"><span class="sub-title__dash"></span><%= ship ? "배송대행 신청상세" : "구매대행 주문상세" %></h1>

    <div class="view-head">
      <span>주문번호 <strong><%= Html.esc(o.getOrderNo()) %></strong></span>
      <span class="state <%= OrderStatus.css(o.getStatus()) %>"><%= OrderStatus.label(o.getStatus()) %></span>
      <span>결제 <strong><%= OrderStatus.payLabel(o.getStatus(), o.getPayStatus()) %></strong></span>
      <span>접수일시 <%= Html.esc(o.getCreatedAt()) %></span>
      <span>물류센터 <%= Html.esc(o.getCenter()) %></span>
    </div>

    <h2 class="pane-title">받는 사람 정보</h2>
    <table class="form-table">
      <tbody>
        <tr>
          <th>받는 사람</th>
          <td class="is-readonly"><%= Html.esc(o.getRecvNameKo()) %><% if (o.getRecvNameEn() != null && !o.getRecvNameEn().isEmpty()) { %> (<%= Html.esc(o.getRecvNameEn()) %>)<% } %></td>
          <th>휴대전화</th>
          <td class="is-readonly"><%= Html.esc(o.getMobile()) %></td>
        </tr>
        <tr>
          <th>주소</th>
          <td class="is-readonly" colspan="3">
            <% if (o.getPostcode() != null && !o.getPostcode().isEmpty()) { %>[<%= Html.esc(o.getPostcode()) %>] <% } %><%= Html.esc(o.getAddr1()) %> <%= Html.esc(o.getAddr2()) %>
          </td>
        </tr>
        <tr>
          <th>사업자번호</th>
          <td class="is-readonly"><%= Html.esc(o.getBizNo()) %></td>
          <th>배송 요청사항</th>
          <td class="is-readonly"><%= Html.esc(o.getDeliverNote()) %></td>
        </tr>
        <tr>
          <th>부가서비스</th>
          <td class="is-readonly" colspan="3"><%= (o.getAddonOptions() == null || o.getAddonOptions().isEmpty()) ? "선택 없음" : Html.esc(o.getAddonOptions().replace(",", ", ")) %></td>
        </tr>
        <tr>
          <th>물류 요청사항</th>
          <td class="is-readonly" colspan="3"><%= Html.esc(o.getLogisticsNote()) %></td>
        </tr>
        <tr>
          <th>예치금 결제</th>
          <td class="is-readonly" colspan="3"><%= o.isAutoPay() ? "자동결제" : "수동결제" %></td>
        </tr>
<% if (!ship) { %>
        <tr>
          <th><%= wait ? "결제 예정 금액" : "결제 금액" %></th>
          <td class="is-readonly" colspan="3">
<% if (o.getAppliedRate() != null) { %>
            <strong>₩<%= new java.text.DecimalFormat("#,##0").format(o.getTotalKrw()) %></strong>
            <span class="item-sub">총 <%= df.format(o.getTotalYen()) %>엔 x 고시환율 100엔 = <%= new java.text.DecimalFormat("#,##0.00").format(o.getAppliedRate()) %>원 적용<%= wait ? " (접수신청 시점의 환율로 확정됩니다)" : " (접수 시점 환율로 확정)" %></span>
<% } else { %>
            환율 정보 없음
<% } %>
          </td>
        </tr>
<% } %>
      </tbody>
    </table>

    <h2 class="pane-title">상품 정보</h2>
    <table class="data-table">
      <thead>
        <tr>
          <th class="is-narrow">No</th>
          <th style="width:70px">이미지</th>
          <th>상품명</th>
          <th>쇼핑몰 / 트래킹번호</th>
          <th>수량</th>
          <th>단가(¥)</th>
          <th>금액(¥)</th>
        </tr>
      </thead>
      <tbody>
<% for (BuyOrderItemDTO it : o.getItems()) {
       String imgRaw = it.getImageUrl() == null ? "" : it.getImageUrl().trim();
       String img = (imgRaw.toLowerCase().startsWith("http://") || imgRaw.toLowerCase().startsWith("https://")) ? imgRaw : "";   // http(s) 주소만 이미지로 표시
       String link = it.getProductUrl() == null ? "" : it.getProductUrl().trim();
       boolean linkOk = link.toLowerCase().startsWith("http://") || link.toLowerCase().startsWith("https://");
%>
        <tr>
          <td class="is-center"><%= it.getItemNo() %></td>
          <td class="is-center">
<% if (!img.isEmpty()) { %>
            <img class="mini-thumb" src="<%= Html.esc(img) %>" alt="상품 이미지">
<% } else { %>
            <span class="mini-thumb mini-thumb--none" aria-hidden="true">🖼</span>
<% } %>
          </td>
          <td class="is-left">
            <%= Html.esc(it.getItemNameEn()) %>
            <span class="item-sub">
              <% if (it.getBrand() != null && !it.getBrand().isEmpty()) { %>브랜드 <%= Html.esc(it.getBrand()) %> · <% } %>
              <% if (it.getColor() != null && !it.getColor().isEmpty()) { %>색상 <%= Html.esc(it.getColor()) %> · <% } %>
              <% if (it.getItemSize() != null && !it.getItemSize().isEmpty()) { %>사이즈 <%= Html.esc(it.getItemSize()) %> · <% } %>
              <% if (linkOk) { %><a href="<%= Html.esc(link) %>" target="_blank" rel="noopener noreferrer">상품 링크</a><% } %>
            </span>
          </td>
          <td class="is-left">
            <%= Html.esc(it.getShopSite()) %>
            <span class="item-sub">트래킹 <%= (it.getTrackingNo() == null || it.getTrackingNo().isEmpty()) ? "(미입력)" : Html.esc(it.getTrackingNo()) %></span>
          </td>
          <td class="is-center"><%= it.getQty() %></td>
          <td class="is-right"><%= df.format(it.getUnitPrice()) %></td>
          <td class="is-right"><%= df.format(it.getUnitPrice().multiply(java.math.BigDecimal.valueOf(it.getQty()))) %></td>
        </tr>
<% } %>
        <tr class="sum-row">
          <td colspan="4" class="is-center">합계</td>
          <td class="is-center"><%= o.getTotalQty() %></td>
          <td></td>
          <td class="is-right"><%= df.format(o.getTotalYen()) %></td>
        </tr>
      </tbody>
    </table>

    <div class="btn-row">
      <a class="btn" href="<%= ctx %><%= base %>/list">목록</a>
<% if (wait) { %>
      <a class="btn btn--navy" href="<%= ctx %><%= base %>/form?id=<%= o.getOrderId() %>">수정</a>
      <form class="inline-form" action="<%= ctx %><%= base %>/delete" method="post" onsubmit="return confirm('이 주문을 삭제할까요? 삭제하면 되돌릴 수 없습니다.');">
        <input type="hidden" name="_csrf" value="<%= jp.kurologi.web.Session.csrfToken(request) %>">
        <input type="hidden" name="id" value="<%= o.getOrderId() %>">
        <button class="btn btn--danger" type="submit">삭제</button>
      </form>
<% } %>
    </div>

  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
