<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="jp.kurologi.model.*" %>
<%@ page import="jp.kurologi.web.Html" %>
<%@ page import="jp.kurologi.web.Session" %>
<%@ page import="jp.kurologi.web.App" %>
<%@ page import="jp.kurologi.service.ShipmentBoard" %>
<%
    String ctx = request.getContextPath();

    request.setAttribute("menu", "mypage");   // layout.jsp 주 메뉴에서 현재 메뉴 표시

    // MyPageServlet 이 넣어 준 값
    Member member = (Member) request.getAttribute("member");
    UsageStats usage = (UsageStats) request.getAttribute("usage");
    List<MailboxCenter> centers = (List<MailboxCenter>) request.getAttribute("centers");
    Grade nextGrade = (Grade) request.getAttribute("nextGrade");
    int countToNextGrade = (Integer) request.getAttribute("countToNextGrade");
    String referralUrl = (String) request.getAttribute("referralUrl");

    // 결제가 완료된 운송품 현황 : MyPageMain 이 넣어 준 값을 쓰고,
    // 값이 없으면(예전 MyPageServlet 이 이 화면을 열었을 때 등) 여기서 직접 만든다.
    List<ShipmentRow> shipments = (List<ShipmentRow>) request.getAttribute("shipments");
    if (shipments == null) shipments = ShipmentBoard.load(App.of(application), member);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>마이페이지 | NIPPON BUY</title>
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

.page-body { padding: 24px 0 40px; }
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

/* ---------------------------------------------------- 마이페이지 관리 */

.manage-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 0;
}

.manage-item {
  display: flex;
  gap: 12px;
  padding: 20px 16px;
  border-right: 1px solid var(--line-soft);
  border-bottom: 1px solid var(--line-soft);
}

.manage-item:nth-child(4n) { border-right: 0; }
.manage-item:nth-last-child(-n+4) { border-bottom: 0; }

.manage-item__icon {
  flex: 0 0 40px;
  width: 40px;
  height: 40px;
  display: grid;
  place-items: center;
  font-size: 22px;
  color: #666;
  background: var(--fill);
  border-radius: 50%;
}

.manage-item__name {
  display: block;
  margin-bottom: 2px;
  font-size: 14px;
  font-weight: 700;
  color: var(--orange);
}

.manage-item__desc {
  margin: 0;
  font-size: 12px;
  line-height: 1.6;
  color: var(--body);
}


/* 관리 메뉴가 3개이므로 3열로 배치합니다 */
.manage-grid--three { grid-template-columns: repeat(3, 1fr); }
.manage-grid--three .manage-item { border-bottom: 0; }
.manage-grid--three .manage-item:nth-child(4n) { border-right: 1px solid var(--line-soft); }
.manage-grid--three .manage-item:nth-child(3n) { border-right: 0; }
.manage-item__name a { color: inherit; }
.manage-item__name a:hover { color: var(--teal); }
/* --------------------------------------------------------- 사서함 주소 */

.addr-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0;
}

.addr-card {
  padding: 16px;
  background: var(--fill);
  border-right: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
}

.addr-card:nth-child(3n) { border-right: 0; }
.addr-card:nth-last-child(-n+3) { border-bottom: 0; }

.addr-card__name {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0 0 12px;
  font-size: 16px;
  font-weight: 700;
  color: var(--ink);
}

.addr-card__flag { width: 24px; height: auto; }

.addr-field { margin-bottom: 8px; }
.addr-field__label { display: block; font-size: 11px; color: var(--muted); }
.addr-field__value { display: block; font-size: 13px; color: var(--ink); word-break: break-all; }

