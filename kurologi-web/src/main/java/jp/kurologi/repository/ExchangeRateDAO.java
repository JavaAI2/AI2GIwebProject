package jp.kurologi.repository;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;

import jp.kurologi.model.ExchangeRate;
import util.DBmanager;

/** EXCHANGE_RATE(환율) 전용 DAO */
public class ExchangeRateDAO {

	/** 가장 최근 날짜의 환율. 없으면 null */
	public ExchangeRate latest() {

		String sql = "SELECT RATE_DATE, BASE_RATE, SEND_RATE, NOTICE_RATE, JPY_USD, SOURCE FROM EXCHANGE_RATE "
				+ "WHERE RATE_DATE = (SELECT MAX(RATE_DATE) FROM EXCHANGE_RATE)";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql);
				ResultSet rs = pstmt.executeQuery()) {
			if (rs.next()) {
				ExchangeRate r = new ExchangeRate();
				r.setRateDate(rs.getDate("RATE_DATE").toLocalDate());
				r.setBaseRate(rs.getBigDecimal("BASE_RATE"));
				r.setSendRate(rs.getBigDecimal("SEND_RATE"));
				r.setNoticeRate(rs.getBigDecimal("NOTICE_RATE"));
				r.setJpyUsd(rs.getBigDecimal("JPY_USD"));
				r.setSource(rs.getString("SOURCE"));
				return r;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/** 그 날짜의 환율이 이미 저장되어 있는지 */
	public boolean existsOn(LocalDate date) {

		String sql = "SELECT COUNT(*) FROM EXCHANGE_RATE WHERE RATE_DATE = ?";

		try (Connection conn = DBmanager.getInstance();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setDate(1, Date.valueOf(date));
			try (ResultSet rs = pstmt.executeQuery()) {
				return rs.next() && rs.getInt(1) > 0;
			}
		} catch (Exception e) {
			e.printStackTrace();
			return true;   // DB 를 확인하지 못했으면 "있다"고 보고 이번에는 외부 API 를 부르지 않는다
		}
	}

	/** 그 날짜의 환율을 저장한다 (이미 있으면 덮어쓰기: 먼저 UPDATE, 0건이면 INSERT) */
	public boolean save(ExchangeRate r) {

		String updateSql = "UPDATE EXCHANGE_RATE SET BASE_RATE = ?, SEND_RATE = ?, NOTICE_RATE = ?, JPY_USD = ?, "
				+ "SOURCE = ?, FETCHED_AT = SYSTIMESTAMP WHERE RATE_DATE = ?";
		String insertSql = "INSERT INTO EXCHANGE_RATE (RATE_DATE, BASE_RATE, SEND_RATE, NOTICE_RATE, JPY_USD, SOURCE) "
				+ "VALUES (?, ?, ?, ?, ?, ?)";

		try (Connection conn = DBmanager.getInstance()) {

			int updated;
			try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
				pstmt.setBigDecimal(1, r.getBaseRate());
				pstmt.setBigDecimal(2, r.getSendRate());
				pstmt.setBigDecimal(3, r.getNoticeRate());
				pstmt.setBigDecimal(4, r.getJpyUsd());
				pstmt.setString(5, r.getSource());
				pstmt.setDate(6, Date.valueOf(r.getRateDate()));
				updated = pstmt.executeUpdate();
			}

			if (updated == 0) {
				try (PreparedStatement pstmt = conn.prepareStatement(insertSql)) {
					pstmt.setDate(1, Date.valueOf(r.getRateDate()));
					pstmt.setBigDecimal(2, r.getBaseRate());
					pstmt.setBigDecimal(3, r.getSendRate());
					pstmt.setBigDecimal(4, r.getNoticeRate());
					pstmt.setBigDecimal(5, r.getJpyUsd());
					pstmt.setString(6, r.getSource());
					pstmt.executeUpdate();
				}
			}
			return true;   // autoCommit 이라 바로 확정된다

		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}
