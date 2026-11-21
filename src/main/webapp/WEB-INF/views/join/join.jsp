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
<title>회원가입 | NIPPON BUY</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from join.css */
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
   회원가입 전용
   ============================================================ */

.req { margin-left: 3px; color: var(--red); }
.quiz-q { margin: 0 0 6px; font-weight: 700; color: var(--ink); }

.field-inline { display: flex; align-items: center; gap: 6px; }
.field-inline .input { flex: 1 1 auto; }
.field-inline .input--short { flex: 0 0 180px; }
.field-inline .btn { flex: 0 0 auto; white-space: nowrap; }

.field-stack .input + .input { margin-top: 6px; }
.field-stack .field-inline { margin-bottom: 6px; }

.field-hint { margin: 6px 0 0; font-size: 12px; color: var(--muted); }
.field-hint.is-error { color: var(--red); }
.field-hint.is-ok { color: var(--green); }

.agree-box {
  margin-bottom: 24px;
  padding: 16px 18px;
  background: var(--fill);
  border: 1px solid var(--line);
  border-radius: var(--radius);
}
.agree-box__all {
  padding-bottom: 12px;
  margin-bottom: 10px;
  font-size: 14px;
  font-weight: 700;
  color: var(--ink);
  border-bottom: 1px solid var(--line);
}
.agree-box label { display: block; padding: 4px 0; font-size: 13px; color: var(--body); cursor: pointer; }
.agree-box input { margin-right: 6px; vertical-align: middle; }
.agree-box a { margin-left: 8px; font-size: 12px; text-decoration: underline; }
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">회원가입</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/member/login">회원</a></li>
      <li class="breadcrumb__item is-current">회원가입</li>
    </ol>
  </div>
</section>


<%
    /* MemberInsert 가 검증 실패 시 request 에 담아 보내는 "errors"
       키: loginId / password / passwordConfirm / name / englishName / phone / email / system */
    @SuppressWarnings("unchecked")
    Map<String, String> errors = (Map<String, String>) request.getAttribute("errors");
    if (errors == null) errors = new HashMap<String, String>();
%>
<main class="page-body">
  <div class="container">

    <h1 class="sub-title"><span class="sub-title__dash"></span>회원가입</h1>

    <div class="info-box">
      <p>NIPPON BUY 회원가입을 위해 아래 정보를 입력해 주세요. <span class="req">*</span> 표시 항목은 필수 입력입니다.</p>
    </div>

    <% if (errors.get("system") != null) { %>
    <p class="field-hint is-error" style="margin:0 0 14px;font-size:13px"><%= esc(errors.get("system")) %></p>
    <% } %>

    <form id="joinForm" action="<%= ctx %>/member/join" method="post" autocomplete="off">
      <input type="hidden" name="_csrf" value="<%= esc(Session.csrfToken(request)) %>">

      <h2 class="pane-title">계정 정보</h2>

      <table class="form-table">
        <tbody>
          <tr>
            <th>아이디<span class="req">*</span></th>
            <td colspan="3">
              <div class="field-inline">
                <input class="input" type="text" id="loginId" name="loginId" maxlength="20"
                       value="<%= esc(request.getParameter("loginId")) %>"
                       placeholder="영문, 숫자 조합 4~20자" aria-label="아이디" required>
                <button class="btn btn--navy btn--sm" type="button" id="btnIdCheck">중복확인</button>
              </div>
              <p class="field-hint <%= errors.get("loginId") != null ? "is-error" : "" %>" id="idHint"><%= esc(errors.get("loginId")) %></p>
            </td>
          </tr>
          <tr>
            <th>비밀번호<span class="req">*</span></th>
            <td>
              <input class="input" type="password" id="password" name="password" maxlength="72"
                     placeholder="8자 이상" aria-label="비밀번호" required>
              <% if (errors.get("password") != null) { %><p class="field-hint is-error"><%= esc(errors.get("password")) %></p><% } %>
            </td>
            <th>비밀번호 확인<span class="req">*</span></th>
            <td>
              <input class="input" type="password" id="passwordConfirm" name="passwordConfirm" maxlength="72"
                     aria-label="비밀번호 확인" required>
              <p class="field-hint <%= errors.get("passwordConfirm") != null ? "is-error" : "" %>" id="pwHint"><%= esc(errors.get("passwordConfirm")) %></p>
            </td>
          </tr>
          <tr>
            <th>비밀번호 퀴즈<span class="req">*</span></th>
            <td colspan="3">
              <p class="quiz-q">가장 기억에 남는 장소는?</p>
              <input class="input" type="text" name="pwQuizAnswer" maxlength="20"
                     placeholder="비밀번호를 찾을 때 사용합니다" aria-label="비밀번호 퀴즈 답" required>
              <p class="field-hint <%= errors.get("pwQuizAnswer") != null ? "is-error" : "" %>"><%= errors.get("pwQuizAnswer") != null ? esc(errors.get("pwQuizAnswer")) : "비밀번호 찾기에 사용되니 잊지 않을 답을 입력해 주세요." %></p>
            </td>
          </tr>
        </tbody>
      </table>

      <h2 class="pane-title">기본 정보</h2>

      <table class="form-table">
        <tbody>
          <tr>
            <th>이름<span class="req">*</span></th>
            <td>
              <input class="input" type="text" name="name" maxlength="20"
                     value="<%= esc(request.getParameter("name")) %>" aria-label="이름" required>
              <% if (errors.get("name") != null) { %><p class="field-hint is-error"><%= esc(errors.get("name")) %></p><% } %>
            </td>
            <th>영문 이름</th>
            <td>
              <input class="input" type="text" name="englishName" maxlength="50"
                     value="<%= esc(request.getParameter("englishName")) %>" placeholder="여권상 영문 성함" aria-label="영문 이름">
              <% if (errors.get("englishName") != null) { %><p class="field-hint is-error"><%= esc(errors.get("englishName")) %></p><% } %>
            </td>
          </tr>
          <tr>
            <th>휴대전화</th>
            <td>
              <input class="input" type="tel" name="phone" maxlength="30"
                     value="<%= esc(request.getParameter("phone")) %>" placeholder="010-0000-0000" aria-label="휴대전화">
              <% if (errors.get("phone") != null) { %><p class="field-hint is-error"><%= esc(errors.get("phone")) %></p><% } %>
            </td>
            <th>이메일</th>
            <td>
              <input class="input" type="email" name="email" maxlength="100"
                     value="<%= esc(request.getParameter("email")) %>" placeholder="example@kurologi.com" aria-label="이메일">
              <% if (errors.get("email") != null) { %><p class="field-hint is-error"><%= esc(errors.get("email")) %></p><% } %>
            </td>
          </tr>
          <tr>
            <th>SMS 수신</th>
            <td colspan="3">
              <label><input type="checkbox" name="smsRefuse" value="Y" <%= "Y".equals(request.getParameter("smsRefuse")) ? "checked" : "" %>> SMS 수신을 거부합니다.</label>
            </td>
          </tr>
        </tbody>
      </table>

      <h2 class="pane-title">약관 동의</h2>

      <div class="agree-box">
        <div class="agree-box__all">
          <label><input type="checkbox" id="agreeAll"> 전체 약관에 동의합니다.</label>
        </div>
        <label><input type="checkbox" class="agree-item" required> [필수] 이용약관 동의</label>
        <label><input type="checkbox" class="agree-item" required> [필수] 개인정보 수집 및 이용 동의</label>
      </div>

      <div class="btn-row">
        <button class="btn" type="button" onclick="location.href='<%= ctx %>/'">취소</button>
        <button class="btn btn--navy" type="submit">가입하기</button>
      </div>

    </form>

  </div>
