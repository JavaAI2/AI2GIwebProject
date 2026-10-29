package jp.kurologi.service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.AdminMessageDAO;
import jp.kurologi.web.Session;

/**
 * 관리자 알림 발송
 *   GET  : 발송 폼을 보여준다 (true)
 *   POST : 검증 -> 발송 -> 발송 이력으로 redirect (false). 실패하면 입력값을 그대로 두고 폼을 다시 보여준다 (true)
 *
 * 파라미터 : target("member" = 아래 아이디의 회원들 / "all" = 전체 회원), loginIds(쉼표·공백·줄바꿈으로 구분, 최대 50명),
 *           msgType(구분, 30자), content(내용, 1000자)
 * JSP 에 넘기는 값 : memberCount(전체 발송 대상 수), target, loginIds, msgType, content, errors
 */
public class AdminMessageSend implements Command {

	private static final int TYPE_MAX = 30;       // COMMUNITY_MESSAGE.MSG_TYPE 은 30자
	private static final int CONTENT_MAX = 1000;  // CONTENT 는 1000자
	private static final int IDS_MAX = 50;        // 한 번에 직접 지정할 수 있는 회원 수

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		AdminMessageDAO dao = new AdminMessageDAO();
		request.setAttribute("memberCount", dao.countActiveMembers());

		if ("GET".equalsIgnoreCase(request.getMethod())) {
			request.setAttribute("target", "member");
			return true;
		}

		String target = "all".equals(CommunityUtil.param(request, "target")) ? "all" : "member";
		String loginIdsRaw = CommunityUtil.param(request, "loginIds");
		String msgType = CommunityUtil.param(request, "msgType");
		String content = CommunityUtil.param(request, "content");

		Map<String, String> errors = new LinkedHashMap<>();

		if (msgType.isEmpty()) {
			errors.put("msgType", "구분을 입력해 주세요.");
		} else if (msgType.length() > TYPE_MAX) {
			errors.put("msgType", "구분은 " + TYPE_MAX + "자 이내로 입력해 주세요.");
		}

		if (content.isEmpty()) {
			errors.put("content", "내용을 입력해 주세요.");
		} else if (content.length() > CONTENT_MAX) {
			errors.put("content", "내용은 " + CONTENT_MAX + "자 이내로 입력해 주세요.");
		}

		// 직접 지정한 회원 : 아이디를 쪼개고, 실제로 있는 회원인지 확인한다
		Map<String, Long> found = null;
		if ("member".equals(target)) {
			Set<String> ids = new LinkedHashSet<>();
			for (String token : loginIdsRaw.split("[\\s,;]+")) {
				if (!token.isEmpty()) {
					ids.add(token);
				}
			}

			if (ids.isEmpty()) {
				errors.put("loginIds", "받는 회원의 아이디를 입력해 주세요.");
			} else if (ids.size() > IDS_MAX) {
				errors.put("loginIds", "한 번에 " + IDS_MAX + "명까지 지정할 수 있습니다. 더 많으면 \"전체 회원\"을 선택해 주세요.");
			} else {
				found = dao.findActiveMemberIds(new ArrayList<>(ids));
				List<String> missing = new ArrayList<>();
				for (String id : ids) {
					if (!found.containsKey(id)) {
						missing.add(id);
					}
				}
				if (!missing.isEmpty()) {
					errors.put("loginIds", "등록되지 않았거나 탈퇴한 아이디입니다: " + String.join(", ", missing));
				}
			}
		}

		if (errors.isEmpty()) {
			int sent = "all".equals(target)
					? dao.sendToAll(msgType, content)
					: dao.sendToMembers(new ArrayList<>(found.values()), msgType, content);

			if (sent >= 0) {
				Session.flash(request, "info", sent + "명에게 알림을 발송했습니다.");
				response.sendRedirect(request.getContextPath() + "/admin/community/message");
				return false;
			}
			errors.put("system", "알림을 발송하지 못했습니다. 잠시 후 다시 시도해 주세요. (일부만 발송되는 일은 없습니다)");
		}

		request.setAttribute("errors", errors);
		request.setAttribute("target", target);
		request.setAttribute("loginIds", loginIdsRaw);
		request.setAttribute("msgType", msgType);
		request.setAttribute("content", content);
		return true;
	}
}