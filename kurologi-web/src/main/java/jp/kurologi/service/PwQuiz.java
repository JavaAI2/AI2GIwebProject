package jp.kurologi.service;

import java.util.Locale;

/**
 * 비밀번호 퀴즈("가장 기억에 남는 장소는?") 답 처리 도우미.
 * 답은 비밀번호와 같은 PasswordHasher 로 암호화해서 저장한다.
 * 사용자가 "제주 도", "제주도 " 처럼 다르게 쳐도 맞도록 공백을 모두 없애고 소문자로 맞춘 뒤 비교한다.
 */
public final class PwQuiz {

	public static final String QUESTION = "가장 기억에 남는 장소는?";
	public static final int MAX_LENGTH = 20;   // 한글 3바이트 x 20자 = 60바이트 (BCrypt 는 72바이트까지만 사용)

	private PwQuiz() {}

	static String normalize(String answer) {
		if (answer == null) return "";
		return answer.replaceAll("\\s+", "").toLowerCase(Locale.ROOT);
	}

	/** 저장용 해시 */
	public static String hash(String answer) {
		return PasswordHasher.hash(normalize(answer));
	}

	/** 입력한 답이 저장된 해시와 맞는지 */
	public static boolean matches(String answer, String hash) {
		String n = normalize(answer);
		if (n.isEmpty() || hash == null) return false;
		try {
			return PasswordHasher.matches(n, hash);
		} catch (RuntimeException e) {
			return false;   // DB 값이 알 수 없는 형식인 경우
		}
	}
}
