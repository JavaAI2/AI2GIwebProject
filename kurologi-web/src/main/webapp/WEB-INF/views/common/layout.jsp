

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jp.kurologi.model.Member" %>
<%@ page import="jp.kurologi.web.Html" %>
<%@ page import="jp.kurologi.web.Session" %>
<%--
  모든 화면이 같이 쓰는 부분을 한 파일에 모았습니다. part 값으로 어느 부분을 그릴지 고릅니다.

    top     — 상단 바 + 로고 + 주 메뉴                       (<body> 바로 다음)
    flash   — 1회용 알림 (저장 · 삭제 결과 등)                 (마이페이지, 제목 띠 다음)
    summary — 바로가기 4개 + 회원 요약 다크 바                (계정관리 · 결제방법)
    bottom  — 푸터 + 공통 스크립트 + </body></html>         (맨 끝)

  사용법:
    <jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>

  호출하는 페이지가 request 에 menu 를 넣어 둡니다 (현재 메뉴 표시).
  member, unpaidCount 는 BaseServlet.render() 가 넣어 둡니다 (summary).

  [수정] top : 로그인하면 우측 상단이  "OOO님 환영합니다.  로그아웃  마이페이지"  로 바뀝니다.
         이름은 request 의 member 가 있으면 그 이름, 없으면 로그인할 때 세션에 넣어 둔 loginMemberName 을 씁니다.
--%>
<%
    String ctx = request.getContextPath();
    String part = request.getParameter("part");
    String menu = (String) request.getAttribute("menu");      // service | status | mypage | buy | ship | community
    boolean loggedIn = Session.memberId(request) != null;

    // 상단 바에 찍을 로그인 회원 이름 (summary 부분의 변수 member 와 이름이 겹치지 않게 topMember 로 씀)
    Member topMember = (Member) request.getAttribute("member");
    String topName = topMember != null ? topMember.getName() : (String) session.getAttribute("loginMemberName");
    if (topName == null || topName.trim().isEmpty()) topName = "회원";
%>
<%  if ("top".equals(part)) { %>
<style>
/* 로그인 후 상단 바 : "OOO님 환영합니다." (각 페이지 CSS 를 고치지 않도록 여기에 둠) */
.topbar__welcome { display: block; padding: 0 12px 0 20px; height: 44px; line-height: 44px; font-size: 13px; color: #444; white-space: nowrap; }
.topbar__welcome strong { color: #159692; font-weight: 700; }
</style>
<div class="topbar">
  <div class="container topbar__inner">
    <ul class="topbar__links topbar__links--left">
      <li><a href="<%= ctx %>/">홈</a></li>
      <li><a href="#">즐겨찾기추가</a></li>
      <li><a href="<%= ctx %>/community/qna">1:1게시판</a></li>
    </ul>
    <ul class="topbar__links topbar__links--right">
      <li><a href="#">언어 선택 <i>▾</i></a></li>
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
      <img src="<%= ctx %>/images/logo.png" alt="Kuro Logi 물류시스템">
    </a>
    <nav class="main-nav">
      <ul class="main-nav__list">
        <li class="main-nav__item<%= Html.cls("service".equals(menu), "is-current") %>">
          <a href="<%= ctx %>/service/info_company">서비스안내</a>
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
        <li class="main-nav__item<%= Html.cls("status".equals(menu), "is-current") %>">
          <a href="<%= ctx %>/status/dashboard">종합현황</a>
          <ul class="main-nav__submenu">
            <li><a href="<%= ctx %>/status/dashboard">종합현황</a></li>
            <li><a href="<%= ctx %>/status/tracking">트레킹입력</a></li>
            <li><a href="<%= ctx %>/status/nodata">노데이터 확인</a></li>
            <li><a href="<%= ctx %>/status/storage">보관현황</a></li>
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
            <li><a href="<%= ctx %>/community/deals">특가제품안내</a></li>
            <li><a href="<%= ctx %>/community/faq">자주묻는 질문</a></li>
          </ul>
        </li>
      </ul>
    </nav>
  </div>
</header>
<%  } else if ("flash".equals(part)) {
        // 1회용 알림 — 한 번 보여주고 세션에서 지웁니다
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
          Tel(일본) : (+81) 042-401-0754
        </p>
      </div>
    </div>
  </div>
  <p class="copyright">© 2023 All Rights Reserved by KUROLogi.</p>
</footer>

<script>
/* KURO Logi — 모든 JSP 공통: 확인창 · 클립보드 복사 */
(function () {
  'use strict';

  // <form data-confirm="..."> 제출 전에 확인
  document.addEventListener('submit', function (e) {
    var form = e.target;
    var msg = form.getAttribute('data-confirm');
    // 다른 폼의 버튼(form="...")으로 제출해도 대상 폼의 data-confirm 을 따릅니다
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
    } else {
      fallback(text);
      done();
    }
  }

  // http(비보안) 환경용
  function fallback(text) {
    var ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
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
      // Copy All: "라벨 : 값" 줄바꿈으로 묶어서 복사
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
</body>
</html>
<%  } %>
