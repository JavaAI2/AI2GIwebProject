package jp.kurologi.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

/**
 * EXCHANGE_RATE 테이블 1행 = 하루치 환율.
 * 원화 금액은 모두 "100엔당 원" 이다. (메인 화면 "환율정보(100엔)" 과 같은 단위)
 */
public class ExchangeRate {

	private LocalDate rateDate;     // RATE_DATE  기준일
	private BigDecimal baseRate;    // BASE_RATE  기준환율(시장)
	private BigDecimal sendRate;    // SEND_RATE  송금환율
	private BigDecimal noticeRate;  // NOTICE_RATE 고시환율 (주문 결제에 적용하는 환율)
	private BigDecimal jpyUsd;      // JPY_USD    1엔 = 몇 달러
	private String source;          // SOURCE     API / SEED / MANUAL

	/** 엔화 금액을 결제 예정 원화로 바꾼다 (고시환율 적용, 원 단위 반올림) */
	public long toKrw(BigDecimal yen) {
		return yen.multiply(noticeRate).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP).longValue();
	}

	/** 엔화 금액을 세관 신고용 달러로 바꾼다 (소수 둘째 자리) */
	public BigDecimal toUsd(BigDecimal yen) {
		return yen.multiply(jpyUsd).setScale(2, RoundingMode.HALF_UP);
	}

	public LocalDate getRateDate() {
		return rateDate;
	}

	public void setRateDate(LocalDate rateDate) {
		this.rateDate = rateDate;
	}

	public BigDecimal getBaseRate() {
		return baseRate;
	}

	public void setBaseRate(BigDecimal baseRate) {
		this.baseRate = baseRate;
	}

	public BigDecimal getSendRate() {
		return sendRate;
	}

	public void setSendRate(BigDecimal sendRate) {
		this.sendRate = sendRate;
	}

	public BigDecimal getNoticeRate() {
		return noticeRate;
	}

	public void setNoticeRate(BigDecimal noticeRate) {
		this.noticeRate = noticeRate;
	}

	public BigDecimal getJpyUsd() {
		return jpyUsd;
	}

	public void setJpyUsd(BigDecimal jpyUsd) {
		this.jpyUsd = jpyUsd;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}
}
