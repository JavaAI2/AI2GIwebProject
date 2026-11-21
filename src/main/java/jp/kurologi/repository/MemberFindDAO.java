package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jp.kurologi.model.MemberDTO;

/** 아이디 찾기 / 비밀번호 찾기 전용 DAO (KURO_MEMBER). DB 연결은 MemberDAO.conn() 을 함께 쓴다 */
public class MemberFindDAO {

	/**
	 * 아이디 찾기 : 이름 + 이메일 + 전화번호가 모두 일치하는(탈퇴하지 않은) 회원의 아이디 목록.
	 * 이메일은 대소문자 무시, 전화번호는 숫자만 비교한다(010-1234-5678 = 01012345678).
	 */
	public List<String> findLoginIds(String name, String email, String phoneDigits) {

		String sql = "SELECT LOGIN_ID FROM KURO_MEMBER "
				+ "WHERE NAME = ? AND LOWER(EMAIL) = LOWER(?) "
				+ "AND REGEXP_REPLACE(PHONE, '[^0-9]', '') = ? "
				+ "AND NVL(WITHDRAWN, 'N') = 'N' ORDER BY ID";

		List<String> ids = new ArrayList<>();

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, name);
			pstmt.setString(2, email);
			pstmt.setString(3, phoneDigits);

			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					ids.add(rs.getString("LOGIN_ID"));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return ids;
	}

	/**
	 * 비밀번호 찾기 1단계 : 아이디 + 이름이 일치하는 회원의 번호(ID)와 퀴즈 답 해시를 가져온다.
	 * 퀴즈 답이 맞는지는 서비스에서 PwQuiz.matches 로 확인한다. 없으면 null.
	 */
	public MemberDTO findForPwReset(String loginId, String name) {

		String sql = "SELECT ID, PW_QUIZ_ANSWER FROM KURO_MEMBER "
				+ "WHERE LOGIN_ID = ? AND NAME = ? AND NVL(WITHDRAWN, 'N') = 'N'";

		MemberDTO dto = null;

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, loginId);
			pstmt.setString(2, name);

			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					dto = new MemberDTO();
					dto.setId(rs.getLong("ID"));
					dto.setPwQuizAnswerHash(rs.getString("PW_QUIZ_ANSWER"));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dto;
	}

	/** 비밀번호 찾기 2단계 : 새 비밀번호(이미 암호화된 값)로 변경. 성공하면 1 */
	public int updatePassword(long id, String passwordHash) {

		String sql = "UPDATE KURO_MEMBER SET PASSWORD_HASH = ? WHERE ID = ? AND NVL(WITHDRAWN, 'N') = 'N'";

		try (Connection conn = MemberDAO.conn();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, passwordHash);
			pstmt.setLong(2, id);
			return pstmt.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}
}
