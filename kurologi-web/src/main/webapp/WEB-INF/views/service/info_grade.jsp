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
<title>회원등급, 수수료 안내 | NIPPON BUY</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from info-grade.css */
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
.center-empty { margin: 14px 0 24px; padding: 48px 16px; text-align: center; font-size: 16px; color: #666; background: #fafafa; border: 1px dashed #bbb; border-radius: 6px; }
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
   NIPPON BUY — 회원등급, 수수료 안내 페이지
   이 파일만 고치면 이 페이지 디자인이 바뀌니다.
   ========================================================================== */


/* 개정 안내 문구 */
.grade-notice {
  margin: 0 0 20px;
  font-size: 15px;
  text-align: center;
  color: var(--ink);
}

/* 등급 표는 값이 많아 글자를 조금 줄이고 칸 여백을 좁힙니다 */
.grade-table th,
.grade-table td {
  padding: 10px 6px;
  font-size: 13px;
  line-height: 1.6;
}

/* 표 안 등급 아이콘 */
.grade-table img {
  display: inline-block;
  max-width: 100px;
  margin: 2px;
  vertical-align: middle;
}

/* 표 아래 안내 목록 */
.grade-notes {
  margin: 20px 0 0;
  padding: 0;
  list-style: none;
}
.grade-notes li {
  padding: 6px 0 6px 14px;
  font-size: 13px;
  line-height: 1.8;
  border-bottom: 1px dashed var(--line);
}
.grade-notes li:last-child { border-bottom: 0; }
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<!-- 페이지 제목 + 현재 위치 -->
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">회원등급, 수수료 안내</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/service/info_company">서비스안내</a></li>
      <li class="breadcrumb__item is-current">회원등급, 수수료 안내</li>
    </ol>
  </div>
</section>

<main class="page-body">
  <div class="container">
<div>
	<h4>회원등급,수수료</h4>
	<span style='float:right'>2026.03.30일 개정</span>
	</div>
	<table class="data-table grade-table">
	<tr>
		<th >회원등급</th>
		<th  style="width:120px" >적용 서비스</th>
		<th class="is-bold text-h3">베이직(Basic)</th>
		<th class="is-bold text-h3">파트너(Partner)</th>
		<th class="is-bold text-h3">패밀리(Family)</th>
		<th class="is-bold text-h3">로얄패밀리<br>(Royal Family)</th>		
	</tr>
	
	<tr>
		<td class="is-bold text-h3" style='background-color:#F3E2A9;'>월 이용료</td>
		<td class="is-bold text-h3" style='background-color:#F3E2A9'><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"></td>
		<td class="is-bold text-h3" style='background-color:#F3E2A9;'>무료</td>
		<td class="is-bold text-h3" style='background-color:#F3E2A9;'>4,400엔/월</td>
		<td class="is-bold text-h3" style='background-color:#F3E2A9;'>8,800엔/월</td>
		<td class="is-bold text-h3" style='background-color:#F3E2A9;color:red'>무료<br><span class="text-sm">(전월 발송량 500건 이상 자동적용)</span></td>		
	</tr>
	<tr>
		<td class="is-bold text-h3" >등급마크</td>
		<td class="is-bold text-h3" style=''><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"></td>
		<td class="is-bold text-h3" ><img src="<%= ctx %>/images/grade/basic.png" style="width:30px"></td>
		<td class="is-bold text-h3" ><img src="<%= ctx %>/images/grade/partner.png" style="width:30px"></td>
		<td class="is-bold text-h3" ><img src="<%= ctx %>/images/grade/family.png" style="width:30px"></td>
		<td class="is-bold text-h3" ><img src="<%= ctx %>/images/grade/royal_family.png" style="width:30px;height:42px"></td>		
	</tr>
	
	<tr>
		<td class="is-bold text-h3">국제배송료</td>
		<td class="is-bold text-h3" style=''><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"></td>
		<td  style='font-weight:bold;font-size:16px;'><span class="fontcolor_blue">베이직요율</span><br><span class="text-sm">(예: 0.5kg 해상680엔, 항공720엔)</span></td>
		<td  style='font-weight:bold;font-size:16px;'><span class="fontcolor_blue">파트너요율</span><br><span class="text-sm">(예: 0.5kg 해상650엔, 항공690엔)</span></td>
		<td  style='font-weight:bold;font-size:16px;'><span class="fontcolor_blue">패밀리요율</span><br><span class="text-sm">(예: 0.5kg 해상630엔, 항공670엔)</span></td>
		<td  style='font-weight:bold;font-size:16px;'><span class="is-red">패밀리요율과 동일</span></td>		
	</tr>
	<tr>
		<td class="is-bold text-h3">부피무게 적용<br>(예 - 실중량 0.5kg,<br>부피무게 2kg일때)</td>
		<td class="is-bold text-h3" style=''>
			<img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px">
			<img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px">
		</td>
		<td  style='font-weight:bold;font-size:16px;' colspan='1'>
		<img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><span class="fontcolor_blue">항공:</span><span style='color:red;'>50%만 적용</span>		
		<br>(예 - 부피무게 1kg 적용)<br>
		<img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px">
		<span class="fontcolor_blue">해상 :<span class="fontcolor-red">부피무게 미적용</span></span>
		
		</td>
		<td  style='font-weight:bold;font-size:16px;' colspan='3'>
		<img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><span class="fontcolor_blue">항공:</span><span style='color:red;'>부피무게 미적용</span>		
		<br>(예- 실중량 0.5kg만 적용)
		<br>단, 부피무게 12kg 이상 <span class="fontcolor_blue">대형화물은 부피무게 50% 적용</span>		
		<br><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"><span class="fontcolor_blue">해상 :<span class="fontcolor-red">부피무게 미적용</span></span>
		</td>
	</tr>

	<tr>
		<td class="is-bold text-h3">쿠팡그로스로 직배송<br>바코드 출력/ 작업<br><span class="fontcolor_blue">(기본료 330엔/건)</span><br><span class="is-red">한시적 무료!</span></td>
		<td class="is-bold text-h3" style=''><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"></td>
		<td  style='font-weight:bold;font-size:16px;'><span class="fontcolor_blue">30엔/1장</span></td>
		<td  colspan='3' style='font-weight:bold;font-size:16px;' ><span class="fontcolor_blue">20엔/장</span></td>		
	</tr>

	
	<tr>
		<td class="is-bold text-h3">구매대행수수료</td>
		<td class="is-bold text-h3" style=''><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"></td>
		<td  style='font-weight:bold;font-size:16px;'><span class="fontcolor_blue">2%</span></td>
		<td  style='font-weight:bold;font-size:16px;'><span class="fontcolor_blue">무료</span></td>
		<td  style='font-weight:bold;font-size:16px;'><span class="fontcolor_blue">무료</span></td>
		<td  style='font-weight:bold;font-size:16px;'><span class="fontcolor_blue">무료</span></td>		
	</tr>
	
	
	<tr>
		<td class="is-bold text-h3">합/나눔배송</td>
		<td class="is-bold text-h3" style=''>
			<img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px">
			<img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px">
		</td>
		<td class="is-bold" colspan='4'>
		ㅇ 합배송 수수료  : 주문서 1건당<br> 
		- 3종류 까지 => <span style='color:red'>무료</span><br> 
		- 4종류 이상 => <span style='color:red'>50엔 추가/상품종류당</span> (기준 : 주문서 등록상품 번호, 트레킹수 상관 없이 적용)<br> 
	    예) 주문번호 73421번에 상품번호가 5번까지 있는경우 : 합배송 수수료 => 100엔 (50엔 x 2종류)<br><br>
		ㅇ 나눔배송 => <span style='color:red'>무료</span></td>
	</tr>
	<tr>
		<td class="is-bold text-h3">납품서,청구서,기타 구성품 제거</td>
		<td class="is-bold text-h3" style=''><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"></td>
		<td  colspan='4'><span style='color:red'>무료 서비스</span><br>
		※ 무료서비스 이므로 문제발생시 책임 및 보상을 하지 않습니다.		
		</td>
	</tr>
	<tr>
		<td class="is-bold text-h3">기본검수<span class="is-red">(※보상불가)</span></td>
		<td class="is-bold text-h3" style=''><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"></td>
		<td  colspan='4'>
		<span style='color:red'>무료 서비스　 (※품명, 품번, 옵션명을 기입된 정보로 간단 확인 후 발송, 이미지의 차이는 대상 아님)</span><br>
		<span class="is-bold" style='background:yellow;'>※ 무료서비스 이므로 문제발생시 책임 및 보상을 하지 않습니다.</span><br>
		<span class="is-bold is-red" >※주의! 보상불가 </span><br>
	    분리배송화물중 일부만 주문서(트레킹입력)를 작성하여, 주문서 미작성(트레킹 미입력) 제품이 함께 오발송 된경우. <br>
		=> <span class="is-bold is-red">반드시 동일 트레킹화물 제품은 같은 타이밍에 주문서 작성필수! </span>(작업자가 인지 못하고 오배송 가능성 높습니다)
		</td>
	</tr>
	<tr>
		<td class="is-bold text-h3">상세사진검수<span class="is-red">(※보상가능)</span></td>
		<td class="is-bold text-h3" style=''><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"></td>
		<td  colspan='4'>330엔/제품당(100사이즈 이하만 가능, 대형사이즈 불가) <br>
		<span class="fontcolor_blue">※ 제품 상세사진은 1:1 문의로 제공</span><br>
		<span class="is-bold is-red">※검품 오배송 걱정되시는 건은 상세사진검수 이용요망</span>

		</td>
	</tr>
	<tr>
		<td class="is-bold text-h3">재고 보관료</td>
		<td class="is-bold text-h3" style=''><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/no_ship_icon_red.png" style="width:30px"></td>
		<td  colspan='4'>
		<span style='color:red'>ㅇ 입고후 30일간 : 무료</span><br><br>
		ㅇ 31일 부터 아래와 같이 일단위 차감 (※사이즈 기준 : 보관단위 박스사이즈)<br>
       - 40사이즈 이하.  : <span class="fontcolor_blue">20엔/1일</span><br>
       - 41~80사이즈    : <span class="fontcolor_blue">40엔/1일</span><br>
       - 81~120사이즈.   : <span class="fontcolor_blue">80엔/1일</span><br>
       - 121~ 160사이즈 : <span class="fontcolor_blue">160엔/1일</span><br>
       - 160사이즈~         :  <span class="fontcolor_blue">※재고보관 불가</span><br><br>
		【월 단위 선반 계약 (상시 재고보관용) 】<br>
		- 선반 1단 (1단/ 사이즈:150x45cmx40Cm)   : <span class="fontcolor_blue">3,300엔/월</span><br>
        - 선반 1대 (4단/ 사이즈:150x45cmx180Cm) : <span class="fontcolor_blue">9,900엔/월</span><br>
		※ 계약선반은 계약후에는 사용유무와 관계없이 매월(1일) 예치금에서 차감됩니다.<br>
		1개월단위 계약으로 해약월은 월말까지 과금됩니다.<br>
		※ 신청방법 : 반드시 아래 메일로 계약 희망 내용을 보내주시기 바랍니다.  (※1:1 문의로는 적용되지 않습니다)<br>
		메일주소 : support@nipponbuy.jp <br><br>
		※ 재고보관은 160사이즈 이하만 가능
	 </td>
	</tr>
	<tr>
		<td class="is-bold text-h3">재고 입고,관리비 (재고 보관시)</td>
		<td class="is-bold text-h3" style=''><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"></td>
		<td  colspan='4'><span class="fontcolor_blue">제품당 20엔/개</span>  (종류와 상관없이, 개수적용.  <span class="is-red">※재고등록 제품만 적용됩니다</span>) 
		</td>
	</tr>
	<tr>
		<td class="is-bold text-h3">멀티박스 추가요금</td>
		<td class="is-bold text-h3" style=''><img src="<%= ctx %>/images/common/air_icon_red.png" style="width:30px"><img src="<%= ctx %>/images/common/ship_icon_red.png" style="width:30px"></td>
		<td  colspan='4'><span class="fontcolor_blue">추가 280엔/박스당</span> 
		</td>
	</tr>		
	</table>
	
	

	<p>・각 등급별 월 이용료는 매월 1일 12시(정오)에 예치금에서 자동 차감됩니다.</p>
	<p>・경우에 따라 각종 수수료 등은 변경 될 수 있으며, 변경 되는 경우에는 사전에 공지하도록 하겠습니다.</p>
	<p>・수수료는 세금포함(税込) 금액입니다.</p>
	<p>・문의사항은 1:1게시판으로 연락 바랍니다.</p>
	<br>
	<%
    // 센터 선택 : ?center=air | sea1 | sea2  (그 밖의 값은 항공-도쿄)
    String center = request.getParameter("center");
    if (!"sea1".equals(center) && !"sea2".equals(center)) {
        center = "air";
    }
    String centerName = "sea1".equals(center) ? "해상-후쿠오카 제1센터(JP)" : "해상-후쿠오카 제2센터(JP)";
