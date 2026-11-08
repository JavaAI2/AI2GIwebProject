<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jp.kurologi.model.Member" %>
<%@ page import="jp.kurologi.web.Html" %>
<%@ page import="jp.kurologi.web.Session" %>
<%-- Common layout for all pages. --%>
<%
    String ctx = request.getContextPath();
    String part = request.getParameter("part");
    String menu = (String) request.getAttribute("menu");
    boolean loggedIn = Session.memberId(request) != null;

    Member topMember = (Member) request.getAttribute("member");
    String topName = topMember != null ? topMember.getName() : (String) session.getAttribute("loginMemberName");
    if (topName == null || topName.trim().isEmpty()) topName = "회원";
%>
<%  if ("top".equals(part)) { %>
<style>
.topbar__welcome { display: block; padding: 0 12px 0 20px; height: 44px; line-height: 44px; font-size: 13px; color: #444; white-space: nowrap; }
.topbar__welcome strong { color: #159692; font-weight: 700; }
</style>
<div class="topbar">
  <div class="container topbar__inner">
    <ul class="topbar__links topbar__links--left">
      <li><a href="<%= ctx %>/">홈</a></li>
      <li><a href="<%= ctx %>/community/qna">1:1게시판</a></li>
    </ul>
    <ul class="topbar__links topbar__links--right">
      <li class="lang-slot"><div class="gtranslate_wrapper"></div></li>
<%  if (loggedIn) { %>
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

<header class="site-header">
  <div class="container site-header__inner">
    <a class="site-header__logo" href="<%= ctx %>/">
      <img src="<%= ctx %>/images/logo.png" alt="NIPPON BUY 물류시스템">
    </a>
    <nav class="main-nav">
      <ul class="main-nav__list">
        <li class="main-nav__item<%= Html.cls("service".equals(menu), "is-current") %>">
          <a href="<%= ctx %>/service/info_company">서비스안내</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/service/info_company">NIPPON BUY 소개</a></li>
            <li><a href="<%= ctx %>/service/info_grade">회원등급, 수수료 안내</a></li>
            <li><a href="<%= ctx %>/service/weightchart2">국제배송비 안내</a></li>
            <li><a href="<%= ctx %>/service/info_regulation">검수규정,보상규정</a></li>
            <li><a href="<%= ctx %>/service/clearance_policy">통관불가 품목</a></li>
            <li><a href="<%= ctx %>/service/listpass_help">목록통관 품목안내</a></li>
            <li><a href="<%= ctx %>/service/manual">NIPPON BUY 사용메뉴얼</a></li>
          </ul>
        </li>
        <li class="main-nav__item<%= Html.cls("status".equals(menu), "is-current") %>">
          <a href="<%= ctx %>/status/dashboard">종합현황</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/status/dashboard">종합현황</a></li>
          </ul>
        </li>
        <li class="main-nav__item<%= Html.cls("mypage".equals(menu), "is-current") %>">
          <a href="<%= ctx %>/mypage">마이페이지</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/mypage">마이페이지</a></li>
            <li><a href="<%= ctx %>/mypage/account">계정관리</a></li>
            <li><a href="<%= ctx %>/mypage/payment">결제방법</a></li>
            <li><a href="<%= ctx %>/mypage/address">주소관리</a></li>
          </ul>
        </li>
        <li class="main-nav__item<%= Html.cls("buy".equals(menu), "is-current") %>">
          <a href="<%= ctx %>/buy/order_form">구매대행</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/buy/order_form">주문서등록</a></li>
            <li><a href="<%= ctx %>/buyorder/list">구매대행 주문내역</a></li>
          </ul>
        </li>
        <li class="main-nav__item<%= Html.cls("ship".equals(menu), "is-current") %>">
          <a href="<%= ctx %>/ship/order_form">배송대행</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/ship/order_form">주문서등록</a></li>
            <li><a href="<%= ctx %>/shiporder/list">배송대행 신청내역</a></li>
          </ul>
        </li>
        <li class="main-nav__item<%= Html.cls("community".equals(menu), "is-current") %>">
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
<%  } else if ("flash".equals(part)) {
        Session.Flash flash = (Session.Flash) session.getAttribute(Session.FLASH);
        if (flash != null) {
            session.removeAttribute(Session.FLASH);
%>
  <div class="container">
    <p class="flash flash--<%= Html.esc(flash.type()) %>" role="status"><%= Html.esc(flash.message()) %></p>
  </div>
<%  } %>
<%  } else if ("summary".equals(part)) {
        Member member = (Member) request.getAttribute("member");
        int unpaidCount = (Integer) request.getAttribute("unpaidCount");
%>
<div class="quick-links">
  <a href="#">나의 배송대행지</a>
  <a href="<%= ctx %>/service/weightchart2">나의 배송요율표</a>
  <a href="<%= ctx %>/mypage/address">나의 주소록</a>
  <a href="#">운송장 발송정보</a>
</div>

<div class="summary-strip">
  <div class="summary-strip__cell">
    <span class="summary-strip__label">회원명</span>
    <span class="summary-strip__value"><%= Html.esc(member.getName()) %></span>
  </div>
  <div class="summary-strip__cell">
    <span class="summary-strip__label">나의 사서함</span>
    <span class="summary-strip__value summary-strip__value--gold"><%= Html.esc(member.getMailboxNo()) %></span>
  </div>
  <div class="summary-strip__cell">
    <span class="summary-strip__label">예치금(₩)</span>
    <span class="summary-strip__value summary-strip__value--gold"><%= Html.num(member.getDeposit()) %></span>
  </div>
  <div class="summary-strip__cell">
    <span class="summary-strip__label">쿠폰</span>
    <span class="summary-strip__value summary-strip__value--gold"><%= member.getCoupons() %></span>
  </div>
  <div class="summary-strip__cell">
    <span class="summary-strip__label">미결제</span>
    <a class="summary-strip__value summary-strip__value--gold" href="<%= ctx %>/mypage/payment"><%= unpaidCount %></a>
  </div>
</div>
<%  } else if ("bottom".equals(part)) { %>
<footer class="site-footer">
  <div class="container site-footer__inner">
    <div class="row">
      <div class="col col--footer-logo">
        <img class="site-footer__logo" src="<%= ctx %>/images/logo.png" alt="NIPPON BUY 물류시스템">
      </div>
      <div class="col col--footer-info">
        <div class="footer-links">
          <a href="#">이용약관</a>
          <a href="#">개인정보처리방침</a>
          <a href="#">이메일무단수집거부</a>
          <a href="#">특정상거래법에 따른 표기</a>
          <a href="#">개인정보 보호방침(일본)</a>
        </div>
        <p class="site-footer__text">
          NIPPON BUY Co., Ltd <br>
          3F, 1-2-3, Sample-cho, Chiyoda-ku, Tokyo To, 100-0000, Japan<br>
          Tel(일본) : (+81) 03-1234-5678
        </p>
      </div>
    </div>
  </div>
  <p class="copyright">© 2023 All Rights Reserved by NIPPON BUY.</p>
</footer>

<script>
/* NIPPON BUY Common Scripts: confirm & clipboard copy */
(function () {
  'use strict';
  document.addEventListener('submit', function (e) {
    var form = e.target;
    var msg = form.getAttribute('data-confirm');
    if (msg && !window.confirm(msg)) e.preventDefault();
  });
  var toast;
  function notify(text) {
    if (!toast) {
      toast = document.createElement('div');
      toast.className = 'toast';
      toast.setAttribute('role', 'status');
      document.body.appendChild(toast);
    }
    toast.textContent = text;
    toast.classList.add('is-shown');
    clearTimeout(notify.timer);
    notify.timer = setTimeout(function () { toast.classList.remove('is-shown'); }, 1500);
  }
  function copy(text) {
    text = (text || '').trim();
    if (!text) return;
    var done = function () { notify('복사되었습니다.'); };
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(done, function () { fallback(text); done(); });
    } else { fallback(text); done(); }
  }
  function fallback(text) {
    var ta = document.createElement('textarea');
    ta.value = text; ta.style.position = 'fixed'; ta.style.opacity = '0';
    document.body.appendChild(ta); ta.select();
    document.execCommand('copy'); document.body.removeChild(ta);
  }
  function fieldValue(field) {
    var v = field.querySelector('.addr-field__value');
    return v ? v.textContent : '';
  }
  document.addEventListener('click', function (e) {
    var el;
    if ((el = e.target.closest('[data-copy]'))) {
      copy(el.getAttribute('data-copy'));
    } else if ((el = e.target.closest('[data-copy-card]'))) {
      var card = el.closest('.addr-card');
      var lines = Array.prototype.map.call(card.querySelectorAll('[data-copy-field]'), function (f) {
        return f.querySelector('.addr-field__label').textContent + ' : ' + fieldValue(f).trim();
      });
      copy(lines.join('\n'));
    } else if ((el = e.target.closest('[data-copy-field]'))) {
      copy(fieldValue(el));
    }
  });
})();
</script>
<%@ include file="translate.jspf" %>
</body>
</html>
<%  } %>