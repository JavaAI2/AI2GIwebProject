package jp.kurologi.service;

//모든 기능(로그인, 회원가입, 아이디 중복확인...)이 공통으로 구현할 인터페이스
//컨트롤러는 이 인터페이스만 다룬다(다형성)

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public interface Command {

	/**
	 * @return true  : 컨트롤러가 지정된 JSP 로 forward 한다 (화면 보여주기)
	 *         false : 여기서 이미 응답(redirect / JSON 출력)을 끝냈으니 컨트롤러는 아무것도 하지 않는다
	 */
	boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException;

}
