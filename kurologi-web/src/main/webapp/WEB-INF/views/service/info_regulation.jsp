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
<title>NIPPON BUY 검수규정, 보상규정 | NIPPON BUY</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from info-regulation.css */
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
   NIPPON BUY — 검수규정, 보상규정 페이지
   이 파일만 고치면 이 페이지 디자인이 바뀝니다.
   ========================================================================== */


/* 두 규정으로 나누는 큰 제목 */
.regulation-part {
  margin: 40px 0 16px;
  padding: 12px 16px;
  font-size: 20px;
  font-weight: 700;
  color: #fff;
  background: var(--teal);
  border-radius: var(--radius);
}
.regulation-part:first-child { margin-top: 0; }

/* 규정 표: 본문이 길어 왼쪽 정렬 */
.regulation-table th,
.regulation-table td {
  padding: 12px 10px;
  font-size: 13px;
  line-height: 1.8;
  text-align: left;
}
.regulation-table th { text-align: center; }

/* 검수 항목 목록 (· 로 시작하는 줄) */
.check-list {
  margin: 0 0 20px;
  padding: 0;
  list-style: none;
}
.check-list li {
  padding: 4px 0 4px 14px;
  font-size: 13px;
  line-height: 1.8;
  text-indent: -14px;
}

/* ※ 표시 안내 */
.notice-line {
  margin: 6px 0;
  padding: 10px 12px;
  font-size: 13px;
  line-height: 1.8;
  color: #7a5b00;
  background: #fffaf0;
  border-left: 3px solid #e0a800;
}

/* 안내 그림 */
.regulation-guide { margin: 16px 0; }
.regulation-guide img { display: block; margin: 0 auto; }
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<!-- 페이지 제목 + 현재 위치 -->
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">NIPPON BUY 검수규정, 보상규정</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/service/info_company">서비스안내</a></li>
      <li class="breadcrumb__item is-current">NIPPON BUY 검수규정, 보상규정</li>
    </ol>
  </div>
</section>

<main class="page-body">
  <div class="container">
