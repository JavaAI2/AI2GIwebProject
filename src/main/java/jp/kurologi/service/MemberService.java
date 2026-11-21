package jp.kurologi.service;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 서비스 부분을 작성합니다.
 * 서비스는 DB > Dao > service > servlet 순으로 오는 처리 과정 중 3번째에 해당합니다.
 * (요청을 서블릿에서 받아서 -> 실제 기능인 서비스에서 처리하고 -> DB를 담당하는 DAO에 접근합니다.)
 * 서블렛에 메서드나 함수 같은 것을 다 적어넣는 데 한계가 존재하기 때문에 서비스 파트를 만듭니다.
 * 
 * 보통 서블렛 부분에는 다형성의 성질을 가진 문장 한 개만 적어넣는데, 그 문장이 이쪽으로 연결됩니다.
 * 아래의 내용은 회원 관련 모든 기능(회원가입, 로그인, 중복체크 등)이 공통으로 구현할 최상위 인터페이스입니다.
 * 컨트롤러(MemberController)는 내부를 몰라도 오직 이 인터페이스(규격)만 다룹니다.
 */
public interface MemberService {

    /**
     * 주소 주머니(request)와 응답 주머니(response)를 받아 비즈니스 로직을 수행합니다.
     * 
     * @return true 면 JSP로 화면을 연결(Forwarding)하고, false 면 직접 리다이렉트나 Ajax 처리를 하여 화면 이동을 막음
     */
    boolean doCommand(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException;
}