.addr-copy {
  display: inline-block;
  margin-top: 10px;
  padding: 8px 20px;
  font-size: 13px;
  font-weight: 700;
  color: #fff;
  background: var(--blue);
  border: 0;
  border-radius: var(--radius);
  cursor: pointer;
}
.addr-copy:hover { background: #0d659b; }


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

/* 클릭 복사 (JSP) */
.addr-field[data-copy-field] { cursor: pointer; }
.addr-field[data-copy-field]:hover .addr-field__value { color: var(--blue); }
button.info-link { font-family: inherit; background: #fff; cursor: pointer; }

/* ------------------------------------------------- 결제 완료 운송품 현황 */

.ship-table { width: 100%; border-collapse: collapse; }

.ship-table th {
  padding: 11px 8px;
  font-size: 13px;
  font-weight: 700;
  color: var(--ink);
  text-align: center;
  background: #f3f3f3;
  border-bottom: 1px solid var(--line);
}

.ship-table td {
  padding: 13px 8px;
  font-size: 13px;
  color: var(--ink);
  text-align: center;
  vertical-align: middle;
  border-bottom: 1px solid var(--line-soft);
}

.ship-table tr:last-child td { border-bottom: 0; }
.ship-table td.is-left { text-align: left; }
.ship-table__empty { padding: 30px 10px; text-align: center; color: var(--muted); }

.ship-table .wb__no { display: block; font-weight: 700; letter-spacing: .3px; }
.ship-table .wb__label { color: var(--body); }
.ship-table .wb a { font-size: 12px; }
.ship-table .order-no { display: block; margin-top: 3px; font-size: 12px; }

.ship-more { font-size: 13px; font-weight: 700; }

/* 진행 상태 알약 (구매대행 · 배송대행 주문내역과 같은 색) */
.state { display: inline-block; padding: 2px 10px; font-size: 12px; border-radius: 999px; }
.state--done { color: var(--orange); border: 1px solid var(--orange); }
.state--wait { color: var(--muted); border: 1px solid #bbb; }
.state--submit { color: var(--teal); border: 1px solid var(--teal); }
.state--received { color: #8a5a00; border: 1px solid #d9a441; }
.state--shipped { color: #fff; background: #37b149; border: 1px solid #37b149; }
.state--billed { color: #b34700; border: 1px solid #e8a15c; }
.state--delivering { color: #fff; background: #1b6fb5; border: 1px solid #1b6fb5; }
.state--delivered { color: #fff; background: #0f6b5c; border: 1px solid #0f6b5c; }
</style>
</head>
<body>
<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>

<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">마이페이지</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item is-current">마이페이지</li>
    </ol>
  </div>
</section>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="flash" /></jsp:include>

<main class="page-body">
  <div class="container">

    <!-- ============ 나의 정보 ============ -->
    <div class="box">
      <div class="box__head">
        <p class="box__title">나의 정보</p>
        <p class="box__note">
<%  if (nextGrade == null) { %>
          최고 등급인 <strong><%= member.getGrade().getLabelShort() %></strong> 회원입니다.
<%  } else { %>
          다음 등급인 <strong><%= nextGrade.getLabelShort() %></strong> 레벨로 상향되려면, <strong><%= Html.num(countToNextGrade) %></strong>건 더 이용하시면 됩니다.
<%  } %>
        </p>
      </div>
      <div class="box__body" style="padding:0">
        <table class="info-table">
          <thead>
            <tr>
              <th>등급</th>
              <th>포인트</th>
              <th>친구 추천 포인트</th>
              <th>예치금</th>
              <th>회원번호</th>
              <th>이용실적</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><%= member.getGrade().getLabel() %></td>
              <td class="money">¥<%= Html.num(member.getPoints()) %></td>
              <td>
                <span class="dim"><%= Html.num(member.getReferralPointsPending()) %> P 적립대기</span>
                
              </td>
              <td class="money">¥<%= Html.num(member.getDeposit()) %></td>
              <td><%= Html.esc(member.getMemberNo()) %></td>
              <td class="plain">
                전월 이용건수 : <%= usage.lastMonth() %>건<br>
                당월 이용건수 : <%= usage.thisMonth() %>건<br>
                총 이용건수 : <%= usage.total() %>건
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ============ 결제 완료 운송품 현황 (결제내역에서 확인되는 물품의 진행 상황) ============ -->
    <div class="box">
      <div class="box__head">
        <p class="box__title">결제 완료 운송품 현황</p>
        <p class="box__note">최근 결제한 <%= shipments.size() %>건 &nbsp;<a class="ship-more" href="<%= ctx %>/mypage/payment?tab=history">결제내역 전체보기 ›</a></p>
      </div>
      <div class="box__body" style="padding:0">
        <table class="ship-table">
          <thead>
            <tr>
              <th>결제일</th>
              <th>내용</th>
              <th>한국 운송장</th>
              <th>일본 운송장</th>
              <th>진행 상태</th>
            </tr>
          </thead>
          <tbody>
<%  for (ShipmentRow r : shipments) {
        Payment sp = r.payment();
%>
            <tr>
              <td><%= sp.getCreatedAtText() %></td>
              <td class="is-left"><%= Html.esc(sp.getSummary()) %></td>
              <td class="wb">
<%      if (sp.getKrWaybillNo() != null) { %>
                <span class="wb__label"><%= Html.esc(sp.getKrMethodLabel()) %></span>
                <span class="wb__no"><%= Html.esc(sp.getKrWaybillNo()) %></span>
                <a href="<%= ctx %>/?krMethod=<%= Html.esc(sp.getKrMethod()) %>&amp;krNo=<%= Html.esc(sp.getKrWaybillNo()) %>#tracking">조회</a>
<%      } else { %>-<%      } %>
              </td>
              <td class="wb">
<%      if (sp.getJpWaybillNo() != null) { %>
                <span class="wb__label"><%= Html.esc(sp.getJpCarrierLabel()) %></span>
                <span class="wb__no"><%= Html.esc(sp.getJpWaybillNo()) %></span>
                <a href="<%= ctx %>/?jpCarrier=<%= Html.esc(sp.getJpCarrier()) %>&amp;jpNo=<%= Html.esc(sp.getJpWaybillNo()) %>#tracking">조회</a>
<%      } else { %>-<%      } %>
              </td>
              <td>
                <span class="state <%= Html.esc(r.statusCss()) %>"><%= Html.esc(r.statusLabel()) %></span>
<%      if (r.orderNo() != null) { %>
<%          if (r.orderUrl() != null) { %>
                <a class="order-no" href="<%= ctx %><%= r.orderUrl() %>"><%= Html.esc(r.orderNo()) %></a>
<%          } else { %>
                <span class="order-no"><%= Html.esc(r.orderNo()) %></span>
<%          } %>
<%      } %>
              </td>
            </tr>
<%  } %>
<%  if (shipments.isEmpty()) { %>
            <tr><td class="ship-table__empty" colspan="5">결제가 완료된 운송품이 없습니다.</td></tr>
<%  } %>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ============ 나의 사서함 주소 ============ -->
    <div class="box">
      <div class="box__head">
        <p class="box__title">회원님의 일본 사서함 주소</p>
        <p class="box__note">★ 각 항목을 클릭하시면 자동 복사됩니다.</p>
      </div>
      <div class="box__body" style="padding:0">
        <div class="addr-grid">
<%  for (MailboxCenter center : centers) { %>
          <div class="addr-card">
            <p class="addr-card__name"><%= Html.esc(center.name()) %></p>
            <div class="addr-field" data-copy-field><span class="addr-field__label">우편번호</span><span class="addr-field__value"><%= Html.esc(center.zipcode()) %></span></div>
            <div class="addr-field" data-copy-field><span class="addr-field__label">주소</span><span class="addr-field__value"><%= Html.esc(center.address()) %></span></div>
            <div class="addr-field" data-copy-field><span class="addr-field__label">사서함번호</span><span class="addr-field__value"><%= Html.esc(member.getMailboxNo()) %></span></div>
            <div class="addr-field" data-copy-field><span class="addr-field__label">전화번호</span><span class="addr-field__value"><%= Html.esc(center.phone()) %></span></div>
            <div class="addr-field" data-copy-field><span class="addr-field__label">수취인</span><span class="addr-field__value"><%= Html.esc(member.getRecipientName()) %></span></div>
            <button class="addr-copy" type="button" data-copy-card>Copy All</button>
          </div>
<%  } %>
        </div>
      </div>
    </div>

    <!-- ============ 관리 메뉴 ============ -->
    <div class="box">
      <div class="box__head">
        <p class="box__title">마이페이지 관리 하기</p>
      </div>
      <div class="manage-grid manage-grid--three">

        <div class="manage-item">
          <span class="manage-item__icon">⚙</span>
          <span>
            <span class="manage-item__name"><a href="<%= ctx %>/mypage/account">계정관리</a></span>
            <span class="manage-item__desc">비밀번호, 회원정보 변경<br>나의 멤버십 등급</span>
          </span>
        </div>

        <div class="manage-item">
          <span class="manage-item__icon">💳</span>
          <span>
            <span class="manage-item__name"><a href="<%= ctx %>/mypage/payment">결제방법</a></span>
            <span class="manage-item__desc">신용카드 및 체크카드 관리<br>신용카드 및 체크카드 추가</span>
          </span>
        </div>

        <div class="manage-item">
          <span class="manage-item__icon">📇</span>
          <span>
            <span class="manage-item__name"><a href="<%= ctx %>/mypage/address">주소관리</a></span>
            <span class="manage-item__desc">나의 주소록<br>새 주소 추가하기</span>
          </span>
        </div>

      </div>
    </div>

  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
