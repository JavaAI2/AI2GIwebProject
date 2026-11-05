<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*, jp.kurologi.web.Session" %>
<%!
    /** 화면에 다시 찍는 값(XSS 방지용 HTML 이스케이프) */
    static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    /** 입력칸 아래에 찍을 에러 메시지(없으면 빈 문자열) */
    static String err(Map<String, String> errors, String key) {
        return errors.get(key) == null ? "" : "<p class=\"field-hint is-error\">" + esc(errors.get(key)) + "</p>";
    }
%>
<%
    String ctx = request.getContextPath();
    request.setAttribute("menu", "member");   // layout.jsp 주 메뉴에서 현재 메뉴 표시

    /* 서비스(FindIdCommand / FindPwCommand / ResetPwCommand)가 실패 시 request 에 담아 보내는 "errors" */
    @SuppressWarnings("unchecked")
    Map<String, String> errors = (Map<String, String>) request.getAttribute("errors");
    if (errors == null) errors = new HashMap<String, String>();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>아이디 찾기 | NIPPON BUY</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from find.css */
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
   아이디 / 비밀번호 찾기 전용
   ============================================================ */

.req { margin-left: 3px; color: var(--red); }

.field-hint { margin: 6px 0 0; font-size: 12px; color: var(--muted); }
.field-hint.is-error { color: var(--red); }
.field-hint.is-ok { color: var(--green); }

.quiz-q { margin: 0 0 6px; font-weight: 700; color: var(--ink); }

.find-tabs {
  display: flex;
  margin: 0 0 24px;
  padding: 0;
  list-style: none;
  border-bottom: 1px solid var(--line);
}
.find-tabs a {
  display: block;
  padding: 12px 28px;
  font-size: 15px;
  font-weight: 700;
  color: var(--muted);
  border: 1px solid var(--line);
  border-bottom: 0;
  margin-right: -1px;
  background: var(--fill);
}
.find-tabs a.is-active { color: #fff; background: var(--navy); border-color: var(--navy); }

.form-error {
  margin: 0 0 14px;
  padding: 10px 12px;
  font-size: 13px;
  color: var(--red);
  background: #fdf1ef;
  border: 1px solid #f3c9c3;
  border-radius: var(--radius);
}

.result-box {
  margin: 0 0 6px;
  padding: 28px 20px;
  text-align: center;
  background: #f7fbfb;
  border: 1px solid #d9ecec;
  border-radius: var(--radius);
}
.result-box__title { margin: 0 0 14px; font-size: 14px; color: var(--body); }
.result-box__list { margin: 0; padding: 0; list-style: none; }
.result-box__list li { margin: 6px 0; font-size: 22px; font-weight: 700; color: var(--navy); }
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">아이디 찾기</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/member/login">회원</a></li>
      <li class="breadcrumb__item is-current">아이디 찾기</li>
    </ol>
  </div>
</section>


<%
    /* FindIdCommand 가 일치하는 회원을 찾으면 담아 주는 아이디 목록 (없으면 null -> 입력 폼 표시) */
    @SuppressWarnings("unchecked")
    List<String> foundIds = (List<String>) request.getAttribute("foundIds");
%>
<main class="page-body">
  <div class="container">

    <h1 class="sub-title"><span class="sub-title__dash"></span>아이디 찾기</h1>

    <ul class="find-tabs">
      <li><a class="is-active" href="<%= ctx %>/member/find/id">아이디 찾기</a></li>
      <li><a href="<%= ctx %>/member/find/pw">비밀번호 찾기</a></li>
    </ul>

<% if (foundIds != null) { %>

    <h2 class="pane-title">찾은 아이디</h2>

    <div class="result-box">
      <p class="result-box__title">입력하신 정보와 일치하는 아이디입니다.</p>
      <ul class="result-box__list">
<%      for (String id : foundIds) { %>
        <li><%= esc(id) %></li>
<%      } %>
      </ul>
    </div>

    <div class="btn-row">
      <button class="btn" type="button" onclick="location.href='<%= ctx %>/member/find/pw'">비밀번호 찾기</button>
      <button class="btn btn--navy" type="button" onclick="location.href='<%= ctx %>/member/login'">로그인하기</button>
    </div>

<% } else { %>

    <div class="info-box">
      <p>가입하실 때 입력한 이름, 이메일, 휴대전화 번호를 모두 입력해 주세요. 세 가지가 모두 일치하면 아이디를 알려 드립니다.</p>
    </div>

<%  if (errors.get("find") != null) { %>
    <p class="form-error"><%= esc(errors.get("find")) %></p>
<%  } %>

    <form id="findIdForm" action="<%= ctx %>/member/find/id" method="post" autocomplete="off">
      <input type="hidden" name="_csrf" value="<%= esc(Session.csrfToken(request)) %>">

      <h2 class="pane-title">회원 정보 확인</h2>

      <table class="form-table">
        <tbody>
          <tr>
            <th>이름<span class="req">*</span></th>
            <td>
              <input class="input" type="text" name="name" maxlength="20"
                     value="<%= esc(request.getParameter("name")) %>" aria-label="이름" required>
              <%= err(errors, "name") %>
            </td>
          </tr>
          <tr>
            <th>이메일<span class="req">*</span></th>
            <td>
              <input class="input" type="email" name="email" maxlength="100"
                     value="<%= esc(request.getParameter("email")) %>" placeholder="example@kurologi.com" aria-label="이메일" required>
              <%= err(errors, "email") %>
            </td>
          </tr>
          <tr>
            <th>휴대전화<span class="req">*</span></th>
            <td>
              <input class="input" type="tel" name="phone" maxlength="30"
                     value="<%= esc(request.getParameter("phone")) %>" placeholder="010-0000-0000" aria-label="휴대전화" required>
              <%= err(errors, "phone") %>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="btn-row">
        <button class="btn" type="button" onclick="location.href='<%= ctx %>/member/login'">취소</button>
        <button class="btn btn--navy" type="submit">아이디 찾기</button>
      </div>
    </form>

<% } %>

  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
</body>
</html>
