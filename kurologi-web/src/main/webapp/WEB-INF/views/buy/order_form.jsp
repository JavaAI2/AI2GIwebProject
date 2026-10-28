<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="jp.kurologi.web.Session,jp.kurologi.web.Html,jp.kurologi.model.ExchangeRate,jp.kurologi.service.ExchangeRateService,jp.kurologi.model.BuyOrderDTO,jp.kurologi.model.BuyOrderItemDTO,java.util.ArrayList,java.util.Arrays,java.util.HashSet,java.util.List,java.util.Set" %>
<%
    String ctx = request.getContextPath();
    // 구매대행(BUY) / 배송대행(SHIP) : 컨트롤러가 request 에 담아 준다.
    // 주소창에서 /buy/... JSP 를 바로 열면 값이 없으므로 구매대행으로 본다.
    String svc = (String) request.getAttribute("svc");
    boolean ship = "SHIP".equals(svc);
    String base = ship ? "/shiporder" : "/buyorder";   // 이 서비스의 컨트롤러 주소
    String svcName = ship ? "배송대행" : "구매대행";
    request.setAttribute("menu", ship ? "ship" : "buy");   // layout.jsp 주 메뉴에서 현재 메뉴 표시
    ExchangeRate rate = ExchangeRateService.current();   // 오늘의 환율 (없으면 null)
    java.text.DecimalFormat rateFmt = new java.text.DecimalFormat("#,##0.00");

    // 컨트롤러가 담아 준 주문 정보 (formOrder)
    //   - 없음            : 새 주문서(빈 화면)
    //   - orderId 있음    : 접수대기 주문 수정 (저장된 값으로 채움)
    //   - 검사 실패       : 방금 입력한 값을 그대로 다시 채움
    BuyOrderDTO fo = (BuyOrderDTO) request.getAttribute("formOrder");
    boolean editing = fo != null && fo.getOrderId() > 0;
    if (fo == null) fo = new BuyOrderDTO();

    Set<String> addonSet = new HashSet<String>();   // 체크해 둘 부가서비스
    if (fo.getAddonOptions() != null && !fo.getAddonOptions().isEmpty()) {
        addonSet.addAll(Arrays.asList(fo.getAddonOptions().split(",")));
    }

    List<BuyOrderItemDTO> its = new ArrayList<BuyOrderItemDTO>(fo.getItems());
    if (its.isEmpty()) its.add(new BuyOrderItemDTO());   // 상품 칸은 최소 1개
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= ship ? "배송대행 신청" : "구매대행 주문서등록" %> | KURO Logi</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from order-form.css */
/* ==========================================================================
   KURO Logi — 공통 뼈대 (상단 바 · 헤더 · 페이지 제목 · 푸터)

   바꾸고 싶은 값은 :root 한 곳만 고치면 됩니다.
   순수 CSS · Bootstrap 클래스 없음 · 데스크톱 고정폭
   ========================================================================== */

