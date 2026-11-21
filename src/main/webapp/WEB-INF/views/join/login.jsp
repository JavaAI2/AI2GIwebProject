<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*, java.net.URLDecoder, jp.kurologi.web.Session" %>
<%!
    /** 화면에 다시 찍는 값(XSS 방지용 HTML 이스케이프) */
    static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String ctx = request.getContextPath();
    request.setAttribute("menu", "member");   // layout.jsp 주 메뉴에서 현재 메뉴 표시
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>로그인 | NIPPON BUY</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from login.css */
/* ==========================================================================
   NIPPON BUY — 회원 (stock_order.css 와 동일한 공통 스타일)

   바꾸고 싶은 값은 :root 한 곳만 고치면 됩니다.
   순수 CSS · Bootstrap 클래스 없음 · 데스크톱 고정폭
   ========================================================================== */

:root {
  --teal:      #159692;
  --teal-dark: #107a77;
  --blue:      #107abd;
  --purple:    #6f42c1;
  --orange:    #f0801a;
  --orange-bg: #fdf3e7;
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
  border-top: 2px solid var(--ink);
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

/* ============================================================
   로그인 전용
   ============================================================ */

.login-box {
  width: 100%;
  max-width: 460px;
  margin: 30px auto 20px;
  padding: 30px 32px 28px;
  border: 1px solid var(--line);
  border-top: 2px solid var(--ink);
}

.login-box__title {
  margin: 0 0 22px;
  font-size: 20px;
  font-weight: 700;
  text-align: center;
  color: var(--ink);
}

.login-field { margin-bottom: 10px; }
.login-field .input { padding: 12px 12px; font-size: 14px; }

.login-options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 4px 0 18px;
  font-size: 13px;
}
.login-options label { cursor: pointer; }
.login-options input { margin-right: 6px; vertical-align: middle; }

.login-error {
  margin: 0 0 14px;
  padding: 10px 12px;
  font-size: 13px;
  color: var(--red);
  background: #fdf1ef;
  border: 1px solid #f3c9c3;
  border-radius: var(--radius);
}

.btn--block { display: block; width: 100%; padding: 14px 20px; font-size: 15px; }

.login-links {
  margin: 20px 0 0;
  padding-top: 18px;
  text-align: center;
  font-size: 13px;
  color: var(--muted);
  border-top: 1px solid var(--line);
}
.login-links a { margin: 0 10px; color: #555; }
.login-links a:hover { color: var(--teal); }

.login-notice {
  margin: 0 0 14px;
  padding: 10px 12px;
  font-size: 13px;
  color: #1f7a37;
  background: #eef8f0;
  border: 1px solid #bfe3c8;
  border-radius: var(--radius);
}
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">로그인</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/member/login">회원</a></li>
      <li class="breadcrumb__item is-current">로그인</li>
    </ol>
  </div>
</section>


<%
    /* LoginCommand 가 실패 시 request 에 담는 "loginFail" 메시지 */
    String loginFail = (String) request.getAttribute("loginFail");
    boolean joined = "1".equals(request.getParameter("joined"));   // 가입 직후 redirect 로 들어온 경우
    boolean pwReset = "1".equals(request.getParameter("pwReset")); // 비밀번호 변경 직후 redirect 로 들어온 경우

    /* 아이디 저장 쿠키(LoginCommand.SAVED_ID_COOKIE = "savedId", URL 인코딩되어 저장됨) */
    String savedId = "";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if ("savedId".equals(c.getName())) {
                try { savedId = URLDecoder.decode(c.getValue(), "UTF-8"); } catch (Exception ignore) { }
            }
        }
    }
    /* 로그인 실패로 다시 열린 경우에는 방금 입력한 아이디를 우선 사용 */
    String idValue = request.getParameter("loginId") != null ? request.getParameter("loginId") : savedId;
    boolean saveChecked = !savedId.isEmpty() || request.getParameter("saveId") != null;
%>
<main class="page-body">
  <div class="container">

    <h1 class="sub-title"><span class="sub-title__dash"></span>로그인</h1>

    <div class="login-box">
      <h2 class="login-box__title">NIPPON BUY 회원 로그인</h2>

      <% if (joined) { %>
      <p class="login-notice">회원가입이 완료되었습니다. 로그인해 주세요.</p>
      <% } %>
      <% if (pwReset) { %>
      <p class="login-notice">비밀번호가 변경되었습니다. 새 비밀번호로 로그인해 주세요.</p>
      <% } %>
      <% if (loginFail != null) { %>
      <p class="login-error"><%= esc(loginFail) %></p>
      <% } %>

      <form id="loginForm" action="<%= ctx %>/member/login" method="post">
      <input type="hidden" name="_csrf" value="<%= esc(Session.csrfToken(request)) %>">
        <div class="login-field">
          <input class="input" type="text" name="loginId" value="<%= esc(idValue) %>"
                 placeholder="아이디" aria-label="아이디" <%= idValue.isEmpty() ? "autofocus" : "" %> required>
        </div>
        <div class="login-field">
          <input class="input" type="password" name="password" placeholder="비밀번호" aria-label="비밀번호"
                 <%= idValue.isEmpty() ? "" : "autofocus" %> required>
        </div>

        <div class="login-options">
          <label><input type="checkbox" name="saveId" value="Y" <%= saveChecked ? "checked" : "" %>> 아이디 저장</label>
        </div>

        <button class="btn btn--navy btn--block" type="submit">로그인</button>
      </form>

      <div class="login-links">
        <a href="<%= ctx %>/member/find/id">아이디 찾기</a>|<a href="<%= ctx %>/member/find/pw">비밀번호 찾기</a>|<a href="<%= ctx %>/member/join">회원가입</a>
      </div> 
    </div>

  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
</body>
</html>