<div>
	<p>본 규정은 NIPPON BUY 이용약관의 일부를 구성하며, 서비스 이용 시 본 규정에 동의한 것으로 간주됩니다.</p>
	<br>
	
	<p><a href='#info_a'>A. NIPPON BUY 검수규정 안내</a></p>
	<p><a href='#info_b'>B. NIPPON BUY 보상 규정 안내</a></p>
	<div class="line"></div>
	<h3 id='info_a level-1'>A. NIPPON BUY 검수규정 안내</h3>

	<p class="fontsize-bold22 level-2">1. 기본 검수 (무료)</p>
    <p class="level-3" ><span class="is-red">기본 검수는 무료 서비스</span>이며, 아래 항목에 한하여 육안으로 간단하게 확인합니다.</p>
	<p class="level-4" >· 문서상의 상품명 확인</p>
	<p class="level-4" >· 상품 수량 확인</p>
	<p class="level-4" >· 옵션(색상/사이즈 등) 확인</p>
	<p class="level-4" >· 육안으로 확인 가능한 심각한 파손 여부</p>
	<p class="level-3" >※ 제품의 컬러, 사이즈 등 옵션에 해당하는 내용은 반드시 제품명이 아닌 옵션에 명시해 주셔야 합니다.</p>
	<p class="level-3 is-red">※기본 검수는 무료 서비스이므로, 검수 과정에서 발견하지 못한 사항에 대해서는 책임 및 보상이 어렵습니다.</p>
	<p class="level-3">※ 기본 검수는 작업자의 육안 확인만 진행되며 <span class="is-red">아래 사항은 검수 대상이 아닙니다.</span></p>
 
	<table class="data-table regulation-table" style='border-top: 4px solid #107976;'>
	<tr>
		<td  >· 파손여부</td>
		<td  >· 미세한 스크래치</td>
		<td  >· 오염</td>
	</tr>	
	<tr>
		<td  >· 실밥</td>
		<td  >· 색상 차이</td>
		<td  >· 재질 차이</td>
	</tr>
	<tr>
		<td  >· 제조사 마감 품질</td>
		<td  >· 상품의 진위 여부</td>
		<td  >· 정품 여부</td>
	</tr>	
	<tr>
		<td  >· 기능 이상</td>
		<td  >· 구성품 누락</td>
		<td  >· 내부 불량</td>
	</tr>

	<tr>
		<td  >· 유통기한 확인</td>
		<td  ></td>
		<td  ></td>
	</tr>

	</table>
	<br>
	<p class="level-2 fontsize-bold22">2. 상세 사진 검수 (유료)</p>
    <p class="level-3">상세 사진 검수를 신청한 상품은 작업자가 다각도에서 약 5~10장의 사진을 촬영하여 1:1 문의를 통해 전달드립니다.</p>
	<p class="level-3">회원사에서 직접 사진을 확인한 후.</p>
	<p class="level-4">· 출고</p>
	<p class="level-4">· 보류</p>
	<p class="level-4">· 반품</p>
	<p class="level-3">여부를 결정해 주시면 해당 내용에 따라 작업을 진행합니다.</p>
	<p class="level-3"><span class="is-red" >상세 사진 검수는 작업자의 주관적인 판단이 아닌 회원사의 최종 확인을 기준으로 출고</span>됩니다.</p>

	<br>
	<p class="level-2 fontsize-bold22">3. 검수 제외 항목</p>
    <p class="level-3" >	다음 항목은 검수가 어렵거나 전문적인 확인이 필요한 사항으로 <span class="is-red" >검수 대상이 아닙니다</span>.</p>

	<table class="data-table regulation-table">
	<tr>
		<th  >외관</th>
		<th  >기능</th>
	</tr>	
	<tr>
		<td  >파손 여부</td>
		<td  >전원 작동 여부</td>  
	</tr>	
	<tr>
		<td  >미세 스크래치</td>
		<td  >전자제품 기능 확인</td>   
	</tr>
	<tr>
		<td  >오염</td>
		<td  >충전 여부</td>   
	</tr>		
	<tr>
		<td  >실밥</td>
		<td  >인터넷 연결</td>   
	</tr>	
	<tr>
		<td  >선물용 포장(기프트 랩핑)된 제품   </td>
		<td  >소프트웨어 이상</td>   
	</tr>	
	<tr>
		<td  >정품여부</td>
		<td  >향기,맛 확인</td>   
	</tr>	
	<tr>
		<td  >사용 흔적</td>
		<td  >개봉 테스트가 필요한 상품</td>   
	</tr>		
	<tr>
		<td  >밀봉 상품 내부 상태</td>
		<td  ></td>   
	</tr>			
	</table>
	
	
	
	<br>
	<p class="level-2 fontsize-bold22">4. 동일 트래킹번호 상품 관리</p>
    <p class="level-3" ><span class="is-red" >동일한 트래킹번호로 입고된 상품은 반드시 동일한 시점에 주문서를 작성</span>해 주시기 바랍니다.</p>
	<p class="level-3" >예를들어
	<p class="level-4" >· A상품 주문서 작성</p>
	<p class="level-4" >· B상품 주문서 미작성</p>
	<p class="level-3" >상태에서 동일 박스로 입고된 경우,</p>	
	<p class="level-3" >작업자가 하나의 화물로 인식하여 주문서가 없는 상품까지 함께 발송되는 사례가 발생할 수 있습니다.</p>
	<p class="level-3" >(특히, 완충재 등으로 시야가 가려져, 미등록 제품이 함께 들어있어도 안보이는 경우가 많습니다)</p>

	<p class="level-3" >이 경우 <span class="is-red">회원사의 주문서 작성 누락으로 간주되며 보상이 어렵습니다.</span></p>

	<div class="line" id='info_b'></div>
	<h3 class="level-1">B. NIPPON BUY 보상 규정 안내</h3>
	
	<p class="level-2">NIPPON BUY에서 출고된 화물은 일본 내 운송, 수출 통관, 국제운송, 한국 수입 통관 및 국내배송 등 여러 협력업체를 거쳐 최종 구매자에게 배송됩니다.</p>
	<p class="level-2">운송 과정 중 발생할 수 있는 예기치 못한 사고에 대비하여 NIPPON BUY는 <span class="is-red fontsize-bold18">배송보험 서비스</span>를 제공하고 있으며, 회원사는 주문서별로 보험 가입 여부를 선택할 수 있습니다.</p>
	<p class="level-2">보상 범위는 <span class="fontsize-bold18">보험 가입 여부에 따라 아래와 같이 적용됩니다.</span></p>

	<table class="data-table regulation-table">
	<tr>
		<th class="is-bold text-h3" >구분</th>
		<th class="is-bold text-h3 is-red" >보험 가입(추천)</th>
		<th class="is-bold text-h3" >보험 미가입</th>		
	</tr>	
	<tr>
		<td  >보상한도</td>
		<td  >○</td>  
		<td  >Invoice기준 최대 20,000엔</td>  		
	</tr>	
	<tr>
		<td  >구매금액</td>
		<td  >○</td>  
		<td  >○(20,000엔 한도)</td>  		
	</tr>	
	<tr>
		<td  >국제배송비</td>
		<td  >○</td>  
		<td  >X</td>  		
	</tr>	
	<tr>
		<td  >관·부가세</td>
		<td  >○</td>  
		<td  >X</td>  		
	</tr>	
		<tr>
		<td  >분실</td>
		<td  >○</td>  
		<td  >○(20,000엔 한도)</td>  		
	</tr>		
		
		<tr>
		<td  >파손</td>
		<td  >○</td>  
		<td  >○(20,000엔 한도)</td>  	
	</tr>			
	
	</table>
	<br>
	
	<p class="level-2 fontsize-bold22">1. 보험 가입 화물 (추천)</p>	
	<p class="level-3" >고가 상품 또는 파손 위험이 높은 상품은 배송보험 가입을 권장드립니다.<p>
