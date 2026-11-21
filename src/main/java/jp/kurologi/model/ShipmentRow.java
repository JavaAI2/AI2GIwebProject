package jp.kurologi.model;

/**
 * 마이페이지 "결제 완료 운송품 현황" 박스의 한 줄.
 *
 * @param payment     결제 1건 (한국 · 일본 운송장 정보가 들어 있다)
 * @param orderNo     연결된 주문번호 (없으면 null)
 * @param orderUrl    주문 상세 주소 (프로젝트 주소 ctx 는 붙이지 않은 값. 없으면 null)
 * @param statusLabel 화면에 보일 진행 상태 이름 (주문을 못 찾으면 "결제완료")
 * @param statusCss   상태 표시에 쓸 CSS 클래스 이름 (state--submit ...)
 */
public record ShipmentRow(Payment payment, String orderNo, String orderUrl, String statusLabel, String statusCss) { }
