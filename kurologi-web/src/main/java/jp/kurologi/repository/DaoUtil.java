package jp.kurologi.repository;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

/** 커뮤니티 DAO 들이 같이 쓰는 작은 도우미 (같은 패키지 안에서만 사용) */
final class DaoUtil {

	private DaoUtil() {}

	/**
	 * 검색어를 LIKE 용으로 바꾼다. 검색어 안의 % _ \ 는 글자 그대로 찾도록 \ 로 막아 준다.
	 * SQL 문장에는 반드시 ESCAPE '\' 를 같이 쓴다.
	 */
	static String likePattern(String keyword) {
		String k = keyword.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
		return "%" + k + "%";
	}

	/** params 목록을 순서대로 ? 자리에 채운다 (Long, Integer, String 만 사용) */
	static void bind(PreparedStatement pstmt, List<Object> params) throws SQLException {
		for (int i = 0; i < params.size(); i++) {
			Object v = params.get(i);
			if (v instanceof Long) {
				pstmt.setLong(i + 1, (Long) v);
			} else if (v instanceof Integer) {
				pstmt.setInt(i + 1, (Integer) v);
			} else {
				pstmt.setString(i + 1, (String) v);
			}
		}
	}
}