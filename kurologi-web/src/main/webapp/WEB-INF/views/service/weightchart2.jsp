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
<title>국제배송비 안내 | NIPPON BUY</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from weightchart2.css */
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
   NIPPON BUY — 국제배송비 안내 페이지
   이 파일만 고치면 이 페이지 디자인이 바뀌니다.
   ========================================================================== */


/* 요율표는 가로로 매우 넓습니다. 좁은 화면에서도 잘리지 않게 스크롤을 허용 */
.rate-scroll {
  width: 100%;
  margin-bottom: 24px;
  overflow-x: auto;
}

/* 요율표 글자를 촘촘하게 */
.rate-table {
  min-width: 900px;
  border-collapse: collapse;
  border-top: 2px solid var(--teal-line);
}
.rate-table th,
.rate-table td {
  padding: 6px 4px;
  font-size: 12px;
  text-align: center;
  vertical-align: middle;
  border: 1px solid var(--line-table);
  white-space: nowrap;
}
.rate-table th { font-weight: 700; background: var(--fill-th); }
.rate-table td { background: #fff; }

/* 왼쪽 첫 칸(중량)은 강조 */
.rate-table td:first-child,
.rate-table th:first-child { background: #eef7f7; font-weight: 700; }

/* 센터 선택 버튼 줄 */
.center-picker { margin-bottom: 20px; }
.center-picker a { margin-right: 6px; }

/* 부피무게 안내 그림 */
.weight-info { margin: 10px 0 20px; }
.weight-info img { display: block; margin: 0 auto; }

/* 번호가 붙은 안내 목록 */
.guide-list {
  margin: 0 0 24px;
  padding: 0 0 0 4px;
  list-style: none;
}
.guide-list > li {
  position: relative;
  margin: 8px 0;
  padding-left: 22px;
  font-size: 14px;
  line-height: 1.8;
}
.guide-list > li::before {
  content: attr(data-no);
  position: absolute;
  left: 0;
  font-weight: 700;
  color: var(--teal);
}
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<!-- 페이지 제목 + 현재 위치 -->
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">국제배송비 안내</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/service/info_company">서비스안내</a></li>
      <li class="breadcrumb__item is-current">국제배송비 안내</li>
    </ol>
  </div>
</section>

<main class="page-body">
  <div class="container">
<h4>국제배송비 안내</h4>
	<p class="spaced-bottom">
	1.	모든 국제 배송비용은 실제 물류센터에 도착하는 물건에 대해 중량과 크기를 통해 정해집니다.<br/>
	
	2.	항공-도쿄(JP)화물의 무게 단위는 Kg입니다.   1kg= 2.204623lbs<br/>
	
	3.	요율표의 배송비는 항공운송비용과 “NIPPON BUY 물류시스템”의 서비스 비용이 포함된 금액입니다.<br/>
	4.	수입시 발생되는 관세, 부가세는 고객님이 납부하셔야 통관이 완료되고, 국내 배송이 진행됩니다.<br/>
	5.	최소중량은 
	0.5 kg 이며, 0.5단위로 절상합니다 (예: 2.1 kg 는 2.5 kg로 청구됩니다)
	<br/>
	6.  중량산정<br/>
	   ㅇ 항공배송 :  <span class="fontcolor_blue">실제무게와 부피무게 중에 높은쪽으로 계산</span>됩니다.(<span class="fontcolor_blue">회원등급별 차등 적용</span>).<br/> 
	                        부피무게 측정방법은 가로 X 세로 X 높이 /6000 (항공사 청구 기준)<br/>
      ㅇ 해상배송 : <span class="fontcolor_blue">부피무게 미적용으로 실중량으로 계산</span>됩니다 (단, 부피무게 68Kg이상인 경우는 부피무게가 적용됨)<br/>

	
	
	7.	국제 운송료 외에 부가 서비스 비용이 발생할 수 있습니다. (추가 수수료  안내 참조)<br/>
	8.	항공, 해상 모두 <span class="fontcolor_blue">아래 기준 이상의 대형화물의 경우 일반택배 배송이 불가하며,)<br/>
       화물택배사로. 인계되며, 추가요금이 부과</span>됩니다.<br/> 
       <span class="class="center t700">ㅇ 대형화물 기준 (1가지 이상 해당시 적용)</span><br/>
	   ① 한변 100cm 이상    ② 세변의 합 160cm 이상     ③ 중량 25kg 이상)<br/>
	
	

				
	</p>
	<h3>실무게/부피무게 적용기준</h3>
	<h3 class="is-bold" ><img src="<%= ctx %>/images/common/air_icon_red.jpg" style="width:50px"><img src="<%= ctx %>/images/common/no_ship_icon_red.jpg" style="width:50px">
	(※항공만 적용, 해상은 부피무게 68Kg이상인 경우 적용) 
	</h3>
	<dl class="note-block">
							
	<dd>
	중량무게와 부피무게중 큰쪽의 무게를 적용
	
	
	<b>* 부피무게 구하는 공식 (기본 단위: 센티 )</b><br />
	<span class="bold">가로(W) x 세로(L) x 높이(H) / 6000 = 부피무게</span><br>
	<img src="<%= ctx %>/images/help/weightinfo.png" style="padding:0 30px 0 30px;"/><br>
	</dd>
	</dl>

	<table class="data-table rate-table">
		<tr>
			<th >회원등급</th>
			<th class="is-bold text-h3" >베이직(Basic)</th>
			<th class="is-bold text-h3">파트너(Partner)🌟인기!</th>
			<th class="is-bold text-h3">패밀리(Family)</th>
		</tr>
		<tr>
			<td class="is-bold text-h3">부피무게 적용<br>(예 - 실중량 0.5kg,<br>부피무게 2kg일때)</td>
			<td  style='font-weight:bold;font-size:16px;' colspan='1'><span class="fontcolor_blue">50%</span><br/>
			(예 - 부피무게 2kg의 50%인 <span class="is-red">1kg 적용</span>)</td>
			<td  style='font-weight:bold;font-size:16px;' colspan='2'><span class="fontcolor_blue">부피무게 미적용(실중량 적용)</span><br>
			(예- <span class="is-red">중량 0.5kg만 적용</span>)<br>
			단, 부피무게 12kg 이상 <span class="fontcolor_blue">대형화물은<br>
			부피무게 50% 적용</span>
			</td>
		</tr>
	</table>

	

	
		<%
    // 센터 선택 : ?center=air | sea1 | sea2  (그 밖의 값은 항공-도쿄)
    String center = request.getParameter("center");
    if (!"sea1".equals(center) && !"sea2".equals(center)) {
        center = "air";
    }
    String centerName = "sea1".equals(center) ? "해상-후쿠오카 제1센터(JP)" : "해상-후쿠오카 제2센터(JP)";