<<<<<<< HEAD
=======
	<p class="level-3" ><span class="fontcolor_blue">니폰바이 안심케어 상세보기=></span><a class="btn btn--info btn--sm" href='https://nipponbuy.jp/service/insurance' target='_blank'>클릭!</a></p>
>>>>>>> branch 'main' of https://github.com/Earthly-j/AI2GIwebProject.git
	<p class="level-3 fontsize-bold22">①보상범위</p>
	<p class="level-4" ><span class="is-red">·보험 가입 화물은 보험약관에 따라 최대 500만원까지 보상</span>이 가능합니다.</p>
	<p class="level-4"  class="fontsize-bold18">·파손, 도난, 분실, 오발송(주문한제품과 다른제품 수령)  발생시</p>
	<br>

	<p class="level-3 fontsize-bold22">② 보상 대상</p>
	<p class="level-4" ><span class="is-red">·상품 구매금액(Invoice 기준)</span></p>
	<p class="level-4" ><span class="is-red">·국제배송비</span></p>
	<p class="level-4" ><span class="is-red">·반송필요시 반송비용</span></p>
	<p class="level-4" ><span class="is-red">·관세, 부가세(발생 시)</span> ※ 단, 세금 종류에 따라, 일부 세금은 제외되는 경우도 있습니다</p>
	<p class="level-4">	※ 보험사 심사 결과에 따라 최종 보상금액이 결정됩니다.</p>
	<br>
	<p class="level-3 fontsize-bold22">③ 보상 대상 사고</p>
	<p class="level-4" >·배송 중 분실</p>
	<p class="level-4" >·배송 중 파손</p>
	<p class="level-4" >·오발송 사고 (주문제품과 다른제품 수령)</p>
	<p class="level-4" >·기타 보험약관에서 인정하는 사고</p>
	<br>
	<p class="level-3 fontsize-bold22">④ 보험 청구 방법</p>
	<p class="level-4" >본 청구시 고객정보 등 개인정보 포함 제출이 필요하기 때문에 반드시 <span class="fontsize-bold18"> 회원사께서 접수</span>.</p>
	<br>
	<p class="level-2 fontsize-bold22">2. 보험 미가입 화물
	<p class="level-3" >보험 미가입 화물은 아래 기준에 따라 보상이 진행됩니다.</p> 
	<br> 
	<p class="level-3 fontsize-bold22">① 보상 대상</p> 
	<p class="level-3">다음의 경우 NIPPON BUY의 명백한 과실이 확인되면 보상 대상이 됩니다.</p> 
	<p class="level-4" >· 상세 검수 미스 (<span class="is-red">※기본검수 제외</span>)</p> 
	<p class="level-4" >· 타 회원사 상품 오배송</p> 
	<p class="level-4" >· 수량 오출고</p> 
	<p class="level-4" >· 회원사 승인 없이 오출고</p> 
	<p class="level-4" >· 작업 중 발생한 명백한 파손</p> 
	<p class="level-4" >· NIPPON BUY 과실로 인한 분실</p> 
	<br> 
	<p class="level-3 fontsize-bold22">②보상 제외</p> 
	<p class="level-3" >다음의 경우는 보상이 어렵습니다.</p> 
	<p class="level-4" >· 판매처 출고 불량</p> 
	<p class="level-4" >· 제조불량</p> 
	<p class="level-4" >· 초기불량</p> 
	<p class="level-4" >· 유통기한 문제</p> 
	<p class="level-4" >· 판매처 오배송</p> 
	<p class="level-4" >· 기본검수 범위 외 사항</p> 
	<p class="level-4" >· 상품 판매가 하락</p> 
	<p class="level-4" >· 할인 손실</p> 
	<p class="level-4" >· 판매 기회 손실</p> 
	<p class="level-4" >· 간접 손해</p> 
	<p class="level-4" >· 영업 손실</p> 
	<p class="level-4" >· 예상 이익</p> 
	<p class="level-4" >· 운송사 조사 결과 NIPPON BUY 책임이 아닌 경우</p> 
	<p class="level-4 fontsize-bold18">· 배송중 사고시 이하 보상제외 제품 품목</p> 
	<br>
	<p class="level-3 fontsize-bold18">※ 보상제외 제품 품목</p> 
	<table class="data-table regulation-table">
	<tr>
		<th class="is-bold text-h3" >깨지거나 파손되기 쉬운 제품<br>(액체류, 유리, 가구 제품)</th>
		<th class="is-bold text-h3" >전자제품, 정밀제품</th>
		<th class="is-bold text-h3" >고가품, 중고품</th>		
	</tr>	
	<tr>
		<td  >거울</td>
		<td  >노트북</td>  
		<td  >보석</td>  		
	</tr>	
	<tr>
		<td  >액자</td>
		<td  >휴대폰</td>  
		<td  >귀금속</td>  		
	</tr>	
	<tr>
		<td  >액체류</td>
		<td  >카메라</td>  
		<td  >예술품</td>  		
	</tr>	
	<tr>
		<td  >샴푸</td>
		<td  >TV</td>  
		<td  >골동품</td>  		
	</tr>	
	<tr>
		<td  >화장품</td>
		<td  >모니터</td>  
		<td  >중고제품등</td>  		
	</tr>	
	<tr>
		<td  >음료</td>
		<td  >스피커</td>  
		<td  ></td>  		
	</tr>	
	<tr>
		<td  >피규어</td>
		<td  >DVD플레이어</td>  
		<td  ></td>  		
	</tr>	
	<tr>
		<td  >도자기</td>
		<td  >스토브</td>  
		<td  ></td>  		
	</tr>	
	<tr>
		<td  >원목제품</td>
		<td  >나무,금속 봉,판 등</td>  
		<td  ></td>  		
	</tr>	
	<tr>
		<td  >가구등</td>
		<td  ></td>  
		<td  ></td>  		
	</tr>	
	</table>
	
	<p class="level-3">※위 품목은 특성상 파손 위험이 높아 택배사 및 통관사의 보상 대상에서 제외될 수 있으며
 NIPPON BUY 역시 동일 기준을 적용합니다.</p>
