<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jp.kurologi.model.Page, jp.kurologi.web.Html" %>
<%--
  커뮤니티 목록 하단의 페이지 번호 (공지 · 1:1 · 알림 · 특가 공용)
  쓰는 쪽(JSP)이 request 에 담아 두는 값
    pageData  : 서비스가 담은 Page 객체
    startPage / endPage : 하단에 보여줄 번호 구간
    pagerBase : 번호를 눌렀을 때 이동할 주소 (검색어가 있으면 ?searchType=..&keyword=.. 까지 포함)
--%>
<%
    Page<?> pg = (Page<?>) request.getAttribute("pageData");
    Object sp = request.getAttribute("startPage");
    Object ep = request.getAttribute("endPage");
    String base = (String) request.getAttribute("pagerBase");
    if (pg != null && sp != null && ep != null && base != null) {
        int current = pg.getPage();
        int totalPages = pg.getTotalPages();
        int startPage = (Integer) sp;
        int endPage = (Integer) ep;
        String join = base.contains("?") ? "&" : "?";
%>
<div class="pager">
<%      if (startPage > 1) { %>
  <a class="pager__item" href="<%= Html.esc(base + join + "page=" + (startPage - 1)) %>" aria-label="이전 페이지">&lsaquo;</a>
<%      } %>
<%      for (int n = startPage; n <= endPage; n++) { %>
<%          if (n == current) { %>
  <span class="pager__item is-active"><%= n %></span>
<%          } else { %>
  <a class="pager__item" href="<%= Html.esc(base + join + "page=" + n) %>"><%= n %></a>
<%          } %>
<%      } %>
<%      if (endPage < totalPages) { %>
  <a class="pager__item" href="<%= Html.esc(base + join + "page=" + (endPage + 1)) %>" aria-label="다음 페이지">&rsaquo;</a>
<%      } %>
</div>
<%  } %>
