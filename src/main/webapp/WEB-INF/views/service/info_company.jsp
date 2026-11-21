<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    request.setAttribute("menu", "service");   // layout.jsp 주 메뉴에서 현재 메뉴 표시
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>NIPPON BUY 소개 | NIPPON BUY</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from info-company.css */
/* ==========================================================================
   NIPPON BUY — 내부 페이지 공통 기본 스타일

   이 파일은 5개 페이지의 CSS 맨 위에 그대로 복사해서 씁니다.
   (페이지마다 CSS를 따로 두기로 했기 때문에 @import 대신 복사합니다)

   바꾸고 싶은 값은 :root 한 곳만 고치면 됩니다.
   ========================================================================== */

:root {
  --teal:      #159692;   /* 헤더, 기본 버튼 */
  --teal-dark: #107a77;   /* 호버 */
  --teal-tab:  #129692;   /* 선택된 탭 */
  --teal-line: #107976;   /* 표 상단 굵은 선 */
  --blue:      #107abd;   /* 링크, 포인트 */
  --red:       #dd4b39;   /* 경고, 강조 */
  --mint:      #159692;

  --ink:       #333333;   /* 제목 */
  --body:      #555555;   /* 본문 */
  --muted:     #666666;   /* 보조 */
  --footer-text: #cccccc;

  --line:       #e5e5e5;
  --line-soft:  #eeeeee;
  --line-table: #dddddd;
  --line-input: #ced4da;
  --fill:       #f2f2f2;
  --fill-th:    #f4fafa;   /* 표 머리글 배경 */
  --fill-head:  #f6f6f6;   /* 페이지 제목 띠 배경 */

  --container:  1360px;
  --gutter:     15px;
  --radius:     4px;
}

/* --------------------------------------------------------------- 리셋 */

*,
*::before,
*::after { box-sizing: border-box; }

html { font-size: 16px; }

body {
  margin: 0;
  font-family: 'Noto Sans KR', serif;
  font-size: 0.875rem;      /* 14px */
  line-height: 1.5;
  color: var(--body);
  background: #fff;
}

h1, h2, h3, h4, h5, h6 {
  margin: 0 0 0.5rem;
  color: #444;
  font-weight: 400;
  line-height: 1.5;
}

h1 { font-size: 36px; }
h2 { font-size: 30px; }
h3 { font-size: 24px; }
h4 { font-size: 18px; }

p { margin: 0 0 1rem; }

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

.row {
  display: flex;
  flex-wrap: wrap;
  margin: 0 calc(var(--gutter) * -1);
}

.col { padding: 0 var(--gutter); }
.col--footer-logo { width: 16.6667%; }
.col--footer-info { width: 83.3333%; }

/* --------------------------------------------------------------- 상단 바 */

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
  color: var(--muted);
}

.topbar__links a.kakao-btn { height: 44px; line-height: 44px; padding: 0 6px; }

/* -------------------------------------------------------- 헤더 + 주 메뉴 */

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
.main-nav__item.is-current > a { color: #fff; }

/* 하위 메뉴 */
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
  color: var(--muted);
  white-space: normal;
}

.main-nav__submenu a:hover { padding-left: 18px; color: var(--teal); }

/* ------------------------------------------------------- 페이지 제목 띠 */

.page-head {
  padding: 15px 0 13px;
  background: var(--fill-head);
  border-bottom: 1px solid var(--line-soft);
}

.page-head__inner {
  position: relative;
  min-height: 33px;
}

.page-head__title {
  margin: 0;
  font-size: 22px;
  font-weight: 400;
  line-height: 1;
  letter-spacing: -2px;
  color: var(--ink);
}

/* 현재 위치 (오른쪽 정렬) */
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
.breadcrumb__item a:hover { color: var(--blue); }
.breadcrumb__item.is-current { color: var(--muted); }

/* ------------------------------------------------------------------ 본문 */

.page-body { padding: 30px 0 40px; }

/* 본문 안의 소제목: 왼쪽에 청록 세로 막대 */
.page-body h3 {
  margin: 30px 0 14px;
  padding-left: 12px;
  font-size: 20px;
  font-weight: 500;
  color: var(--ink);
  border-left: 4px solid var(--teal);
}

.page-body h4 {
  margin: 24px 0 12px;
  padding-left: 12px;
  font-size: 18px;
  font-weight: 500;
  color: var(--ink);
  border-left: 3px solid var(--teal);
}