<br> 
<p class="level-3 fontsize-bold22">③ 보상 한도</p> 
<p class="level-3" >보험 미가입 화물의 보상은</p> 
<p class="level-3" ><span class="fontsize-bold18">Invoice(상품 구매금액) 기준으로 주문서 1건당 최대 20,000엔까지</span> 보상됩니다. </p> 
<p class="level-3">※ 관세 및 부가세는 보상 대상에 포함되지 않습니다.</p> 

<br>
<p class="level-2 fontsize-bold22">3. 분실 보상 기준</p>
<p class="level-3" >분실은 발생 시점에 따라 아래 기준으로 처리됩니다.</p> 

<p class="level-3 fontsize-bold22">① NIPPON BUY 입고 전 분실</p> 
<p class="level-3 fontsize-bold18">(일본 판매처 → NIPPON BUY 입고 전)</p> 
<p class="level-4" >예)  일본 택배사 배송 중 분실,</p> 
<p class="level-4" >   배송완료로 표시되었으나 NIPPON BUY에서 입고 확인이 되지 않는 경우</p> 
<p class="level-4" >  → 일본 운송사의 조사 결과를 기준으로 처리됩니다.</p> 
<p class="level-4" >  → NIPPON BUY 책임이 확인되지 않는 경우 보상 대상이 아닙니다.</p> 

