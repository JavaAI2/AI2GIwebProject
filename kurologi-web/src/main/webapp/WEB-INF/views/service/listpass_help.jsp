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
<title>목록통관 품목안내 | NIPPON BUY</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Lato:wght@400;600;700&display=swap" rel="stylesheet">
<style>
/* inlined from listpass-help.css */
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
   NIPPON BUY — 목록통관 품목안내 페이지
   이 파일만 고치면 이 페이지 디자인이 바뀝니다.
   ========================================================================== */


/* 도입 설명 */
.listpass-intro {
  margin: 0 0 24px;
  font-size: 14px;
  line-height: 1.9;
  color: var(--body);
}

/* 품목 표: 좌우 2단 구성이라 글자를 줄이고 왼쪽 정렬 */
.listpass-table th,
.listpass-table td {
  padding: 10px 8px;
  font-size: 12px;
  line-height: 1.7;
  text-align: left;
}
.listpass-table th { text-align: center; }

/* 링크형 버튼 줄 */
.listpass-links { margin: 20px 0; }

/* 강조 문구 */
.listpass-strong {
  font-weight: 700;
  color: var(--red);
}
</style>
</head>
<body>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="top" /></jsp:include>
<!-- 페이지 제목 + 현재 위치 -->
<section class="page-head">
  <div class="container page-head__inner">
    <h1 class="page-head__title">목록통관 품목안내</h1>
    <ol class="breadcrumb">
      <li class="breadcrumb__item"><a href="<%= ctx %>/">홈</a></li>
      <li class="breadcrumb__item"><a href="<%= ctx %>/service/info_company">서비스안내</a></li>
      <li class="breadcrumb__item is-current">목록통관 품목안내</li>
    </ol>
  </div>
</section>

<main class="page-body">
  <div class="container">
<h4>목록통관 품목이란?</h4>
		<p>2012년 3월 15일 한미FTA 발효 후 변경되는 면세기준(목록통관)에 대해 안내드립니다.<br />안내되는 내용은 협력 관세사 및 관세청 문의를 통해 FTA협정문을 재해석한 자료이며, 관세청의 공식발표에 따라 세부적인 시행안이 변경될 수 있는 점 참고하시기 바랍니다.</p>

		<h4 class="spaced-top">한미 FTA</h4>
		<p>원산지와 관계없이 미국으로부터 출발한 특송화물로 반입되는</p>
		<p>  - <span>세관신고 가격 미화 200,00 이하</span></p>
		<p>  - <span>자가사용 물품과 상용견품</span></p>
		<p>조건에 충족하는 품목은 <span>목록통관 대상으로 관부가세가 면제</span> 됩니다.</p>

		<h4 class="spaced-top">전자상거래 업체의 목록통관 대상품목</h4>

			
                <table class="data-table listpass-table">
				<tr>
					<th>품목분류</th>
					<th>목록통관 대상품목</th>
					<th>목록통관 불가품목(세관장 확인대상)</th>
				</tr>
				<tr>
					<td>화장지, 주방용기류<br />(HS코드:48)</td>
					<td>일반화장지, 종이타올, 주방용기류(종이컵, 종이쟁반, 종이접시 등 종이 재질의 제품에 한함), 화장지, 벽지, 엽서, 편지지, 봉투, 노트류, 상자, 신문</td>
					<td>물휴지, 일회용기저귀, 생리대 등</td>
				</tr>
				<tr>
					<td>서적, 인쇄물류<br />(HS코드:49)</td>
					<td>책, 신문, 잡지, 악보, 캘린더, 기타 인쇄물</td>
					<td>음란서적, 1만불이상의 지급수단(수표, 유가증권)등</td>
				</tr>
				<tr>
					<td>의류<br />(HS코드:61~63)</td>
					<td>외투, 바지, 셔츠, 수영복, 양말, 100%면장갑, 운동복, 넥타이, 속옷, 스카프, 모포, 텐트, 커튼, 100% 면벨트, 기타 방직용 섬유제품</td>
					<td>가죽류(가죽소재가 포함된 제품), 모피류, 스포츠용 구명복, 잠수복, 우비, 유아용 캐리어, 모자류, 스포츠용 장갑, 코팅된 기저귀커버, 인형옷, 강아지옷 등</td>
				</tr>
				<tr>
					<td>신발류<br />(HS코드:64)</td>
					<td>운동화, 부츠, 스니커즈, 구두</td>
					<td>조물제 신발, 특수용 방화 신발 등</td>
				</tr>
				<tr>
					<td>가구,조명기구류<br />(HS코드:94)</td>
					<td>의자, 책장, 테이블, 가구, 매트리스, 쿠션, 베개, 방석, 슬리핑백(침낭), 램프, 실내조명기구</td>
					<td>양탄자류, 카시트, 전기스탠드, 유아용의자, 침대, 보행기, 아동용침대, 의료용의자, 전기장판, 전기방석, 형광등기구, 휴대용전등, 랜턴 등</td>
				</tr>
				<tr>
					<td>CD,DVD류<br />(HS코드:85)</td>
					<td>음악,영상</td>
					<td>프로그램저작물, 음란물, 게임팩 등</td>
				</tr>
			</table>
			

		<p>ㆍ목록통관 대상품목이더라도 세관장 확인 대상 물품으로 분류되어 일반통관 될 수 있습니다.</p>

		<h4 class="spaced-top">목록통관 배제 품목</h4>
		<p>농림축수산물검역대상품, 의약품, 야생동물관련용품, 건강기능식품, 한약재, 지식재산권 위반의심물품, 식품류,화장품(기능성,태반함유,스테로이드제함유,성분미상화장품 등),특별통관대상업체로 지정되지 아니한 전자상거래업체가 수입하는 물품, <span>품명·규격·수량·가격이 부정확하게기재된 물품, 기타 목록통관이 타당하지 아니하다고 세관장이 인정하는 물품</span></p>

		<h4 class="spaced-top">신고방법에 따른 구분</h4>
			
                <table class="data-table listpass-table">
				<tr>
					<th colspan=2>구분</th>
					<th>현행</th>
					<th>변경(미국발 특송화물)</th>
				</tr>
				<tr>
					<td rowspan=3>신고방법</td>
					<td>목록통관</td>
					<td>$100이하</td>
					<td>물품가액 $200 이하</td>
				</tr>
				<tr>
					<td>간이신고</td>
					<td>$100~$2,000</td>
					<td>현행유지</td>
				</tr>
				<tr>
					<td>일반수입신고</td>
					<td>$2,000 초과</td>
					<td>현행유지</td>
				</tr>
				<tr>
					<td colspan=2>소액면세 기준 금액</td>
					<td>15만원</td>
					<td>$150</td>
				</tr>
			</table>
			

		<p>ㆍ<span>일반통관(간이신고,일반수입신고)물품소액면세기준금액은 현행과 동일</span>합니다.</p>
		<p>ㆍ<span>목록통관대상이지만 목록통관에서 배제(취하)되는 보류건의 관세면제 여부는 확정</span>되지 않았습니다.</p>
		<p>ㆍ<span>목록통관 품목과 일반통관 품목이 혼재한 경우 일반통관으로 분류</span>됩니다.</p>
		<p>ㆍ그 밖에 관세법 시행규칙에 따라 합산과세 등 특송물품의 통관에 관한 사항은 현행과 동일합니다.</p>
  </div>
</main>

<jsp:include page="../common/layout.jsp"><jsp:param name="part" value="bottom" /></jsp:include>
