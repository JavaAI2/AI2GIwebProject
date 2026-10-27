<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="jp.kurologi.web.Html,jp.kurologi.web.Session,jp.kurologi.model.StockItemDTO,jp.kurologi.model.StockOrderDTO,java.text.DecimalFormat,java.util.List" %>
<%
    String ctx = request.getContextPath();
    request.setAttribute("menu", "buy");   // layout.jsp 주 메뉴에서 현재 메뉴 표시

    // 주소창에서 /buy/stock_order 로 직접 들어오면 데이터가 없으므로 컨트롤러 주소로 보낸다
    List<StockItemDTO> items = (List<StockItemDTO>) request.getAttribute("stockItems");
    List<StockOrderDTO> orders = (List<StockOrderDTO>) request.getAttribute("stockOrders");
    if (items == null) {
        response.sendRedirect(ctx + "/stock/form");
        return;
    }
    DecimalFormat df = new DecimalFormat("#,##0");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>재고구매신청등록 | KURO Logi</title>
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

/* ------------------------------------------------- 재고구매신청 (DB 연결 추가분) */
.flash { margin: 16px 0 0; padding: 12px 16px; font-size: 14px; color: #155724; background: #e8f5ec; border: 1px solid #c3e6cb; border-radius: 4px; }
.flash--error { color: #8a1f11; background: #fdecea; border-color: #f5c6cb; }
.data-table .is-right { text-align: right; }
.data-table tr.is-soldout td { color: #aaa; }
.stock-pick { cursor: pointer; }
.field-hint { margin-top: 4px; font-size: 12px; color: var(--muted); }
.add-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 8px; }
.add-grid label { display: block; margin-bottom: 4px; font-size: 12px; font-weight: 700; color: var(--ink); }
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">재고구매신청등록</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/buy/order_form">구매대행</a></li>
      <li class="breadcrumb__item is-current">재고구매신청등록</li>
    </ol>
  </div>
</section>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="flash" /></jsp:include>

<main class="page-body">
  <div class="container">

    <h1 class="sub-title"><span class="sub-title__dash"></span>재고구매신청등록</h1>

    <div class="info-box">
      <p>재고관리 중인 상품을 구매대행으로 신청합니다. 재고번호를 선택하면 상품 정보가 자동으로 채워집니다.</p>
    </div>

    <form id="applyForm" action="<%= ctx %>/stock/apply" method="post" autocomplete="off">
    <input type="hidden" name="_csrf" value="<%= Session.csrfToken(request) %>">

    <h2 class="pane-title">상품 선택</h2>

    <table class="data-table">
      <thead>
        <tr>
          <th class="is-narrow">선택</th>
          <th>재고번호</th>
          <th>상품명</th>
          <th>옵션</th>
          <th>재고수량</th>
          <th>판매가(₩)</th>
          <th>등록일</th>
        </tr>
      </thead>
      <tbody>
<% if (items.isEmpty()) { %>
        <tr><td class="data-table__empty" colspan="7">재고로 등록된 상품이 없습니다. 아래 '재고 상품 등록'에서 먼저 등록해 주세요.</td></tr>
<% } %>
<% for (StockItemDTO s : items) {
       boolean soldout = s.getQty() <= 0;
%>
        <tr<%= soldout ? " class=\"is-soldout\"" : "" %>>
          <td class="is-center"><input class="stock-pick" type="radio" name="stockId" value="<%= s.getStockId() %>"
              data-qty="<%= s.getQty() %>" data-price="<%= s.getPrice() %>" aria-label="<%= Html.esc(s.getStockNo()) %> 선택"<%= soldout ? " disabled" : "" %>></td>
          <td class="is-center"><%= Html.esc(s.getStockNo()) %></td>
          <td class="is-left"><%= Html.esc(s.getItemName()) %></td>
          <td class="is-center"><%= Html.esc(s.getOptionName()) %></td>
          <td class="is-center"><%= soldout ? "품절" : String.valueOf(s.getQty()) %></td>
          <td class="is-right"><%= df.format(s.getPrice()) %></td>
          <td class="is-center"><%= Html.esc(s.getCreatedAt()) %></td>
        </tr>
<% } %>
      </tbody>
    </table>

    <h2 class="pane-title">신청 정보</h2>

    <table class="form-table">
      <tbody>
        <tr>
          <th>받는 사람</th>
          <td><input class="input" type="text" id="recvName" name="recvName" maxlength="60" aria-label="받는 사람"></td>
          <th>휴대전화</th>
          <td><input class="input" type="tel" id="mobile" name="mobile" maxlength="30" aria-label="휴대전화"></td>
        </tr>
        <tr>
          <th>주소</th>
          <td colspan="3">
            <div style="display:flex;gap:6px;max-width:320px;margin-bottom:6px">
              <input class="input" type="text" id="postcode" name="postcode" placeholder="우편번호" aria-label="우편번호" maxlength="10" readonly>
              <button class="btn btn--sm" type="button" id="btnPostcode" style="white-space:nowrap">우편번호 검색</button>
            </div>
            <input class="input" type="text" id="addr1" name="addr1" placeholder="주소" aria-label="주소" maxlength="200" readonly>
            <input class="input" type="text" id="addr2" name="addr2" placeholder="상세주소" aria-label="상세주소" maxlength="200" style="margin-top:6px">
          </td>
        </tr>
        <tr>
          <th>배송 요청사항</th>
          <td colspan="3"><input class="input" type="text" id="deliverNote" name="deliverNote" maxlength="200" aria-label="배송 요청사항"></td>
        </tr>
        <tr>
          <th>신청 수량</th>
          <td>
            <input class="input" type="number" id="qty" name="qty" value="1" min="1" aria-label="신청 수량">
            <div class="field-hint" id="qtyHint">상품을 선택해 주세요.</div>
          </td>
          <th>예상 금액</th>
          <td class="is-readonly" id="expected">₩0</td>
        </tr>
      </tbody>
    </table>

    <div class="btn-row">
      <button class="btn" type="reset" id="btnReset">취소</button>
      <button class="btn btn--navy" type="submit">신청하기</button>
    </div>

    </form>

    <h2 class="pane-title" style="margin-top:44px">재고 상품 등록</h2>

    <form id="addForm" action="<%= ctx %>/stock/add" method="post" autocomplete="off">
      <input type="hidden" name="_csrf" value="<%= Session.csrfToken(request) %>">
      <div class="add-grid">
        <div><label for="addName">상품명 *</label><input class="input" id="addName" name="itemName" type="text" maxlength="200"></div>
        <div><label for="addOption">옵션</label><input class="input" id="addOption" name="optionName" type="text" maxlength="100"></div>
        <div><label for="addQty">재고수량 *</label><input class="input" id="addQty" name="qty" type="number" min="1" value="1"></div>
        <div><label for="addPrice">판매가(₩) *</label><input class="input" id="addPrice" name="price" type="number" min="0" value="0"></div>
      </div>
      <div class="btn-row" style="justify-content:flex-start;margin-top:12px">
        <button class="btn btn--navy" type="submit">재고 등록</button>
      </div>
    </form>

    <h2 class="pane-title" style="margin-top:44px">재고구매신청 내역 (최근 10건)</h2>

    <table class="data-table">
      <thead>
        <tr>
          <th>신청번호</th>
          <th>상품명</th>
          <th>수량</th>
          <th>금액(₩)</th>
          <th>받는 사람</th>
          <th>신청일시</th>
        </tr>
      </thead>
      <tbody>
<% if (orders == null || orders.isEmpty()) { %>
        <tr><td class="data-table__empty" colspan="6">신청 내역이 없습니다.</td></tr>
<% } else { for (StockOrderDTO o : orders) { %>
        <tr>
          <td class="is-center"><%= Html.esc(o.getOrderNo()) %></td>
          <td class="is-left"><%= Html.esc(o.getItemName()) %></td>
          <td class="is-center"><%= o.getQty() %></td>
          <td class="is-right"><%= df.format(o.getTotalPrice()) %></td>
          <td class="is-center"><%= Html.esc(o.getRecvName()) %></td>
          <td class="is-center"><%= Html.esc(o.getCreatedAt()) %></td>
        </tr>
<% } } %>
      </tbody>
    </table>

  </div>
</main>

<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
(function () {
  var form = document.getElementById('applyForm');
  var qty = document.getElementById('qty');

  function selected() { return form.querySelector('input[name="stockId"]:checked'); }

  // 선택한 재고에 맞춰 수량 한도 안내와 예상 금액(판매가 x 수량)을 갱신한다
  function refresh() {
    var r = selected();
    var hint = document.getElementById('qtyHint');
    var n = parseInt(qty.value, 10);
    if (isNaN(n) || n < 0) n = 0;
    if (!r) { hint.textContent = '상품을 선택해 주세요.'; document.getElementById('expected').textContent = '₩0'; return; }
    var max = parseInt(r.getAttribute('data-qty'), 10);
    var price = parseInt(r.getAttribute('data-price'), 10);
    qty.max = max;
    hint.textContent = '신청 가능 수량 : 최대 ' + max + '개';
    document.getElementById('expected').textContent = '₩' + (price * n).toLocaleString();   // 화면 표시용. 저장할 때는 서버가 다시 계산
  }

  form.addEventListener('change', function (e) {
    if (e.target.name === 'stockId') { qty.value = 1; }
    refresh();
  });
  qty.addEventListener('input', refresh);
  document.getElementById('btnReset').addEventListener('click', function () { setTimeout(refresh, 0); });

  // 우편번호 검색 (Daum 우편번호 서비스)
  document.getElementById('btnPostcode').addEventListener('click', function () {
    if (typeof daum === 'undefined') { alert('우편번호 서비스를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.'); return; }
    new daum.Postcode({
      oncomplete: function (d) {
        document.getElementById('postcode').value = d.zonecode;
        document.getElementById('addr1').value = d.roadAddress || d.address;
        document.getElementById('addr2').focus();
      }
    }).open();
  });

  // 전송 전 검사 (서버에서도 같은 검사를 다시 한다)
  form.addEventListener('submit', function (e) {
    var r = selected(), msg = '';
    var v = function (id) { return document.getElementById(id).value.trim(); };
    if (!r) msg = '신청할 재고 상품을 선택해 주세요.';
    else if (!(parseInt(qty.value, 10) >= 1)) msg = '신청 수량은 1 이상으로 입력해 주세요.';
    else if (parseInt(qty.value, 10) > parseInt(r.getAttribute('data-qty'), 10)) msg = '재고수량(' + r.getAttribute('data-qty') + '개)을 넘을 수 없습니다.';
    else if (!v('recvName')) msg = '받는 사람을 입력해 주세요.';
    else if (!v('mobile')) msg = '휴대전화를 입력해 주세요.';
    else if (!v('postcode') || !v('addr1')) msg = '우편번호 검색으로 주소를 입력해 주세요.';
    else if (!v('addr2')) msg = '상세주소를 입력해 주세요.';
    if (msg) { e.preventDefault(); alert(msg); }
  });

  refresh();
})();
</script>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
