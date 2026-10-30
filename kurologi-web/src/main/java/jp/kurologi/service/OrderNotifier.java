package jp.kurologi.service;

import jp.kurologi.model.BuyOrderDTO;
import jp.kurologi.model.MessageDTO;
import jp.kurologi.repository.MessageDAO;

/**
 * 주문 진행 단계가 바뀔 때 회원에게 알림메세지(COMMUNITY_MESSAGE)를 보낸다.
 * 알림 발송이 실패해도 주문 상태 변경은 그대로 유지한다. (알림은 부가 기능이므로 예외를 밖으로 던지지 않는다)
 *
 *   단계  구분(MSG_TYPE)  내용
 *   02    입고            일본 물류센터에 입고되었습니다.
 *   03    결제            배송비 결제를 기다립니다.
 *   04    출고            결제가 완료되어 한국으로 출고되었습니다.
 *   05    배송            한국 택배사로 인계되어 배송 중입니다.
 *   (01 신청 완료는 회원이 직접 신청한 것이라 알림을 보내지 않는다)
 */
public final class OrderNotifier {

	private OrderNotifier() { }

	/** 단계 번호(2 ~ 5)에 맞는 알림을 보낸다. 보냈으면 true */
	public static boolean sendStep(BuyOrderDTO order, int step) {

		String type;
		String text;
		switch (step) {
		case 2:
			type = "입고";
			text = "일본 물류센터에 입고되었습니다.";
			break;
		case 3:
			type = "결제";
			text = "무게 측정이 끝났습니다. 배송비 결제를 기다리고 있습니다.";
			break;
		case 4:
			type = "출고";
			text = "결제가 완료되어 한국으로 출고되었습니다.";
			break;
		case 5:
			type = "배송";
			text = "통관이 끝나 한국 택배사로 인계되었습니다. 국내 배송 중입니다.";
			break;
		default:
			return false;   // 01 신청 완료 등은 알림 대상이 아니다
		}
		return send(order, type, text);
	}

	/** 결제(입금) 확인 알림 */
	public static boolean sendPaid(BuyOrderDTO order) {
		return send(order, "결제", "결제(입금)가 확인되었습니다.");
	}

	private static boolean send(BuyOrderDTO order, String type, String text) {

		if (order == null || order.getMemberId() <= 0) {
			return false;
		}

		try {
			MessageDAO dao = new MessageDAO();
			long messageId = dao.nextId();
			if (messageId < 0) {
				return false;
			}

			MessageDTO dto = new MessageDTO();
			dto.setMessageId(messageId);
			dto.setMemberId(order.getMemberId());
			dto.setMsgType(type);
			dto.setContent("[" + ServiceType.label(order.getServiceType()) + "] 주문번호 " + order.getOrderNo() + " " + text);
			return dao.insert(dto) == 1;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}