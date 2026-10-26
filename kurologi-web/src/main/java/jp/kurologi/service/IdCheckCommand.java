package jp.kurologi.service;

//아이디가 중복되는지 체크하는 서비스문
//MemberInsert서비스문(회원가입 문) 에서 넘어와서 처리한다


import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.kurologi.repository.MemberDAO;

/** 아이디 중복확인(Ajax). 화면 이동 없이 {"isDuplicate":true/false} JSON 만 응답한다 */
public class IdCheckCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String loginId = request.getParameter("loginId");
		loginId = (loginId == null) ? "" : loginId.trim();

		// 비어 있으면 DB 에 묻지 않고 "중복(사용 불가)" 으로 취급
		boolean isDuplicate = loginId.isEmpty() || new MemberDAO().idCheck(loginId);
		//사용자가 값을 입력하지 않았거나 DB에 해당 id가 존재한다면 true를 반환하여 중복된 id 취급

		// 주의: "application/json, charset=utf-8" 처럼 쉼표로 쓰면 안 되고 세미콜론(;)이어야 한다
		response.setContentType("application/json; charset=UTF-8");
		//json타입으로 직접 아이디가 중복되었다는 내용을 보일 것

		PrintWriter out = response.getWriter();
		out.print("{\"isDuplicate\":" + isDuplicate + "}");
		//화면에 아이디 중복 여부를 보인다

		return false;   // 응답을 직접 끝냈으니 forward 하지 않는다
	}
}
