package util;

import java.sql.Connection;
import java.sql.DriverManager;



public class DBmanager {
	
	public static Connection getInstance() {
		Connection conn = null;
		String driver = "oracle.jdbc.driver.OracleDriver";
		String url = "jdbc:oracle:thin:@localhost:1521:xe";
		String id = "system";
		String pw = "1234";
		try {
			Class.forName(driver);
			conn=DriverManager.getConnection(url,id,pw);
		}catch(Exception e) {
			e.printStackTrace();
		}
		return conn;
	}


}
