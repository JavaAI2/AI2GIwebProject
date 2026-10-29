package jp.kurologi.service;

/**
 * JSON 문자열을 직접 만들 때 쓰는 아주 작은 도우미 (JSON 라이브러리를 쓰지 않는다).
 * 값에 따옴표나 줄바꿈이 있어도 깨지지 않게, < > & 도 \\u 코드로 바꿔 HTML 로 해석되지 않게 한다.
 */
public final class Json {

	private Json() { }

	/** 문자열을 "..." 형태의 JSON 문자열로 만든다 (null 은 빈 문자열) */
	public static String q(String s) {
		if (s == null) {
			return "\"\"";
		}
		StringBuilder sb = new StringBuilder("\"");
		for (int i = 0; i < s.length(); i++) {
			char c = s.charAt(i);
			switch (c) {
			case '"':  sb.append("\\\""); break;
			case '\\': sb.append("\\\\"); break;
			case '\n': sb.append("\\n"); break;
			case '\r': sb.append("\\r"); break;
			case '\t': sb.append("\\t"); break;
			case '<': case '>': case '&':
				sb.append(String.format("\\u%04x", (int) c));
				break;
			default:
				if (c < 0x20) {
					sb.append(String.format("\\u%04x", (int) c));
				} else {
					sb.append(c);
				}
			}
		}
		return sb.append('"').toString();
	}
}