.page-body h3 + p,
.page-body h4 + p { margin-top: 0; }

/* -------------------------------------------------------------- 표 공통 */

/* 원본 .table1 : 위쪽에 청록 굵은 선, 칸마다 회색 테두리 */
.data-table {
  width: 100%;
  height: auto;
  margin-bottom: 20px;
  border-collapse: collapse;
  border-top: 2px solid var(--teal-line);
}

.data-table th,
.data-table td {
  padding: 12px 7px;
  font-size: 13px;
  text-align: center;
  vertical-align: middle;
  border: 1px solid var(--line-table);
}

.data-table th { font-weight: 700; background: var(--fill-th); }
.data-table td { background: #fff; }

/* 왼쪽 정렬이 필요한 칸 */
.data-table td.is-left { text-align: left; }

/* 세로형 표: 머리글 줄을 흰 배경으로 */
.data-table--vertical thead th { background: #fff; color: #000; font-weight: 700; }
.data-table--vertical td img { display: block; margin: 0 auto; }

/* ------------------------------------------------------------ 텍스트 도우미 */

.is-bold      { font-weight: 700; }
.is-red       { color: var(--red); }
.is-mint      { color: var(--mint); }
.text-center  { text-align: center; }
.text-h2      { font-size: 20px; }
.text-h3      { font-size: 18px; }
.spaced-top   { margin-top: 30px; }
.spaced-bottom { margin-bottom: 30px; }

/* 안내 문구 블록 */
.note-block {
  margin: 16px 0;
  padding: 14px 16px;
  font-size: 14px;
  line-height: 1.8;
  background: #f7fbfb;
  border: 1px solid #d9ecec;
  border-radius: var(--radius);
}

/* 빨간 주의 박스 */
.alert {
  margin: 0 0 16px;
  padding: 0.75rem 1.25rem;
  font-size: 14px;
  line-height: 24px;
  color: #721c24;
  background: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: var(--radius);
}

/* --------------------------------------------------------------- 버튼 */

.btn {
  display: inline-block;
  padding: 0.4rem 0.75rem;
  border: 0;
  border-radius: var(--radius);
  font-size: 0.9rem;
  line-height: 1.5;
  letter-spacing: -0.5px;
  text-align: center;
  white-space: nowrap;
  vertical-align: middle;
}

.btn--dark { color: #fff; background: #343a40; }
.btn--dark:hover { color: #fff; background: #23272b; }

.btn--info { color: #fff; background: #17a2b8; }
.btn--info:hover { color: #fff; background: #138496; }

.btn--sm { padding: 0.25rem 0.5rem; font-size: 0.8rem; border-radius: 0.2rem; }

/* 링크형 버튼 (원본 .btn_link) */
.link-btn {
  display: inline-block;
  margin: 0 6px 6px 0;
  padding: 0 16px 0 16px;
  font-size: 16px;
  line-height: 26px;
  color: var(--ink);
  background: #ddd;
}
.link-btn:hover { color: var(--ink); background: #cfcfcf; }
.link-btn--active { color: #fff; background: var(--teal-tab); }
.link-btn--active:hover { color: #fff; background: var(--teal-dark); }

/* 카카오 상담 버튼 이미지 */
.kakao-btn img { height: 35px; width: auto; padding-top: 5px; vertical-align: middle; }

/* --------------------------------------------------------------- 푸터 */

.site-footer {
  margin-top: 10px;
  background: #333;
  color: var(--footer-text);
}

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
  color: var(--footer-text);
}

.copyright {
  margin: 0;
  padding: 20px 0;
  font-size: 13px;
  text-align: center;
  color: rgba(255, 255, 255, .5);
  background: rgba(0, 0, 0, .2);
}

/* ==========================================================================
   NIPPON BUY — NIPPON BUY 소개 페이지
   이 파일만 고치면 이 페이지 디자인이 바뀝니다.
   ========================================================================== */


/* 소개 이미지: 가운데 정렬, 너무 커지지 않게 */
.company-intro {
  margin: 0 auto 24px;
  text-align: center;
}
.company-intro img {
  display: block;
  max-width: 100%;
  margin: 0 auto;
}

/* 인사말 */
.company-hello {
  margin: 0 0 30px;
  font-size: 15px;
  line-height: 1.9;
  text-align: center;
  color: var(--body);
}

/* 서비스 3열 표는 칸마다 설명이 길어 왼쪽 정렬이 읽기 좋습니다 */
.page-body .data-table td { text-align: left; }
.page-body .data-table tr:first-child td { text-align: center; }
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<!-- 페이지 제목 + 현재 위치 -->
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">NIPPON BUY 소개</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/service/info_company">서비스안내</a></li>
      <li class="breadcrumb__item is-current">NIPPON BUY 소개</li>
    </ol>
  </div>
</section>

<main class="page-body">
  <div class="container">
<p class="text-center"><img src="<%= ctx %>/images/help/kuro_info.jpg"  /></p>
	<p class="text-center">안녕하세요. 방문해 주셔서 감사합니다. <br> NIPPON BUY(니폰바이)를 소개합니다. </p> 

	<h4>NIPPON BUY 란?</h4>
	<p>경쟁력 있는 가격의  E-commerce 글로벌 종합 물류서비스 입니다.</p> 

	<h4>NIPPON BUY 의미?</h4>
	<p>NIPPON(日本)은 일본, BUY는 구매를 뜻합니다.</p> 
	<p> [일본의 좋은 상품을 한국 고객에게 가장 안전하고 빠르게 전달한다] </p> 
	<p> 라는 미션을 배경으로 NIPPON BUY가 탄생 하였습니다.</p> 

	<h4 class="spaced-top">NIPPON BUY  물류 서비스</h4>

    <table class="data-table company-table">
			
			<tr class ='fontcolor-mint1 text-center' style='font-weight:bold;font-size:16px'>
				<td >
					NIPPON BUY Express 
					(글로벌 항공, 해상 운송 서비스)
				</td>
				<td>구매, 배송대행 서비스 (일본 배대지)</td>
				<td>구매대행 셀러를 위한 인기 일본 제품 제안 </td>
			</tr>
			<tr>
				<td>
					일본에서 한국, 동남아국가 등에 B2C, B2B 항공 및 해상운송 서비스를 경쟁력 있는 가격에 제공합니다. <br>일본 수,출입 운송건은 부담 없이 문의 바랍니다. 
					(글로벌 항공, 해상 운송 서비스)<br>
				</td>
				<td>NIPPON BUY 배대지 시스템을 이용하여, 손쉽게 일본구매대행 서비스를 시작할 수 있습니다.<br>
					경쟁력있는 국제송료와 서비스 비용으로 빠르게 빅셀러가 되도록 서포트 합니다. <br>
				</td>
				<td>구매대행에서 인기있는 제품들을 쉽게 구매 할 수 있도록 다양하게 제안합니다.   일본 수퍼딜리버리, 넷씨, 타지마야 등의 다양한 제품을 제안드리며 예치금으로 쉽게 구매 가능합니다.  </td>
			</tr>
			<tr>
				<td>
					이미지
				</td>
				<td>이미지</td>
				<td>이미지</td>
			</tr>
			<tr class ='fontcolor-mint1 text-center' style='font-weight:bold;font-size:16px'>
				<td>
					일본 3PL 서비스
					(풀필먼트)

				</td>
				<td>일본 Amazon FBA
수입대행, 납품
</td>
				<td>일본 수입, 수출 통관대행 </td>
			</tr>
			<tr>
				<td>
					일본 온라인사이트 판매제품을 NIPPON BUY 창고에 재고를 놓고 일본국내 택배 배송을 의뢰하세요!<br><br>

WMS(창고관리시스템), OMS(주문관리시스템)을 이용한 3PL(풀필먼트) 서비스를 제공합니다.<br>
API를 통해 발송의뢰, 발송메일이 자동으로 처리됩니다.<br>
				</td>
				<td>일본 Amazon FBA에 납품하고 싶은데 수입자가 없어 못하고 계신가요?<br><br>
NIPPON BUY가 수입자가 되어 FBA라벨링과 Amazon창고 납품까지 원스톱으로 해결해 드립니다.<br>
Amazon FBA보관료가 부담이면 NIPPON BUY 창고에 일시 보관후 필요시 납품도 가능합니다. <br>

				</td>
				<td>항공, 해상운송시 필요한 일본 통관 대행서비스 입니다.<br><br>
특히, 해외에서 일본으로 수입되는 SP화물의 목록통관 후, 택배사 인계, 라스트마일 배송까지 일련의 서비스를 경쟁력 있는 가격으로 제공합니다. <br>
또한, 배송이슈에 대한 CS 및 반품 관련 서비스도 함께 제공하여 일본에 거점이 없는 기업이 편리하게 이용 가능합니다. <br>
 </td>
			</tr>

		</table>
  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