%>
	<div id="rate-table"></div>
		<a class="link-btn<%= "air".equals(center) ? " link-btn--active" : "" %>" href="<%= ctx %>/service/weightchart2?center=air#rate-table"><strong>항공-도쿄(JP)</strong></a>
		<a class="link-btn<%= "sea1".equals(center) ? " link-btn--active" : "" %>" href="<%= ctx %>/service/weightchart2?center=sea1#rate-table"><strong>해상-후쿠오카 제1센터(JP)</strong></a>
		<a class="link-btn<%= "sea2".equals(center) ? " link-btn--active" : "" %>" href="<%= ctx %>/service/weightchart2?center=sea2#rate-table"><strong>해상-후쿠오카 제2센터(JP)</strong></a>
<% if ("air".equals(center)) { %>
	 <table class="data-table data-table--vertical rate-table">
		
		<tr class="hidden-xs" >
			<th >회원등급</th>			
			
			<th class="text-h2">
				베이직 (BASIC)
			</th>
			
			<th class="text-h2">
				파트너 (Partner)
			</th>
			
			<th class="text-h2">
				패밀리 (Family)
			</th>
			
		</tr>		
		
		
		<tr>
			<td class="fontcolor_blue text-h2" data-th='무게(Kg)' >0.50 (Kg)</td>
			
			<td class="fontcolor_blue text-h2" data-th='베이직 (BASIC)'>

			￥720 </td>

			
			<td class="fontcolor_blue text-h2" data-th='파트너 (Partner)'>

			￥690 </td>

			
			<td class="fontcolor_blue text-h2" data-th='패밀리 (Family)'>

			￥670 </td>

			
		</tr>
		
		<tr>
			<td class="fontcolor_blue text-h2" data-th='무게(Kg)' >1.00 (Kg)</td>
			
			<td class="fontcolor_blue text-h2" data-th='베이직 (BASIC)'>

			￥820 </td>

			
			<td class="fontcolor_blue text-h2" data-th='파트너 (Partner)'>

			￥790 </td>

			
			<td class="fontcolor_blue text-h2" data-th='패밀리 (Family)'>

			￥770 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >1.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥940 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥900 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥870 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >2.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥1,050 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥1,010 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥970 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >2.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥1,150 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥1,120 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥1,070 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >3.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥1,280 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥1,230 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥1,190 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >3.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥1,410 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥1,360 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥1,300 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >4.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥1,540 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥1,480 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥1,420 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >4.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥1,670 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥1,600 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥1,540 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >5.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥2,060 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥1,980 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥1,900 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >5.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥2,160 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥2,080 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥2,000 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >6.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥2,260 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥2,180 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥2,090 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >6.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥2,370 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥2,280 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥2,190 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >7.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥2,470 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥2,380 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥2,290 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >7.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥2,570 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥2,470 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥2,380 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >8.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥2,670 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥2,570 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥2,470 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >8.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥2,780 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥2,680 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥2,570 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >9.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥2,880 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥2,770 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥2,670 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >9.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥2,980 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥2,870 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥2,760 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >10.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥3,090 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥2,980 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥2,860 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >10.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥3,600 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥3,470 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥3,340 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >11.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥3,710 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥3,570 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥3,440 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >11.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥3,830 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥3,680 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥3,540 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >12.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥3,930 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥3,790 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥3,640 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >12.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥4,040 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥3,890 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥3,740 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >13.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥4,330 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥4,170 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥4,010 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >13.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥4,470 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥4,310 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥4,140 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >14.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥4,620 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥4,440 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥4,270 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >14.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥4,760 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥4,580 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥4,400 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >15.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥4,900 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥4,720 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥4,540 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >15.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥5,040 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥4,850 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥4,670 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >16.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥5,180 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥4,990 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥4,800 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >16.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥5,320 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥5,130 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥4,930 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >17.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥5,470 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥5,260 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥5,060 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >17.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥5,610 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥5,400 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥5,190 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >18.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥5,750 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥5,540 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥5,320 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >18.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥5,890 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥5,670 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥5,450 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >19.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥6,030 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥5,810 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥5,590 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >19.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥6,170 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥5,950 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥5,720 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >20.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥6,320 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥6,080 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥5,850 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >20.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥6,460 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥6,220 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥5,980 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >21.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥6,600 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥6,360 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥6,110 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >21.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥6,740 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥6,490 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥6,240 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >22.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥6,880 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥6,630 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥6,370 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >22.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥7,020 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥6,760 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥6,500 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >23.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥7,170 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥6,900 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥6,640 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >23.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥7,310 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥7,040 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥6,770 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >24.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥7,450 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥7,170 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥6,900 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >24.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥7,590 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥7,310 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥7,030 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >25.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥7,730 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥7,450 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥7,160 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >25.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥7,880 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥7,580 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥7,290 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >26.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥8,020 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥7,720 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥7,420 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >26.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥8,160 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥7,860 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥7,550 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >27.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥8,300 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥7,990 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥7,690 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >27.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥8,440 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥8,130 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥7,820 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >28.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥8,580 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥8,270 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥7,950 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >28.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥8,730 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥8,400 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥8,080 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >29.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥8,870 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥8,540 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥8,210 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >29.50 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥9,010 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥8,680 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥8,340 </td>

			
		</tr>
		
		<tr>
			<td  data-th='무게(Kg)' >30.00 (Kg)</td>
			
			<td  data-th='베이직 (BASIC)'>

			￥9,150 </td>

			
			<td  data-th='파트너 (Partner)'>

			￥8,810 </td>

			
			<td  data-th='패밀리 (Family)'>

			￥8,470 </td>

			
		</tr>
										

		</table>

		
		<div  class="is-red">※ 30kg초과시 배송불가</div>
<% } else { %>
	<p class="center-empty"><%= centerName %>의 국제배송비 요율표는 준비 중입니다.</p>
<% } %>
  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
