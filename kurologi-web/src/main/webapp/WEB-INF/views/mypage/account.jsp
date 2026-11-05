<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="jp.kurologi.model.*" %>
<%@ page import="jp.kurologi.web.Html" %>
<%@ page import="jp.kurologi.web.Session" %>
<%
    String ctx = request.getContextPath();

    request.setAttribute("menu", "mypage");   // layout.jsp 주 메뉴에서 현재 메뉴 표시

    Member member = (Member) request.getAttribute("member");
    Map<String, String> errors = Html.errors(request);

    // 검증 실패로 다시 그릴 때는 회원이 입력한 값(파라미터)을, 아니면 저장된 값(member)을 보여줍니다.
    boolean retry = !errors.isEmpty();
    String vEnglishName = retry ? request.getParameter("englishName") : member.getEnglishName();
    String vPhone       = retry ? request.getParameter("phone")       : member.getPhone();
    boolean vSmsRefuse  = retry ? request.getParameter("smsRefuse") != null : member.isSmsRefuse();
    String vMemberType  = retry ? request.getParameter("memberType")  : member.getMemberType().name();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>계정관리 | NIPPON BUY</title>
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
   계정관리 — 회원정보 수정
   ============================================================ */

/* 상단 4개 바로가기 */
.quick-links {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 18px;
}

.quick-links a {
  display: block;
  padding: 14px 10px;
  font-size: 15px;
  text-align: center;
  color: var(--ink);
  background: #fff;
  border: 1px solid var(--line);
  border-radius: var(--radius);
}

.quick-links a:hover { border-color: var(--teal); color: var(--teal); }

/* 회원 요약 (다크 바) */
.summary-strip {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  margin-bottom: 26px;
  background: #464b5c;
  border-radius: var(--radius);
  overflow: hidden;
}

.summary-strip__cell {
  padding: 16px 10px;
  text-align: center;
  border-right: 1px solid rgba(255, 255, 255, .12);
}

.summary-strip__cell:last-child { border-right: 0; }

.summary-strip__label {
  display: block;
  font-size: 14px;
  color: #fff;
}

.summary-strip__value {
  display: block;
  margin-top: 6px;
  font-size: 15px;
  font-weight: 700;
  color: #fff;
}