:root {
  --teal:      #159692;
  --teal-dark: #107a77;
  --blue:      #107abd;
  --navy:      #1e3354;   /* 제출 버튼 */
  --orange:    #ff7000;
  --red:       #dd4b39;
  --pink-bg:   #fdeef3;   /* 안내 박스 (분홍) */
  --blue-bg:   #e4f0f9;   /* 섹션 머리글 */

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

/* --------------------------------------------------------------- 푸터 */

.site-footer { margin-top: 30px; background: #333; color: #ccc; }
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

/* ============================================================
   본문 공통
   ============================================================ */

.page-body { padding: 24px 0 40px; }

/* 제목 */
.form-title {
  margin: 0 0 24px;
  font-size: 24px;
  font-weight: 700;
  color: var(--ink);
  text-align: center;
}

/* 섹션 (» 표시가 있는 파란 머리글) */
.form-section {
  margin-bottom: 20px;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  background: #fff;
}

.form-section__head {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 14px;
  font-size: 15px;
  font-weight: 700;
  color: #2b6a94;
  background: var(--blue-bg);
  border-bottom: 1px solid var(--line);
}

.form-section__head::before {
  content: '»';
  font-weight: 700;
}

.form-section__body { padding: 16px; }

/* 라벨 + 입력 한 줄 */
.field-row {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 14px;
}

.field-row__label {
  flex: 0 0 150px;
  padding-top: 8px;
  font-size: 14px;
  font-weight: 700;
  color: var(--ink);
}

.field-row__body { flex: 1 1 auto; min-width: 0; }

/* 2열 배치가 필요한 경우 */
.field-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px 14px;
}

.field-grid--3 { grid-template-columns: repeat(3, 1fr); }

.field { margin-bottom: 10px; }

.field__label {
  display: block;
  margin-bottom: 4px;
  font-size: 12px;
  color: var(--muted);
}

/* 입력 요소 */
.input,
.select,
.textarea {
  width: 100%;
  padding: 8px 10px;
  font-family: inherit;
  font-size: 13px;
  line-height: 1.5;
  color: #495057;
  background: #fff;
  border: 1px solid var(--line);
  border-radius: var(--radius);
}

.input:focus,
.select:focus,
.textarea:focus { outline: none; border-color: var(--teal); }

.input::placeholder,
.textarea::placeholder { color: #aaa; }

/* 필수 항목 (빨간 테두리) */
.input--required { border-color: var(--red); }

.textarea { min-height: 74px; resize: vertical; }

.input--inline { display: inline-block; width: auto; }

/* 안내 문구 */
.note {
  margin: 4px 0 10px;
  font-size: 12px;
  line-height: 1.7;
  color: var(--body);
}

.note--red { color: var(--red); }
.note--gray { color: var(--muted); }

.note-list { margin: 0; padding: 0; list-style: none; }
.note-list li { padding: 2px 0 2px 10px; font-size: 12px; line-height: 1.7; }
.note-list li::before { content: '* '; margin-left: -10px; }

/* 분홍 안내 박스 */
.info-box {
  margin: 16px 0;
  padding: 14px 16px;
  font-size: 13px;
  line-height: 1.9;
  color: var(--body);
  background: var(--pink-bg);
  border-radius: var(--radius);
}

.info-box p { margin: 6px 0; }
.info-box p:first-child { margin-top: 0; }
.info-box p:last-child { margin-bottom: 0; }

/* 버튼 */
.btn {
  display: inline-block;
  padding: 9px 18px;
  font-family: inherit;
  font-size: 13px;
  font-weight: 700;
  line-height: 1.5;
  text-align: center;
  color: #fff;
  background: #6f6f6f;
  border: 0;
  border-radius: var(--radius);
  cursor: pointer;
  white-space: nowrap;
}

.btn:hover { color: #fff; background: #5c5c5c; }

.btn--navy { background: var(--navy); }
.btn--navy:hover { background: #16263f; }

.btn--sm { padding: 6px 12px; font-size: 12px; }

.btn-row {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 8px;
  margin-top: 20px;
}

.btn-row--left { justify-content: flex-start; }

/* 두 칸 버튼 (다운로드 등) */
.btn-pair {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 12px;
}

.btn-pair .btn { padding: 12px; }

/* 파일 선택 */
.file-box {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 16px;
  font-size: 13px;
  color: var(--body);
  background: #fff;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  cursor: pointer;
}

.file-box:hover { border-color: var(--teal); }

/* 표 형태 폼 (부가서비스) */
.opt-table { width: 100%; border-collapse: collapse; }

.opt-table th,
.opt-table td {
  padding: 12px 10px;
  font-size: 13px;
  text-align: left;
  vertical-align: top;
  border: 1px solid var(--line);
}

.opt-table th {
  width: 130px;
  font-weight: 700;
  color: var(--ink);
  text-align: center;
  vertical-align: middle;
  background: var(--fill);
}

.opt-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px 16px;
}

/* 체크박스 한 줄 */
.check {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  font-size: 13px;
  line-height: 1.6;
  color: var(--body);
  cursor: pointer;
}

.check input { flex: 0 0 auto; margin-top: 3px; }

.check .price { color: var(--red); }
.check .req { color: var(--red); font-size: 12px; }

/* 동의 항목 (25문항) */
.agree-list { margin: 0; padding: 0; list-style: none; }

.agree-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  font-size: 13px;
  line-height: 1.6;
  border-bottom: 1px solid var(--line-soft);
}

.agree-item:last-child { border-bottom: 0; }
.agree-item__text { flex: 1 1 auto; color: var(--body); }

.agree-item__arrow {
  flex: 0 0 auto;
  font-size: 12px;
  color: var(--muted);
}

.agree-all {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 10px;
  padding: 14px;
  font-size: 15px;
  font-weight: 700;
  color: var(--red);
  background: var(--fill);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  cursor: pointer;
}

/* 상품 이미지 자리 */
.thumb {
  width: 130px;
  height: 130px;
  display: grid;
  place-items: center;
  font-size: 34px;
  color: #bbb;
  background: var(--fill);
  border: 1px solid var(--line);
  border-radius: var(--radius);
}

/* 뱃지 */
.badge {
  display: inline-block;
  padding: 8px 16px;
  font-size: 13px;
  font-weight: 700;
  color: #e05a7a;
  background: #fdeef3;
  border-radius: var(--radius);
}

/* 라디오 줄 */
.radio-row { display: flex; gap: 24px; font-size: 13px; }
.radio-row label { display: flex; align-items: center; gap: 5px; cursor: pointer; }

/* ------------------------------------------------- 서버 알림 · 상품 블록 (DB 연결 추가분) */
.flash {
  margin: 16px 0 0;
  padding: 12px 16px;
  font-size: 14px;
  color: #155724;
  background: #e8f5ec;
  border: 1px solid #c3e6cb;
  border-radius: 4px;
}
.flash--error { color: #8a1f11; background: #fdecea; border-color: #f5c6cb; }
.thumb { position: relative; overflow: hidden; }
.thumb img { display: block; width: 100%; height: 100%; object-fit: cover; }
.item-block + .item-block { margin-top: 28px; padding-top: 18px; border-top: 1px dashed var(--line); }
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title"><%= ship ? "배송대행 신청" : "구매대행 주문서등록" %></h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %><%= base %>/list"><%= svcName %></a></li>
      <li class="breadcrumb__item is-current"><%= ship ? "배송대행 신청" : "구매대행 주문서등록" %></li>
    </ol>
  </div>
</section>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="flash" /></jsp:include>

<main class="page-body">
  <div class="container">

    <form id="orderForm" action="<%= ctx %><%= base %>/save" method="post" autocomplete="off">
    <input type="hidden" name="_csrf" value="<%= Session.csrfToken(request) %>">

    <h1 class="form-title"><%= editing ? (ship ? "배송대행 신청 수정" : "구매대행 주문서수정") : (ship ? "배송대행 신청" : "구매대행 주문서등록") %></h1>
<% if (editing) { %>
    <input type="hidden" name="orderId" value="<%= fo.getOrderId() %>">
    <div class="info-box"><p>주문번호 <strong><%= Html.esc(fo.getOrderNo()) %></strong> 을(를) 수정하고 있습니다. 접수대기 상태에서만 수정할 수 있습니다.</p></div>
<% } %>

    <!-- ============ 물류센터 및 운송방식 ============ -->
    <section class="form-section">
      <h2 class="form-section__head">물류센터 및 운송방식</h2>
      <div class="form-section__body">
        <p class="note" style="margin:0">위해 / LCL 사업자(월/수/금)</p>
      </div>
    </section>

    <!-- ============ 받는 사람 정보 ============ -->
    <section class="form-section">
      <h2 class="form-section__head">받는 사람 정보</h2>
      <div class="form-section__body">

        <div class="field-row">
          <span class="field-row__label">받는 사람</span>
          <div class="field-row__body">
            <div class="field-grid">
              <div class="field">
                <label class="field__label" for="recvKo">한글</label>
                <input class="input" id="recvKo" name="recvNameKo" value="<%= Html.esc(fo.getRecvNameKo()) %>" type="text">
              </div>
              <div class="field">
                <label class="field__label" for="recvEn">영문</label>
                <input class="input" id="recvEn" name="recvNameEn" value="<%= Html.esc(fo.getRecvNameEn()) %>" type="text">
              </div>
            </div>
          </div>
        </div>

        <div class="field-row">
          <span class="field-row__label">주소</span>
          <div class="field-row__body">
            <div class="field-grid field-grid--3">
              <div class="field">
                <label class="field__label" for="postcode">우편번호</label>
                <input class="input" id="postcode" name="postcode" value="<%= Html.esc(fo.getPostcode()) %>" type="text">
              </div>
              <div class="field" style="padding-top:20px">
                <button class="btn btn--sm" type="button" id="btnPostcode">우편번호 검색</button>
                <button class="btn btn--sm" type="button">주소록</button>
              </div>
              <div class="field"></div>
            </div>
            <div class="field">
              <label class="field__label" for="addr1">주소</label>
              <input class="input" id="addr1" name="addr1" value="<%= Html.esc(fo.getAddr1()) %>" type="text">
            </div>
            <div class="field">
              <label class="field__label" for="addr2">상세주소</label>
              <input class="input input--required" id="addr2" name="addr2" value="<%= Html.esc(fo.getAddr2()) %>" type="text">
            </div>
            <p class="note note--red">* 도로명 주소를 써주십시오. 지번 주소 기재 시 통관/세관에서 오류로 분류시켜 통관지연이 될 수 있습니다.</p>
            <p class="note note--red">* 세관신고 시 상세주소 필수기재입니다.</p>
          </div>
        </div>

        <div class="field-row">
          <span class="field-row__label">사업자</span>
          <div class="field-row__body">
            <p class="note">* 사업자통관의 경우 받는 사람 정보에 사업자등록증상 상호명을 입력 부탁드립니다.</p>
            <div class="field-grid">
              <div class="field">
                <label class="field__label" for="bizNo">사업자번호 (10자리 숫자만 입력)</label>
                <input class="input" id="bizNo" name="bizNo" value="<%= Html.esc(fo.getBizNo()) %>" type="text" maxlength="10">
              </div>
              <div class="field">
                <label class="field__label" for="mobile">휴대전화</label>
                <input class="input" id="mobile" name="mobile" value="<%= Html.esc(fo.getMobile()) %>" type="tel">
              </div>
            </div>
            <button class="btn btn--navy btn--sm" type="button">개인통관부호유효체크</button>
            <p class="note">* 스카이프 등 브라우저 관련된 프로그램이 켜져있으면, 끄고 진행하십시오.</p>
          </div>
        </div>

        <div class="field-row">
          <span class="field-row__label">배송 요청사항</span>
          <div class="field-row__body">
            <input class="input" id="deliverNote" name="deliverNote" value="<%= Html.esc(fo.getDeliverNote()) %>" type="text">
            <p class="note">* 국내 배송기사 분께 전달하고자 하는 요청사항을 남겨주세요 (예: 부재 시 휴대폰으로 연락주세요)</p>
          </div>
        </div>

      </div>
    </section>

    <!-- ============ 해외배송규정 안내 및 동의 ============ -->
    <section class="form-section">
      <h2 class="form-section__head">해외배송규정 안내 및 동의</h2>
      <div class="form-section__body">
        <ul class="agree-list">
        <li class="agree-item">
          <input type="checkbox" id="agree1" name="agree" value="1">
          <label class="agree-item__text" for="agree1">1. 물품파손 규정에 대한 안내사항에 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree2" name="agree" value="2">
          <label class="agree-item__text" for="agree2">2. 합배송을 원하시면 한개 주문서에 합배송 하실려는 트래킹번호 전부 기입해 주셔야 하며, 묶음/나눔배송은 최대 1회까지 무료입니다. 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree3" name="agree" value="3">
          <label class="agree-item__text" for="agree3">3. 제품품목수 20건 제한에 동의 하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree4" name="agree" value="4">
          <label class="agree-item__text" for="agree4">4. 현지 트래킹번호가 모(母)번호 자(子)번호로 나뉘어져 있는 경우, 모(母)번호 기준으로 입출고 작업을 해드리고 있습니다. 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree5" name="agree" value="5">
          <label class="agree-item__text" for="agree5">5. 목록통관취하, 통관 보류 및 통관불가에 대한 사항에 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree6" name="agree" value="6">
          <label class="agree-item__text" for="agree6">6. 검수옵션 및 사진촬영서비스 내용에 대해 동의하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree7" name="agree" value="7">
          <label class="agree-item__text" for="agree7">7. 대형화물 또는 이형화물의 멀티박스/폴리백 포장에 대해 동의하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree8" name="agree" value="8">
          <label class="agree-item__text" for="agree8">8. 화물배송변경으로 인하여 차분요금이 발생할수 있습니다. 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree9" name="agree" value="9">
          <label class="agree-item__text" for="agree9">9. 추가촬영, CCTV확인 작업시 비용이 발생합니다. 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree10" name="agree" value="10">
          <label class="agree-item__text" for="agree10">10. 미등록 및 통관에 문제가되는 사운품 자동폐기에대해 동의하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree11" name="agree" value="11">
          <label class="agree-item__text" for="agree11">11. 포장요청 단계부터는 제품의 묶음배송 및 나눔배송 또는 사진촬영 및 검수요청, 내부 포장요청, 반품요청 등 어떠한 요청도 불가능 합니다. 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree12" name="agree" value="12">
          <label class="agree-item__text" for="agree12">12. 입고가 완료된 화물은 해운 ↔ 항공 ↔ LCL 사업자통관 서비스 변경이 불가합니다 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree13" name="agree" value="13">
          <label class="agree-item__text" for="agree13">13. 도착화물의 보관일수는 30일이며, 노데이터 정책에 동의하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree14" name="agree" value="14">
          <label class="agree-item__text" for="agree14">14. 해운/항공화물의 부피무게 안내사항에 동의하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree15" name="agree" value="15">
          <label class="agree-item__text" for="agree15">15. 무검수가 아닌경우 포장 옵션은 당사 현지 현장직원의 판단하에 변경 진행될 수 있습니다. 이에 동의하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree16" name="agree" value="16">
          <label class="agree-item__text" for="agree16">16. 실제화물 정보 허위입력, 중국 선적 금지품목은 주문서 접수를 금지합니다. 동의 하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree17" name="agree" value="17">
          <label class="agree-item__text" for="agree17">17. 사업자통관 및 LCL사업자통관 안내사항에 동의 하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree18" name="agree" value="18">
          <label class="agree-item__text" for="agree18">18. 재고를 두고 사용하시는 경우 수수료는 없지만 포장지 포장재배용이 청구되실수 있습니다. 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree19" name="agree" value="19">
          <label class="agree-item__text" for="agree19">19. 홈페이지 이용후기에 작성하는 글과 사진은 당사에서 마케팅 목적으로 사용할 수 있습니다. 이에 동의하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree20" name="agree" value="20">
          <label class="agree-item__text" for="agree20">20. 나눔배송&물품배송은 각 1회에 미 나눔상품의 합배송을 엄격히 금지합니다. 이에 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree21" name="agree" value="21">
          <label class="agree-item__text" for="agree21">21. 무검수+중국택배원박스 선택시 트래킹하나만 있는 주문서이면 임시저장(검수대기)상태일지라도 도착한 그대로 포장이 완료되어 결제대기 단계로 이동될 수 있습니다. 이에 동의하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree22" name="agree" value="22">
          <label class="agree-item__text" for="agree22">22. 사업자검수/나눔포장은 사진촬영비용과 수량체크비용이 발생됩니다. 이에 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree23" name="agree" value="23">
          <label class="agree-item__text" for="agree23">23. 미숙지로 인한 불이익이 발생하는 경우 보상처리는 불가합니다. 이에 동의하십니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree24" name="agree" value="24">
          <label class="agree-item__text" for="agree24">24. 보험서비스 제공으로 인한 개인정보 보험사 제공에 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        <li class="agree-item">
          <input type="checkbox" id="agree25" name="agree" value="25">
          <label class="agree-item__text" for="agree25">25. 이용안내(수입금지품목) 및 공지사항내 '상품명 정확한 신고 및 위반 시 책임 안내'를 확인하였으며 이에 동의하시겠습니까?</label>
          <span class="agree-item__arrow">▾</span>
        </li>
        </ul>
        <label class="agree-all">
          <input type="checkbox" id="agreeAll"> 전체 동의하기
        </label>
      </div>
    </section>

    <!-- ============ 상품정보 입력 ============ -->
    <section class="form-section">
      <h2 class="form-section__head">상품정보 입력</h2>
      <div class="form-section__body">

        <div id="itemList">
<%
  for (int idx = 0; idx < its.size(); idx++) {
    BuyOrderItemDTO it = its.get(idx);
    String vQty = it.getQty() > 0 ? String.valueOf(it.getQty()) : "1";
    String vPrice = it.getUnitPrice() != null ? it.getUnitPrice().toPlainString() : "0.00";
%>
<div class="item-block">
        <p class="note note--red" style="font-weight:700">상품 <span class="item-no"><%= idx + 1 %></span> &nbsp;* 적색 테두리 필수항목</p>

        <div class="btn-row btn-row--left" style="margin:10px 0 18px">
          <button class="btn" type="button">등록상품 불러오기</button>
          <button class="btn" type="button">상품URL 가져오기</button>
          <button class="btn" type="button">오더내역복사</button>
          <button class="btn" type="button" data-act="copy">↻ 복사</button>
          <button class="btn" type="button" data-act="add">⊞ 추가</button>
          <button class="btn" type="button" data-act="del">␡ 삭제</button>
        </div>

        <div style="display:flex;gap:16px;align-items:flex-start">
          <div>
            <div class="thumb">
              <span class="thumb__ph" aria-hidden="true">🖼</span>
              <img class="thumb__img" alt="상품 이미지 미리보기" style="display:none">
            </div>
            <input type="file" class="img-file" accept="image/jpeg,image/png,image/gif,image/webp" style="display:none">
            <button class="btn btn--navy btn--sm" type="button" data-act="img" style="margin-top:8px">이미지 업로드</button>
          </div>

          <div style="flex:1 1 auto;min-width:0">
            <div class="field-grid">
              <div class="field">
                <label class="field__label" for="shopSite">쇼핑몰 사이트</label>
                <input class="input" id="shopSite" name="itemShopSite" value="<%= Html.esc(it.getShopSite()) %>" type="text">
              </div>
              <div class="field">
                <label class="field__label" for="brand">브랜드</label>
                <input class="input" id="brand" name="itemBrand" value="<%= Html.esc(it.getBrand()) %>" type="text">
              </div>
            </div>

            <div class="field-grid">
              <div class="field">
                <label class="field__label" for="shopOrder">쇼핑몰 오더번호</label>
                <input class="input" id="shopOrder" name="itemShopOrderNo" value="<%= Html.esc(it.getShopOrderNo()) %>" type="text">
              </div>
              <div class="field">
                <label class="field__label" for="tracking">트래킹번호 (Tracking No)</label>
                <input class="input input--required" id="tracking" name="itemTrackingNo" value="<%= Html.esc(it.getTrackingNo()) %>" type="text">
              </div>
            </div>
            <p class="note note--red">* 트래킹번호 없을 경우 '마이페이지' 주문신청 현황에서 입력</p>

            <div class="field-grid">
              <div class="field">
                <label class="field__label">통관품목</label>
                <button class="btn btn--sm" type="button">통관품목 검색</button>
              </div>
              <div class="field">
                <label class="field__label">영문명</label>
                <label class="check"><input type="checkbox" name="itemNameEnDirect" value="<%= idx %>"<%= Html.checked(it.isNameEnDirect()) %>> 영문명 직접 기재</label>
              </div>
            </div>

            <div class="field">
              <label class="field__label" for="nameEn">상품명 영문</label>
              <input class="input input--required" id="nameEn" name="itemNameEn" value="<%= Html.esc(it.getItemNameEn()) %>" type="text">
            </div>
            <p class="note">* 통관품목 검색 후 없는 품목의 경우 1:1문의 부탁드립니다.</p>
            <p class="note">* 통관품목 검색하신 상품명과 HS코드 기준으로 세관신고되오니 품목 상이에 유의 부탁드립니다. (직접 기재형 신고아님)</p>
          </div>
        </div>

        <div class="field-grid" style="margin-top:16px">
          <div class="field">
            <label class="field__label" for="qty">수량</label>
            <input class="input" id="qty" name="itemQty" type="number" value="<%= vQty %>" min="1">
          </div>
          <div class="field">
            <label class="field__label" for="price">단가 (¥)</label>
            <input class="input" id="price" name="itemUnitPrice" type="text" value="<%= vPrice %>">
          </div>
          <div class="field">
            <label class="field__label" for="color">색상</label>
            <input class="input" id="color" name="itemColor" value="<%= Html.esc(it.getColor()) %>" type="text">
          </div>
          <div class="field">
            <label class="field__label" for="size">사이즈</label>
            <input class="input" id="size" name="itemSize" value="<%= Html.esc(it.getItemSize()) %>" type="text">
          </div>
          <div class="field">
            <label class="field__label" for="prodUrl">상품URL</label>
            <input class="input" id="prodUrl" name="itemProductUrl" value="<%= Html.esc(it.getProductUrl()) %>" type="text">
          </div>
          <div class="field">
            <label class="field__label" for="imgUrl">이미지URL</label>
            <input class="input" id="imgUrl" name="itemImageUrl" value="<%= Html.esc(it.getImageUrl()) %>" type="text">
          </div>
          <div class="field">
            <label class="field__label" for="market">오픈마켓 이름</label>
            <input class="input" id="market" name="itemMarketName" value="<%= Html.esc(it.getMarketName()) %>" type="text">
          </div>
          <div class="field">
            <label class="field__label" for="marketOrder">오픈마켓 주문번호</label>
            <input class="input" id="marketOrder" name="itemMarketOrderNo" value="<%= Html.esc(it.getMarketOrderNo()) %>" type="text">
          </div>
          <div class="field">
            <label class="field__label" for="marketPrice">오픈마켓 판매금액</label>
            <input class="input" id="marketPrice" name="itemMarketPrice" type="text" value="<%= it.getMarketPrice() %>">
          </div>
          <div class="field">
            <label class="field__label" for="hsCode">HS CODE</label>
            <input class="input" id="hsCode" name="itemHsCode" value="<%= Html.esc(it.getHsCode()) %>" type="text">
          </div>
          <div class="field">
            <label class="field__label" for="marketPay">오픈마켓 결제수단</label>
            <input class="input" id="marketPay" name="itemMarketPay" value="<%= Html.esc(it.getMarketPay()) %>" type="text">
          </div>
        </div>
</div><!-- /.item-block -->
<% } %>
</div><!-- /#itemList -->

      </div>
    </section>

    <!-- ============ 금액정보 입력 ============ -->
    <section class="form-section">
      <h2 class="form-section__head">금액정보 입력</h2>
      <div class="form-section__body">
        <div class="field-grid field-grid--3">
          <div class="field">
            <label class="field__label" for="totalQty">총 수량</label>
            <input class="input" id="totalQty" type="text" value="0" readonly>
          </div>
          <div class="field">
            <label class="field__label" for="totalYen">총 금액 ¥</label>
            <input class="input" id="totalYen" type="text" value="0" readonly>
          </div>
          <div class="field">
            <label class="field__label" for="totalUsd">총 금액 $</label>
            <input class="input" id="totalUsd" type="text" value="0" readonly>
          </div>
        </div>
<% if (!ship) { %>
        <div class="field-grid field-grid--3">
          <div class="field">
            <label class="field__label" for="appliedRate">적용 환율 (100엔)</label>
            <input class="input" id="appliedRate" type="text" value="<%= rate == null ? "환율 정보 없음" : "₩" + rateFmt.format(rate.getNoticeRate()) %>" readonly>
          </div>
          <div class="field">
            <label class="field__label" for="totalKrw">예상 결제금액 ₩</label>
            <input class="input" id="totalKrw" type="text" value="0" readonly>
          </div>
        </div>
        <p class="note">* <%= rate == null ? "환율 정보가 없어 원화 금액을 계산할 수 없습니다." : rate.getRateDate().toString().replace('-', '.') + " 기준 고시환율로 계산한 금액입니다. 저장할 때의 환율이 주문에 기록되며, 접수신청 시점의 환율로 확정됩니다." %></p>
<% } else { %>
        <p class="note">* 배송대행은 상품 금액을 세관 신고용으로만 사용합니다. (결제 대상은 배송비 · 관부가세)</p>
<% } %>
        <p class="note">* 세관에 신고되는 금액 입니다 (소량품 결제 금액과 동일)</p>
        <p class="note">* 총금액이 미화 150달러 이상인 경우, 통관수수료가 부과됩니다.</p>
        <p class="note">* 목록통관이 불가한 식품, 액체, 서물, 분말은 간이 통관으로 진행합니다 (*세관 절차비 책임지지 않습니다. 주의 하시기 바랍니다)</p>
        <div class="btn-row btn-row--left" style="margin-top:8px">
          <span class="badge">목록통관</span>
        </div>
      </div>
    </section>

    <!-- ============ 부가서비스 ============ -->
    <section class="form-section">
      <h2 class="form-section__head">부가서비스</h2>
      <div class="form-section__body" style="padding:0">
        <table class="opt-table">
          <tbody>
          <tr>
            <th>사진촬영옵션</th>
            <td>
              <div class="opt-grid">
                <label class="check">
                  <input type="checkbox" name="addon" value="기본검수"<%= addonSet.contains("기본검수") ? " checked" : "" %>>
                  <span>기본검수 <span class="req">(내용필수확인※)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="무검수"<%= addonSet.contains("무검수") ? " checked" : "" %>>
                  <span>무검수 <span class="req">(내용필수확인※)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="사업자검수"<%= addonSet.contains("사업자검수") ? " checked" : "" %>>
                  <span>사업자검수 <span class="price">(₩비용별도문의)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="대형화물개봉촬영"<%= addonSet.contains("대형화물개봉촬영") ? " checked" : "" %>>
                  <span>대형화물개봉촬영 <span class="req">(내용필수확인※)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="사진촬영(의류)"<%= addonSet.contains("사진촬영(의류)") ? " checked" : "" %>>
                  <span>사진촬영(의류) <span class="price">(₩1,000)</span></span>
                </label>
              </div>
            </td>
          </tr>
          <tr>
            <th>포장옵션</th>
            <td>
              <div class="opt-grid">
                <label class="check">
                  <input type="checkbox" name="addon" value="바로포장"<%= addonSet.contains("바로포장") ? " checked" : "" %>>
                  <span>바로포장 <span class="req">(내용필수확인※)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="중국택배원박스사용"<%= addonSet.contains("중국택배원박스사용") ? " checked" : "" %>>
                  <span>중국택배원박스사용 <span class="req">(내용필수확인※)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="멀티탭"<%= addonSet.contains("멀티탭") ? " checked" : "" %>>
                  <span>멀티탭 <span class="price">(₩1,700)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="새플리백포장"<%= addonSet.contains("새플리백포장") ? " checked" : "" %>>
                  <span>새플리백포장 <span class="price">(₩실비청구)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="새박스포장"<%= addonSet.contains("새박스포장") ? " checked" : "" %>>
                  <span>새박스포장 <span class="price">(₩실비청구)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="내부뽁뽁이포장"<%= addonSet.contains("내부뽁뽁이포장") ? " checked" : "" %>>
                  <span>내부뽁뽁이포장 <span class="price">(₩실비청구)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="박스외부포장보완"<%= addonSet.contains("박스외부포장보완") ? " checked" : "" %>>
                  <span>박스외부포장보완 <span class="price">(₩5,000)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="PP밴드밴딩"<%= addonSet.contains("PP밴드밴딩") ? " checked" : "" %>>
                  <span>PP밴드밴딩 <span class="price">(₩3,000)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="외부우드패킹"<%= addonSet.contains("외부우드패킹") ? " checked" : "" %>>
                  <span>외부우드패킹 <span class="price">(₩30,000)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="공기주입이에캡 내부"<%= addonSet.contains("공기주입이에캡 내부") ? " checked" : "" %>>
                  <span>공기주입이에캡 내부 <span class="price">(₩2,000)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="공기주입이에캡 외부"<%= addonSet.contains("공기주입이에캡 외부") ? " checked" : "" %>>
                  <span>공기주입이에캡 외부 <span class="price">(₩5,000)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="외부랩핑"<%= addonSet.contains("외부랩핑") ? " checked" : "" %>>
                  <span>외부랩핑 <span class="req">(내용필수확인※)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="모서리보호대 상하8개"<%= addonSet.contains("모서리보호대 상하8개") ? " checked" : "" %>>
                  <span>모서리보호대 상하8개 <span class="price">(₩2,000)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="종이코너보호대"<%= addonSet.contains("종이코너보호대") ? " checked" : "" %>>
                  <span>종이코너보호대 <span class="price">(₩2,000)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="취급주의스티커부착 한국어"<%= addonSet.contains("취급주의스티커부착 한국어") ? " checked" : "" %>>
                  <span>취급주의스티커부착 한국어 <span class="price">(₩1,400)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="취급주의스티커부착 중국어"<%= addonSet.contains("취급주의스티커부착 중국어") ? " checked" : "" %>>
                  <span>취급주의스티커부착 중국어 <span class="price">(₩700)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="나무 파렛트"<%= addonSet.contains("나무 파렛트") ? " checked" : "" %>>
                  <span>나무 파렛트 <span class="price">(₩30,000)</span></span>
                </label>
              </div>
            </td>
          </tr>
          <tr>
            <th>통관옵션</th>
            <td>
              <div class="opt-grid">
                <label class="check">
                  <input type="checkbox" name="addon" value="사업자통관(후청구)"<%= addonSet.contains("사업자통관(후청구)") ? " checked" : "" %>>
                  <span>사업자통관(후청구) <span class="req">(내용필수확인※)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="원산지증명원"<%= addonSet.contains("원산지증명원") ? " checked" : "" %>>
                  <span>원산지증명원 <span class="price">(₩33,000)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="간이통관(본인선택)"<%= addonSet.contains("간이통관(본인선택)") ? " checked" : "" %>>
                  <span>간이통관(본인선택) <span class="price">(₩3,000)</span></span>
                </label>
              </div>
            </td>
          </tr>
          <tr>
            <th>LCL관련</th>
            <td>
              <div class="opt-grid">
                <label class="check">
                  <input type="checkbox" name="addon" value="용달차(LCL만가능)"<%= addonSet.contains("용달차(LCL만가능)") ? " checked" : "" %>>
                  <span>용달차(LCL만가능) <span class="req">(내용필수확인※)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="본인픽업"<%= addonSet.contains("본인픽업") ? " checked" : "" %>>
                  <span>본인픽업 <span class="req">(내용필수확인※)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="경동택배인계"<%= addonSet.contains("경동택배인계") ? " checked" : "" %>>
                  <span>경동택배인계 <span class="req">(내용필수확인※)</span></span>
                </label>
              </div>
            </td>
          </tr>
          <tr>
            <th>원산지작업</th>
            <td>
              <div class="opt-grid">
                <label class="check">
                  <input type="checkbox" name="addon" value="원산지작업"<%= addonSet.contains("원산지작업") ? " checked" : "" %>>
                  <span>원산지작업 <span class="price">(₩2,000)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="수량체크기본"<%= addonSet.contains("수량체크기본") ? " checked" : "" %>>
                  <span>수량체크기본 <span class="price">(₩5,000)</span></span>
                </label>
              </div>
            </td>
          </tr>
          <tr>
            <th>기타옵션</th>
            <td>
              <div class="opt-grid">
                <label class="check">
                  <input type="checkbox" name="addon" value="택배박스 제거"<%= addonSet.contains("택배박스 제거") ? " checked" : "" %>>
                  <span>택배박스 제거 <span class="price">(₩1,000)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="신발박스 제거"<%= addonSet.contains("신발박스 제거") ? " checked" : "" %>>
                  <span>신발박스 제거 <span class="price">(₩500)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="의류박스 제거"<%= addonSet.contains("의류박스 제거") ? " checked" : "" %>>
                  <span>의류박스 제거 <span class="price">(₩500)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="관/부가세 회원 발송"<%= addonSet.contains("관/부가세 회원 발송") ? " checked" : "" %>>
                  <span>관/부가세 회원 발송 <span class="req">(내용필수확인※)</span></span>
                </label>
                <label class="check">
                  <input type="checkbox" name="addon" value="관/부가세 수취인 발송"<%= addonSet.contains("관/부가세 수취인 발송") ? " checked" : "" %>>
                  <span>관/부가세 수취인 발송 <span class="req">(내용필수확인※)</span></span>
                </label>
              </div>
            </td>
          </tr>
          </tbody>
        </table>

        <div style="padding:16px">
          <label class="field__label" for="logisticsNote">물류 요청사항</label>
          <textarea class="textarea" id="logisticsNote" name="logisticsNote"><%= Html.esc(fo.getLogisticsNote()) %></textarea>
        </div>
      </div>
    </section>

    <!-- ============ 무게측정 후 자동 예치금 결제 ============ -->
    <section class="form-section">
      <h2 class="form-section__head">무게측정 후 자동 예치금 결제</h2>
      <div class="form-section__body">
        <div class="field-row" style="margin:0">
          <span class="field-row__label" style="padding-top:0">예치금 자동 결제</span>
          <div class="field-row__body">
            <div class="radio-row">
              <label><input type="radio" name="autoPay" value="auto"<%= Html.checked(fo.isAutoPay()) %>> 자동결제</label>
              <label><input type="radio" name="autoPay" value="manual"<%= Html.checked(!fo.isAutoPay()) %>> 수동결제</label>
            </div>
          </div>
        </div>
      </div>
    </section>

    <div class="info-box">
      <p>접수신청을 하시게 되면 수정이 불가능합니다. 트래킹 번호 추가 등 수정이 필요하신 경우에는 접수대기를 선택해주세요.</p>
      <p>(접수신청을 완료하신 후에 부득이한 사유로 요청서 수정이 필요한 경우에는 1:1문의를 주세요)</p>
    </div>

    <div class="btn-row">
      <button class="btn" type="submit" name="mode" value="wait">접수대기</button>
      <button class="btn btn--navy" type="submit" name="mode" value="submit">접수신청</button>
    </div>

    </form>

  </div>
</main>

<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
(function () {
  var form = document.getElementById('orderForm');
  var list = document.getElementById('itemList');
  var MAX_ITEMS = 20;          // 제품품목수 20건 제한
  var AGREE_COUNT = 25;        // 해외배송규정 동의 항목 수
  // 오늘의 환율 (서버가 DB 에서 읽은 값). 환율 정보가 없으면 KRW 는 0 이라 원화 금액을 '-' 로 표시한다
  var KRW_PER_100JPY = <%= rate == null ? "0" : rate.getNoticeRate().toPlainString() %>;   // 고시환율(원) / 100엔
  var USD_PER_JPY = <%= rate == null ? "0.00666667" : rate.getJpyUsd().toPlainString() %>;   // 1엔 = 몇 달러 (세관 신고 금액)
  var CTX = '<%= ctx %>';
  var CSRF = '<%= Session.csrfToken(request) %>';
  var MAX_IMG_BYTES = 5 * 1024 * 1024;   // 이미지 5MB 제한 (서버도 같은 제한)

  // 이미지URL 칸의 값(http 주소 또는 /uploads/... 업로드 경로)으로 미리보기를 바꾼다
  function setPreview(block, value) {
    var img = block.querySelector('.thumb__img');
    var ph = block.querySelector('.thumb__ph');
    var src = '';
    value = (value || '').trim();
    if (/^https?:\/\//i.test(value)) src = value;
    else if (value.indexOf('/uploads/buy/') === 0) src = CTX + value;
    if (src) {
      img.onerror = function () { img.style.display = 'none'; ph.style.display = ''; };
      img.src = src;
      img.style.display = 'block';
      ph.style.display = 'none';
    } else {
      img.removeAttribute('src');
      img.style.display = 'none';
      ph.style.display = '';
    }
  }

  // 선택한 사진을 서버로 보내 저장하고, 돌려받은 경로를 이미지URL 칸에 넣는다
  function uploadImage(block, file) {
    if (!file) return;
    if (file.size > MAX_IMG_BYTES) { alert('이미지는 5MB 이하만 올릴 수 있습니다.'); return; }
    var btn = block.querySelector('[data-act="img"]');
    var fd = new FormData();
    fd.append('file', file);
    btn.disabled = true;
    btn.textContent = '업로드 중...';
    fetch(CTX + '/buyorder/upload?_csrf=' + encodeURIComponent(CSRF), { method: 'POST', body: fd, credentials: 'same-origin' })
      .then(function (r) { return r.json(); })
      .then(function (j) {
        if (!j.ok) throw new Error(j.message);
        block.querySelector('[name="itemImageUrl"]').value = j.path;
        setPreview(block, j.path);
      })
      .catch(function (e) {
        alert(e instanceof SyntaxError ? '이미지 업로드에 실패했습니다. 로그인 상태를 확인하고 다시 시도해 주세요.' : e.message);
      })
      .then(function () { btn.disabled = false; btn.textContent = '이미지 업로드'; });
  }

  function blocks() { return list.querySelectorAll('.item-block'); }

  // 상품 번호 · 영문명직접기재 값 · id/for 를 순서대로 다시 매긴다 (복사/추가/삭제 뒤에 호출)
  function renumber() {
    var bs = blocks();
    for (var i = 0; i < bs.length; i++) {
      var b = bs[i];
      b.querySelector('.item-no').textContent = i + 1;
      b.querySelector('input[name="itemNameEnDirect"]').value = String(i);
      var ids = b.querySelectorAll('[id]');
      for (var j = 0; j < ids.length; j++) ids[j].id = ids[j].id.replace(/_\d+$/, '') + '_' + i;
      var labels = b.querySelectorAll('label[for]');
      for (var k = 0; k < labels.length; k++) labels[k].htmlFor = labels[k].htmlFor.replace(/_\d+$/, '') + '_' + i;
    }
    calc();
  }

  // 총 수량 · 총 금액 계산 (화면 표시용. 저장할 때는 서버가 다시 계산한다)
  function calc() {
    var qty = 0, yen = 0;
    var bs = blocks();
    for (var i = 0; i < bs.length; i++) {
      var q = parseInt(bs[i].querySelector('[name="itemQty"]').value.replace(/,/g, ''), 10);
      var p = parseFloat(bs[i].querySelector('[name="itemUnitPrice"]').value.replace(/,/g, ''));
      if (isNaN(q)) q = 0;
      if (isNaN(p)) p = 0;
      qty += q;
      yen += q * p;
    }
    document.getElementById('totalQty').value = qty.toLocaleString();
    document.getElementById('totalYen').value = Math.round(yen).toLocaleString();
    document.getElementById('totalUsd').value = (yen * USD_PER_JPY).toFixed(2);
    var krwEl = document.getElementById('totalKrw');   // 배송대행 화면에는 이 칸이 없다
    if (krwEl) krwEl.value = KRW_PER_100JPY > 0 ? Math.round(yen * KRW_PER_100JPY / 100).toLocaleString() : '-';   // 화면 표시용. 저장할 때는 서버가 다시 계산
  }

  function clearBlock(b) {
    var inputs = b.querySelectorAll('input');
    for (var i = 0; i < inputs.length; i++) {
      var el = inputs[i];
      if (el.type === 'checkbox') el.checked = false;
      else if (el.name === 'itemQty') el.value = '1';
      else if (el.name === 'itemUnitPrice') el.value = '0.00';
      else if (el.name === 'itemMarketPrice') el.value = '0';
      else el.value = '';
    }
  }

  // 상품 블록 안의 버튼 (복사 / 추가 / 삭제)
  list.addEventListener('click', function (e) {
    var btn = e.target.closest('button[data-act]');
    if (!btn) return;
    var block = btn.closest('.item-block');
    var act = btn.getAttribute('data-act');

    if (act === 'copy' || act === 'add') {
      if (blocks().length >= MAX_ITEMS) { alert('상품은 최대 ' + MAX_ITEMS + '개까지 등록할 수 있습니다.'); return; }
      var clone = block.cloneNode(true);          // 입력한 값까지 그대로 복사된다
      if (act === 'add') { clearBlock(clone); setPreview(clone, ''); }   // 추가는 빈 상품
      block.parentNode.insertBefore(clone, block.nextSibling);
      renumber();
    } else if (act === 'img') {
      block.querySelector('.img-file').click();   // 숨겨 둔 파일 선택창을 연다
    } else if (act === 'del') {
      if (blocks().length <= 1) { alert('상품은 최소 1개가 필요합니다.'); return; }
      if (confirm('이 상품을 삭제할까요?')) { block.parentNode.removeChild(block); renumber(); }
    }
  });
  list.addEventListener('input', function (e) {
    calc();
    if (e.target.name === 'itemImageUrl') setPreview(e.target.closest('.item-block'), e.target.value);   // 주소를 직접 붙여넣어도 미리보기
  });
  list.addEventListener('change', function (e) {
    if (e.target.classList.contains('img-file')) {
      uploadImage(e.target.closest('.item-block'), e.target.files[0]);
      e.target.value = '';   // 같은 파일을 다시 골라도 change 가 일어나게 비운다
    }
  });

  // 아직 연결하지 않은 버튼(등록상품 불러오기, 통관품목 검색 등)은 안내만 한다
  form.addEventListener('click', function (e) {
    var btn = e.target.closest('button[type="button"]');
    if (!btn || btn.hasAttribute('data-act') || btn.id === 'btnPostcode') return;
    alert('준비 중인 기능입니다.');
  });

  // 우편번호 검색 (Daum 우편번호 서비스)
  document.getElementById('btnPostcode').addEventListener('click', function () {
    if (typeof daum === 'undefined') { alert('우편번호 서비스를 불러오지 못했습니다. 직접 입력해 주세요.'); return; }
    new daum.Postcode({
      oncomplete: function (d) {
        document.getElementById('postcode').value = d.zonecode;
        document.getElementById('addr1').value = d.roadAddress || d.address;
        document.getElementById('addr2').focus();
      }
    }).open();
  });

  // 전체 동의하기
  var agreeAll = document.getElementById('agreeAll');
  agreeAll.addEventListener('change', function () {
    var cbs = form.querySelectorAll('input[name="agree"]');
    for (var i = 0; i < cbs.length; i++) cbs[i].checked = agreeAll.checked;
  });

  // 전송 전 검사 (서버에서도 같은 검사를 다시 한다)
  function check(mode) {
    var v = function (id) { return document.getElementById(id).value.trim(); };
    if (!v('recvKo')) return '받는 사람(한글)을 입력해 주세요.';
    var bs = blocks();
    for (var i = 0; i < bs.length; i++) {
      var label = '상품 ' + (i + 1) + ' : ';
      if (!bs[i].querySelector('[name="itemNameEn"]').value.trim()) return label + '상품명(영문)을 입력해 주세요.';
      var q = parseInt(bs[i].querySelector('[name="itemQty"]').value, 10);
      if (isNaN(q) || q < 1) return label + '수량은 1 이상으로 입력해 주세요.';
      if (mode === 'submit' && !bs[i].querySelector('[name="itemTrackingNo"]').value.trim())
        return label + '트래킹번호를 입력해 주세요. (없으면 접수대기로 저장하세요)';
    }
    if (mode === 'submit') {
      if (!v('postcode') || !v('addr1')) return '우편번호와 주소를 입력해 주세요.';
      if (!v('addr2')) return '세관신고 시 상세주소는 필수입니다.';
      if (!v('mobile')) return '휴대전화를 입력해 주세요.';
      if (form.querySelectorAll('input[name="agree"]:checked').length < AGREE_COUNT)
        return '해외배송규정 ' + AGREE_COUNT + '개 항목에 모두 동의해 주세요.';
    }
    return '';
  }

  form.addEventListener('submit', function (e) {
    var mode = e.submitter ? e.submitter.value : 'submit';
    var msg = check(mode);
    if (msg) { e.preventDefault(); alert(msg); return; }
    if (mode === 'submit' && !confirm('접수신청 후에는 수정이 불가능합니다. 진행할까요?')) e.preventDefault();
  });

  renumber();
  var initBlocks = blocks();   // 수정 · 입력값 유지로 열렸을 때 이미지 미리보기를 채운다
  for (var n = 0; n < initBlocks.length; n++) {
    setPreview(initBlocks[n], initBlocks[n].querySelector('[name="itemImageUrl"]').value);
  }
})();
</script>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
