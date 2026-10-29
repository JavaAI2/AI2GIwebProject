<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  관리자 화면 위쪽 탭 (모든 관리자 JSP 가 include 한다)
  사용 : <jsp:include page="../common/admin_tabs.jsp"><jsp:param name="current" value="home" /></jsp:include>
  새 관리 화면을 만들 때마다 아래 TABS 에 한 줄씩 추가한다 : { 구분값, 표시 이름, 주소 }
--%>
<%
    String current = request.getParameter("current");
    String ctx = request.getContextPath();
    String[][] TABS = {
        { "home", "현황", "/admin/community" },
        { "qna", "1:1 문의", "/admin/community/qna" },
        { "notice", "공지사항", "/admin/community/notice" },
        { "faq", "자주묻는 질문", "/admin/community/faq" },
        { "orders", "주문관리", "/admin/orders" },
    };
%>
<ul class="admin-tabs">
<%  for (String[] t : TABS) { %>
  <li><a href="<%= ctx + t[2] %>"<%= t[0].equals(current) ? " class=\"is-current\"" : "" %>><%= t[1] %></a></li>
<%  } %>
</ul>
