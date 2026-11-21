package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBmanager {

	// 기본값. 다른 PC / 계정이면 Tomcat 실행 옵션으로 바꾼다 (코드를 고치지 않아도 된다)
	//   -Dkurologi.db.url=jdbc:oracle:thin:@localhost:1521:xe
	//   -Dkurologi.db.user=ai2gi  -Dkurologi.db.password=1234
	private static final String DRIVER = "oracle.jdbc.driver.OracleDriver";
	private static final String URL = System.getProperty("kurologi.db.url", "jdbc:oracle:thin:@localhost:1521:xe");
	private static final String USER = System.getProperty("kurologi.db.user", "system");
	private static final String PASSWORD = System.getProperty("kurologi.db.password", "1234");

	public static Connection getInstance() {
		Connection conn = null;
		try {
			Class.forName(DRIVER);
			conn = DriverManager.getConnection(URL, USER, PASSWORD);
		} catch (Exception e) {
			// 접속에 실패하면 null 이 돌아가 이후 DAO 에서 NullPointerException 이 난다.
			// 진짜 원인이 로그에 먼저 보이도록 접속 정보와 함께 분명하게 남긴다.
			System.err.println("[DBmanager] DB 접속 실패 : url=" + URL + ", user=" + USER
					+ " -> Oracle 이 켜져 있는지, 계정(ai2gi)이 만들어져 있는지 확인하세요. 원인 : " + e);
			e.printStackTrace();
		}
		return conn;
	}

}