<br> 
<p class="level-3 fontsize-bold22">② NIPPON BUY 입고 후 분실</p> 
<p class="level-3 fontsize-bold18">(NIPPON BUY 입고 스캔 완료 이후 출고 전)</p> 
<p class="level-4" >  예) 입고 스캔 이력이 있으나 화물이 분실된 경우</p> 
<p class="level-4" >  → NIPPON BUY 책임으로 처리됩니다.</p> 

<br> 
<p class="level-3 fontsize-bold22">③ NIPPON BUY 출고 후 분실</p> 
<p class="level-3" >(NIPPON BUY 출고 이후 고객 수령 전)</p> 
<br>
<p class="level-4">  예) 국제배송 중 분실</p> 
<p class="level-4">  → 통관사, 택배사 사고조사 후 처리됩니다.</p> 

<br>
<p class="level-2 fontsize-bold22">4. 파손 보상 신청 (보험 미가입시)</p>	
<p class="level-3" >파손이 발생한 경우에는 <span class="is-red">상품 수령 후 7일 이내</span></p>
<p class="level-3" >아래 자료를 제출하여 주시기 바랍니다.</p>
<br>
<p class="level-3 fontsize-bold18">제줄자료</p>
<p class="level-4">✔ 박스 전체 사진 (앞면 / 뒷면 / 좌측 / 우측 / 상단 / 하단)</p>
<p class="level-4">✔ 파손 부위 사진</p>
<p class="level-4">✔ 파손 부위 근접 사진</p>
<p class="level-4">✔ 내부 포장 상태 사진</p>
<p class="level-4">✔ 운송장(송장) 사진</p>
<p class="level-4">✔ 구매내역(Invoice)</p>
<p class="level-4">※ 아래 **「파손 사진 촬영 가이드」**를 참고하여 촬영해 주시기 바랍니다.</p>

<img src="<%= ctx %>/images/help/regulation_guide.png" style='width:100%'/>

<p class="level-4">※ 제출자료가 부족한 경우에는 운송사 및 보험사의 사고조사가 불가능하여 보상이 제한될 수 있습니다.</p>

<br>
<p class="level-2 fontsize-bold22">5.최종 보상 판단</p>	
<p class="level-3" >모든 보상은 아래 자료를 종합적으로 검토하여 최종 결정됩니다.</p>	
<p class="level-3" >또한, 심사기간은 1주일 가량 기간이 소요 될 수 있습니다.</p>	
<p class="level-4" >· 입고 사진</p>	
<p class="level-4" >· 작업 기록</p>	
<p class="level-4" >· CCTV</p>	
<p class="level-4" >· 운송장 정보</p>	
<p class="level-4" >· 포장 상태</p>	
<p class="level-4" >· 운송사 조사 결과</p>	
<p class="level-4" >· 보험사 심사 결과(보험 가입 시)</p>	
<br>
<p class="level-3">    NIPPON BUY는 회원사와의 장기적인 신뢰를 가장 중요한 가치로 생각합니다. </p>	
<p class="level-3">본 규정을 기준으로 보상을 진행하되, 규정으로 판단하기 어려운 사례는 사실관계와 사고 경위를 종합적으로 검토하여 회원사와 함께 합리적인 해결방안을 찾을 수 있도록 노력하겠습니다.</p>	

<p style='float: right;'>개정 2026. 7. 1</p>	
</p></p></p></p></div>
  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