%>
	<h4 id="extra-fee">추가 수수료 안내</h4>

	<div>
		<a class="link-btn<%= "air".equals(center) ? " link-btn--active" : "" %>" href="<%= ctx %>/service/info_grade?center=air#extra-fee"><strong><img src="<%= ctx %>/images/common/air_icon_red.png" style='width:30px'>  항공-도쿄(JP)</strong></a>
		<a class="link-btn<%= "sea1".equals(center) ? " link-btn--active" : "" %>" href="<%= ctx %>/service/info_grade?center=sea1#extra-fee"><strong><img src="<%= ctx %>/images/common/JP_Sea.png" style='width:30px'>  해상-후쿠오카 제1센터(JP)</strong></a>
		<a class="link-btn<%= "sea2".equals(center) ? " link-btn--active" : "" %>" href="<%= ctx %>/service/info_grade?center=sea2#extra-fee"><strong><img src="<%= ctx %>/images/common/JP_Sea2.png" style='width:30px'>  해상-후쿠오카 제2센터(JP)</strong></a>
	</div>
<% if ("air".equals(center)) { %>
	<table class="data-table grade-table">
		<tr>
			<th >수수료</th>
			<th >비용</th>
		</tr>
		
			<tr>
				<td >1)적정 박스 재포장비 (박스비 포함)</td>
				<td><span class="fontcolor_blue">적정 박스로 재포장 (※파손방지, 송료절감 위해 NIPPON BUY 판단후 필요시 실시) </span><br>
				ㅇ 80사이즈 이하 : <span class="fontcolor_blue">80엔</span><br>
				ㅇ 81~100사이즈 이하 : <span class="fontcolor_blue">180엔</span><br>
				ㅇ 101사이즈 이상 : <span class="fontcolor_blue">330엔</span><br>
				ㅇ 161이상 사이즈 : <span class="fontcolor_blue">별도견적</span><br>				
				※ 적정 박스 재포장 ☑ 체크를 삭제하면 추가없음. 단, 불가피할시 NIPPON BUY가 체크후 실시.<br>
				※ 파손가능성 있는 봉투입고시, 나눔배송시 ☑ 체크 상관없이 무조건 실시(필수)<br>
				※ 신발류 등 일부제품은 부피무게를 줄이기 위해 전용 크래프트 택배봉투로 재포장.<br>
				※ 환경을 위해 깨끗한 재활용 박스를 사용하는 경우도 있습니다.
				</td>
			</tr>
			<tr>
			<td >2)추가 완충제</td>
			<td>사이즈에 따라 차등적용 <br>
			ㅇ ~ 80사이즈 까지 : <span class="fontcolor_blue">110엔</span><br>
			ㅇ 81~100사이즈     : <span class="fontcolor_blue">220엔</span><br>
			ㅇ 101~160사이즈   : <span class="fontcolor_blue">440엔</span><br>
			ㅇ 161사이즈~ : 작업 불가  <br>
			※ 사이즈 기준 : 가로(cm) + 세로(cm) + 높이(cm) 의 합

			</td>
			</tr>
			<tr>
			<td >3)박스성형 수수료 <span style='color:red;font-weight:bold;'>(※적용가능 건만 실시, 과금)</span></td>
				<td><span class="fontcolor_blue">220엔</span>(※ 골프채 등, 100Cm 미만으로 박스성형이 가능한 경우 실시)

			</td>
			</tr>

			<tr>
			<td >4)관부가세 대납 수수료</td>
				<td><span class="fontcolor_blue">220엔</span>(※ 관부가세는 니폰바이가 대납하고 예치금 차감)

			</td>
			</tr>
			<tr>
			<td >5)수화인 정보 변경 수수료 (출고일 15시 이후 요청시)	</td>
				<td><span class="fontcolor_blue">330엔</span>  (※변경서류가 필요, 적하목록 정정신고시 과태료 추가될 수 있습니다.)
			</td>
			</tr>
			<tr>
			<td >6)일반통관 수수료</td>
				<td>100엔 ->  <span style='color:red;font-weight:bold;'>무료(기간 한정)</span>
			</td>
			</tr>
			<tr>
			<td >7)사업자통관 수수료</td>
				<td><span class="fontcolor_blue">1,100엔</span> <span style='color:red;font-weight:bold;'> (사업자 통관 신청방법 >>> <a href='https://nipponbuy.jp/service/business-customs
' target='_blank'> 확인</a>)</span>	
			</td>
			</tr>
			
						
			<tr>
			<td >8) 수출통관 수수료 (신고가 20만엔 이상시) 수수료</td>
				<td><span class="is-red">※ 20만엔이상 화물 수탁, 발송 불가</span> (후쿠오카 해상 이용해 주세요!)</td>
			</tr>
			
			
			<tr>
			<td >9)일본내 전화 서비스</td>
				<td>
				<span class="fontcolor_blue">ㅇ 대리 전화서비스</span><br>
				<span class="fontcolor_blue">220엔/한통 </span><br>
					 (※ 전화 -일본 현지 구매숍, 매장 등 전화연락이 필요한 경우)<br><br>
					 
				<span class="fontcolor_blue">ㅇ 대리 계좌이체</span><br>
				<span class="fontcolor_blue">400엔 / 한건</span>  (니폰바이 수수료 220엔 + 은행 이제 수수료 180엔)<br>
				(배송대행 물품 구매 후 추가 금액이 발생하는 경우 이용가능)<br>
				<span class="is-red">(※ 주의 : 물품 구매 목적으로 계좌이체 서비스 이용 불가!!)</span>
				
			</td>
			</tr>
			<tr>
			<td >10) 수출 증빙서류 (수출허가서) 발행</td>
				<td>
				<span class="fontcolor_blue">ㅇ 30건까지 :  무료 (1달기준)</span><br>
				<span class="fontcolor_blue">ㅇ 31건째 부터 : 10엔/건당</span><br>
				(※ 각 건별 수출허가서를 PDF파일로 제공해 드립니다. 주문번호로 파일명 검색 가능)
			</td>
			</tr>
			<tr>
			<td >11) 대형화물 추가 송료
			
			      <br><span class="fontcolor-red">※회원등급 상관없이 발생 (한국도착후 발생)</span>

			</td>
				<td>
				<span class="fontcolor_blue">약 900엔 ~</span><br>
				(화물의 사이즈와 무계에 따라 청구 금액이 상이합니다. – 실비청구)  <br>
				대형화물의 경우  <span class="fontcolor_blue">[경동택배], [대신택배]로 인계되어 배송</span>하게 되며 추가 <br>
				비용이 발생<br>
				※ 달러->엔 청구로 환율에 의해 매월 금액이 변동됩니다.<br>
				<br>
				<span style='font-weight:bold;'>ㅇ 대형화물 기준 (1가지 이상 해당시 적용)<br>
				① 한변 100cm 이상    ② 세변의 합 160cm 이상     ③ 중량 25kg 이상</span><br>
				<br>
				<span style='font-weight:bold;'>■ 청구방법 및 타이밍</span> (대형화물, 기타 추가비용 공통)<br>
		     월말 마감후 익월 10일까지 상세내역을 메일로 보내드린 후 예치금 차감<br>
		     (바쁜 시기에는 청구가 늦어 질 수 있습니다.) 
			</td>
			</tr>
			<tr>
			<td ><span class="fontcolor_blue">12) 기타 추가 비용</span></td>
				<td>
				ㅇ 동물/식품검역 : 약 440엔/건<br>
 ㅇ 폐기(세관 통관불합격) : 약 1,000엔/건 <br>
 ㅇ 반송/ 재배송 (주소미확인) : 약 440엔/건<br>
  　※ 달러->엔 청구로 환율에 의해 매월 금액이 변동됩니다. 

			</td>
			</tr>
			
										
	</table>
<% } else { %>
	<p class="center-empty"><%= centerName %>의 추가 수수료 안내는 준비 중입니다.</p>
<% } %>
  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