.summary-strip__value--gold { color: #e8c341; }

/* 가운데 제목 (짧은 막대 + 글자) */
.sub-title {
  margin: 0 0 26px;
  font-size: 30px;
  font-weight: 700;
  color: var(--ink);
  text-align: center;
}

.sub-title__dash {
  display: block;
  width: 40px;
  height: 3px;
  margin: 0 auto 10px;
  background: var(--ink);
}

/* 라벨 + 값 2단 표 */
.form-table {
  width: 100%;
  margin-bottom: 30px;
  border-collapse: collapse;
}

.form-table th,
.form-table td {
  padding: 14px 16px;
  font-size: 14px;
  border: 1px solid var(--line);
  vertical-align: middle;
}

.form-table th {
  width: 13%;
  font-weight: 700;
  color: var(--ink);
  text-align: left;
  background: var(--fill);
}

.form-table td { width: 37%; color: var(--body); }

.form-table td.is-readonly { color: var(--ink); }
.form-table__note { margin: 0 0 8px; font-size: 13px; color: var(--body); }

/* 버튼 줄 (이 페이지는 가운데 정렬) */
.btn-row {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-top: 20px;
}

.btn {
  display: inline-block;
  padding: 12px 34px;
  font-family: inherit;
  font-size: 15px;
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
.topbar {
  border-bottom: 1px solid #c1c1c1;
  font-size: 13px;
  line-height: 44px;
}
.toast.is-shown { opacity: 1; }

/* 입력 · 라디오 (결제방법 화면과 같은 모양) */
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

.input + .input { margin-top: 6px; }
.input:focus { outline: none; border-color: var(--teal); }

.radio-row { display: flex; gap: 24px; font-size: 14px; color: var(--ink); }
.radio-row label { display: flex; align-items: center; gap: 5px; cursor: pointer; }
.check { display: inline-flex; align-items: center; gap: 5px; cursor: pointer; }
</style>
</head>
<body>
<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>

<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">계정관리</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/mypage">마이페이지</a></li>
      <li class="breadcrumb__item is-current">계정관리</li>
    </ol>
  </div>
</section>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="flash" /></jsp:include>

<main class="page-body">
  <div class="container">

    <jsp:include page="../common/layout.jsp"><jsp:param name="part" value="summary" /></jsp:include>

    <h1 class="sub-title"><span class="sub-title__dash"></span>회원정보 수정</h1>

    <form method="post" action="<%= ctx %>/mypage/account" novalidate>
      <input type="hidden" name="_csrf" value="<%= Html.esc(session.getAttribute(Session.CSRF)) %>">
      <table class="form-table">
        <tbody>
          <tr>
            <th>아이디</th>
            <td class="is-readonly"><%= Html.esc(member.getLoginId()) %></td>
            <th>사서함 번호</th>
            <td class="is-readonly"><%= Html.esc(member.getMailboxNo()) %></td>
          </tr>
          <tr>
            <th>이름</th>
            <td class="is-readonly"><%= Html.esc(member.getName()) %></td>
            <th>영문이름</th>
            <td>
              <input class="input" type="text" name="englishName" value="<%= Html.esc(vEnglishName) %>" maxlength="50" required aria-label="영문이름">
              <%= Html.error(errors, "englishName") %>
            </td>
          </tr>
          <tr>
            <th>비밀번호</th>
            <td>
              <input class="input" type="password" name="newPassword" autocomplete="new-password" placeholder="변경할 때만 입력" aria-label="새 비밀번호">
              <input class="input" type="password" name="newPasswordConfirm" autocomplete="new-password" placeholder="비밀번호 확인" aria-label="비밀번호 확인">
              <%= Html.error(errors, "newPassword") %>
              <%= Html.error(errors, "newPasswordConfirm") %>
            </td>
            <th>휴대폰</th>
            <td>
              <input class="input" type="tel" name="phone" value="<%= Html.esc(vPhone) %>" placeholder="010-0000-0000" aria-label="휴대폰">
              <%= Html.error(errors, "phone") %>
            </td>
          </tr>
          <tr>
            <th>이메일</th>
            <td class="is-readonly"><%= Html.esc(member.getEmail()) %></td>
            <th>마지막 로그인</th>
            <td class="is-readonly"><%= member.getLastLoginAtText() %> &nbsp;<a href="<%= ctx %>/logout">로그아웃</a></td>
          </tr>
          <tr>
            <th>SMS 수신동의<br>(자동 필수)</th>
            <td colspan="3">
              <p class="form-table__note">지속적인 현황을 알 수 있습니다(견적,입고,출고,배송,오류)</p>
              <label class="check"><input type="checkbox" name="smsRefuse" value="Y"<%= Html.checked(vSmsRefuse) %>> 배송비용 통지 수신 거부</label>
            </td>
          </tr>
          <tr>
            <th>개인/사업자</th>
            <td colspan="3">
              <span class="radio-row">
                <label><input type="radio" name="memberType" value="PERSONAL"<%= Html.checked(!"BUSINESS".equals(vMemberType)) %>> 개인</label>
                <label><input type="radio" name="memberType" value="BUSINESS"<%= Html.checked("BUSINESS".equals(vMemberType)) %>> 사업자</label>
              </span>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="btn-row">
        <button class="btn btn--navy" type="submit">정보수정</button>
        <button class="btn" type="submit" form="withdrawForm">탈퇴하기</button>
      </div>
    </form>

    <form id="withdrawForm" method="post" action="<%= ctx %>/mypage/account/withdraw"
          data-confirm="정말 탈퇴하시겠습니까?&#10;탈퇴 후에는 사서함번호와 주문 내역을 복구할 수 없습니다.">
      <input type="hidden" name="_csrf" value="<%= Html.esc(session.getAttribute(Session.CSRF)) %>">
    </form>

  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