</main>

<script>
(function () {
  var form = document.getElementById('joinForm');
  var idInput = document.getElementById('loginId');
  var idHint = document.getElementById('idHint');
  var pw = document.getElementById('password');
  var pw2 = document.getElementById('passwordConfirm');
  var pwHint = document.getElementById('pwHint');

  /* 아이디 중복확인 — GET /member/idCheck?loginId=... -> {"isDuplicate":true|false} */
  function setIdHint(msg, cls) { idHint.textContent = msg; idHint.className = 'field-hint ' + cls; }

  document.getElementById('btnIdCheck').addEventListener('click', function () {
    var v = idInput.value.trim();
    if (!/^[A-Za-z0-9]{4,20}$/.test(v)) {
      setIdHint('아이디는 영문, 숫자 조합 4~20자로 입력해 주세요.', 'is-error');
      return;
    }
    fetch('<%= ctx %>/member/idCheck?loginId=' + encodeURIComponent(v))
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.isDuplicate) setIdHint('이미 사용 중인 아이디입니다.', 'is-error');
        else setIdHint('사용 가능한 아이디입니다.', 'is-ok');
      })
      .catch(function () { setIdHint('중복확인 중 오류가 발생했습니다.', 'is-error'); });
  });
  idInput.addEventListener('input', function () { setIdHint('', ''); });

  /* 비밀번호 일치 확인 (최종 검증은 서버 MemberInsert 에서도 한다) */
  function checkPw() {
    if (!pw2.value) { pwHint.textContent = ''; pwHint.className = 'field-hint'; return true; }
    var same = pw.value === pw2.value;
    pwHint.textContent = same ? '비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.';
    pwHint.className = 'field-hint ' + (same ? 'is-ok' : 'is-error');
    return same;
  }
  pw.addEventListener('input', checkPw);
  pw2.addEventListener('input', checkPw);

  /* 약관 전체 동의 */
  var all = document.getElementById('agreeAll');
  var items = document.querySelectorAll('.agree-item');
  all.addEventListener('change', function () {
    for (var i = 0; i < items.length; i++) items[i].checked = all.checked;
  });
  for (var i = 0; i < items.length; i++) {
    items[i].addEventListener('change', function () {
      var allOn = true;
      for (var j = 0; j < items.length; j++) if (!items[j].checked) allOn = false;
      all.checked = allOn;
    });
  }

  form.addEventListener('submit', function (e) {
    if (!checkPw()) { e.preventDefault(); alert('비밀번호가 일치하지 않습니다.'); pw2.focus(); }
  });
})();
</script>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
</body>
</html>
