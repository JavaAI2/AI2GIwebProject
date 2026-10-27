# kurologi-web — KURO Logi 홈페이지 (JSP · Tomcat 9)

사이트의 정적 HTML 페이지 26개를 모두 JSP 로 옮긴 **Eclipse Dynamic Web Project** 입니다.

- **Tomcat 9** (javax.servlet 4.0 · JSP 2.3) · Java 17 이상 · 추가 jar 없음
- JSP 는 **스크립틀릿** (`<% %>`, `<%= %>`) — JSTL · EL 을 쓰지 않습니다
- CSS · JS 는 원본 HTML 처럼 **각 페이지 안** `<style>` · `<script>` 에 그대로 있습니다
- 저장소는 메모리(`InMemory*`) — Tomcat 을 재시작하면 데이터가 초기화됩니다

> ⚠ `<%= 값 %>` 은 HTML 이스케이프를 하지 않습니다. 회원이 입력한 값은 반드시
> `<%= Html.esc(값) %>` 로 출력하세요. 숫자는 `Html.num(5000)` → `5,000`.

## 실행 (Eclipse)

1. File → Import → General → **Existing Projects into Workspace** → `kurologi-web` 폴더
2. 프로젝트 우클릭 → Run As → **Run on Server** → Tomcat v9.0
3. http://localhost:8080/kurologi/ → 로그인 상자에 **user_id / demo1234**

Maven 은 쓰지 않습니다. 컴파일용 servlet/jsp API 는 `lib/` 의 jar (Tomcat 9 의 `lib/` 에서 복사)
— `.classpath` 가 이 jar 를 가리키므로 Eclipse 와 VS Code 둘 다 같은 설정으로 동작합니다.
`lib/` 는 `WEB-INF/lib` 가 아니라서 배포되지 않습니다 (Tomcat 이 제공).

## 실행 (VS Code)

Tomcat 확장(Al-rimi.tomcat) — `.vscode/settings.json` 에 설정되어 있습니다 (`tomcat.buildType: Local`).
주소는 http://localhost:8080/kurologi-web/ 입니다. Eclipse 와 같은 8080 포트라 **동시에 실행하지 마세요.**

개발 중 매번 로그인하기 귀찮으면 `web.xml` 의 `kurologi.devAutoLogin` 을 `true` 로.

## 주소

| 주소 | 화면 | 서블릿 |
|---|---|---|
| `/` | 홈 (로그인 상자 · 배송센터 · 운송장 조회) | PageServlet |
| `/service/info_company` · `info_grade` · `weightchart2` · `info_regulation` · `clearance_policy` · `listpass_help` · `manual` | 서비스안내 | PageServlet |
| `/status/dashboard` · `tracking` · `nodata` · `storage` | 종합현황 | PageServlet |
| `/buy/order_form` · `stock_order` · `excel_upload` | 구매대행 | PageServlet |
| `/ship/order_form` · `excel_upload` | 배송대행 | PageServlet |
| `/community/notice` · `qna` · `message` · `deals` · `faq` | 커뮤니티 | PageServlet |
| `/mypage` | 마이페이지 — 나의 정보 · 사서함 주소(클릭 복사) | MyPageServlet |
| `/mypage/account` (+`/withdraw`) | 계정관리 — 정보수정 · 탈퇴 | AccountServlet |
| `/mypage/payment[?tab=history]` | 결제방법 — 예치금 · 무통장 · 카드 결제, 결제내역 | PaymentServlet |
| `/mypage/address` | 주소관리 — 검색 · 추가 · 수정 · 삭제 | AddressServlet |
| `POST /login` · `/logout` | 로그인 (아이디저장 쿠키 30일) · 로그아웃 | LoginServlet · LogoutServlet |

`/mypage` 아래는 로그인해야 볼 수 있습니다 (AuthFilter). 나머지는 누구나 볼 수 있습니다.

## 파일

```
src/main/webapp/
  WEB-INF/web.xml
  WEB-INF/views/
    index.jsp                     ← 홈 — 자기만의 헤더 · 푸터 (layout.jsp 안 씀)
    common/layout.jsp             ← 공통 부분 전부 (part=top · flash · summary · bottom)
    service/  status/  buy/  ship/  community/  mypage/   ← 화면 하나 = JSP 하나
  images/                         ← 페이지에서 쓰는 이미지만
src/main/java/jp/kurologi/
  model/  repository/  service/   ← 회원 · 주소 · 결제 데이터와 규칙
  web/                            ← 서블릿 · 필터 · Html(출력 도우미)
```

### 새 화면 추가하기

`WEB-INF/views/service/new_page.jsp` 를 만들면 바로 `/service/new_page` 로 열립니다
(PageServlet 이 같은 이름의 JSP 로 넘겨 줍니다. 이름은 영문 소문자 · 숫자 · `_` 만).

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    request.setAttribute("menu", "service");   // layout.jsp 주 메뉴에서 현재 메뉴 표시
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<title>새 화면 | KURO Logi</title>
<style> /* 이 화면 스타일 */ </style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>

<main class="page-body"> … </main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
```

링크 · 이미지는 항상 `<%= ctx %>/…` 로 시작합니다 (예: `<%= ctx %>/images/logo.png`).

### layout.jsp 의 part

| part | 내용 | 쓰는 곳 |
|---|---|---|
| `top` | 상단 바 (로그인 상태에 따라 로그인/로그아웃) · 로고 · 주 메뉴 | `<body>` 바로 다음 |
| `flash` | 1회용 알림 (저장 · 삭제 결과) | 마이페이지, 제목 띠 다음 |
| `summary` | 바로가기 4개 · 회원 요약 다크 바 | 계정관리 · 결제방법 |
| `bottom` | 푸터 · 공통 스크립트(복사 · 확인창) · `</body></html>` | 맨 끝 |

POST 폼에는 CSRF 한 줄을 넣어야 합니다 (없으면 403):

```jsp
<input type="hidden" name="_csrf" value="<%= Html.esc(session.getAttribute(Session.CSRF)) %>">
```

## 결제 규칙 (`PaymentService`)

- 금액은 화면 값을 믿지 않고 서버에서 대기건 합계로 다시 계산
- 사용 예치금 = min(입력값, 보유 예치금, 결제금액)
- 남은 금액 0 → 즉시 결제완료 / 무통장 → 입금확인중(입금자명 필수) / 카드 → 카드결제 진행중
- `markPaid(id)` 입금확인 · PG 승인, `cancel(id)` 취소 시 예치금 환불 + 대기건 복구

## 아직 남은 것

| 항목 | 메모 |
|---|---|
| 회원가입 · ID/PW 찾기 | 버튼만 있음 |
| DB (JDBC/MyBatis) | `repository/*` 인터페이스 구현으로 교체 |
| 신청서 · 트래킹 · 게시판 기능 | 화면만 JSP — 저장 기능은 BACKEND.md 순서대로 |
| 종합현황 · 구매대행 · 배송대행 로그인 필수화 | `AuthFilter` urlPatterns 에 추가 |
| 토스페이먼츠 · 쿠폰 · 이용실적 집계 | `PaymentServlet` · `PaymentService` · `MemberRepository.usageStats` |
