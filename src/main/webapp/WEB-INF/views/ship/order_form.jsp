<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  배송대행 신청 화면은 구매대행 주문서(buy/order_form.jsp)와 같은 JSP 를 사용합니다.
  (두 서비스는 같은 코드 · 같은 테이블을 쓰고, 컨트롤러 주소 /shiporder 로 구분합니다.)
  예전 주소 /ship/order_form 으로 들어와도 컨트롤러로 보내 줍니다.
--%>
<jsp:forward page="/shiporder/form" />
