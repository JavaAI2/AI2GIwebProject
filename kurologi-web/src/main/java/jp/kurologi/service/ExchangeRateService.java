package jp.kurologi.service;

import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.HttpURLConnection;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jp.kurologi.model.ExchangeRate;
import jp.kurologi.repository.ExchangeRateDAO;

/**
 * 환율 서비스 — "오늘의 환율" 을 외부에서 받아 DB 에 저장하고, 화면/주문에서 꺼내 쓴다.
 *
 *  - 받아 오는 곳 : open.er-api.com (ExchangeRate-API 의 무료 공개 주소, API 키 불필요)
 *      · 하루에 한 번 갱신되는 시장(중간) 환율이다. 사용 조건상 화면에 출처 표시를 해야 한다. (메인 화면에 표시함)
 *      · 요청이 너무 잦으면 차단(429)되므로 "오늘 환율이 DB 에 없을 때만" 요청한다.
 *  - 이 값은 시장 환율이라 은행 고시환율과 조금 다르다. 서비스 수수료 성격의 가산율(SEND_SPREAD, NOTICE_SPREAD)을 더해
 *    송금환율 / 고시환율을 만든다. 가산율은 아래 상수를 고치면 된다.
 *  - 받아 오지 못하면(인터넷 불가, API 장애) DB 에 있는 가장 최근 환율을 계속 쓴다.
 */
public final class ExchangeRateService {

	private ExchangeRateService() { }

	private static final String API_URL = "https://open.er-api.com/v6/latest/JPY";

	/** 기준환율에 더하는 비율 : 송금환율 +1.0%, 고시환율 +2.5% (기존 화면의 값 차이를 참고한 값. 필요하면 수정) */
	private static final BigDecimal SEND_SPREAD = new BigDecimal("0.010");
	private static final BigDecimal NOTICE_SPREAD = new BigDecimal("0.025");

	private static final ZoneId KST = ZoneId.of("Asia/Seoul");
	private static final long CACHE_MILLIS = 10 * 60 * 1000L;   // DB 를 매번 읽지 않도록 10분 보관

	private static final ExchangeRateDAO DAO = new ExchangeRateDAO();
	private static volatile ExchangeRate cached;
	private static volatile long cachedAt;

	/** 지금 적용할 환율(DB 의 가장 최근 값). 아직 한 번도 저장된 적이 없으면 null */
	public static ExchangeRate current() {
		long now = System.currentTimeMillis();
		ExchangeRate c = cached;
		if (c != null && now - cachedAt < CACHE_MILLIS) {
			return c;
		}
		ExchangeRate fresh = DAO.latest();
		if (fresh != null) {
			cached = fresh;
			cachedAt = now;
			return fresh;
		}
		return c;   // DB 를 읽지 못하면 마지막으로 알고 있던 값
	}

	/** 오늘(한국 시간) 환율이 아직 없으면 받아서 저장한다. 새로 저장했으면 true */
	public static boolean refreshIfNeeded() {
		LocalDate today = LocalDate.now(KST);
		if (DAO.existsOn(today)) {
			return false;
		}
		return fetchAndSave(today);
	}

	/** 외부 API 에서 환율을 받아 오늘 날짜로 저장한다 */
	static boolean fetchAndSave(LocalDate date) {

		HttpURLConnection conn = null;
		try {
			conn = (HttpURLConnection) URI.create(API_URL).toURL().openConnection();
			conn.setConnectTimeout(5000);
			conn.setReadTimeout(8000);
			conn.setRequestProperty("Accept", "application/json");
			conn.setRequestProperty("User-Agent", "kurologi-edu-project/1.0");

			int code = conn.getResponseCode();
			if (code != 200) {
				System.out.println("[환율] API 응답 오류 HTTP " + code + " (429 는 요청이 너무 잦다는 뜻)");
				return false;
			}

			String body;
			try (InputStream in = conn.getInputStream()) {
				body = new String(in.readNBytes(300_000), StandardCharsets.UTF_8);   // 너무 큰 응답은 자른다
			}

			ExchangeRate rate = parse(body, date);
			if (rate == null) {
				System.out.println("[환율] API 응답을 해석하지 못했습니다.");
				return false;
			}
			if (!DAO.save(rate)) {
				return false;
			}
			cached = null;   // 다음 current() 에서 새 값을 읽도록
			System.out.println("[환율] " + date + " 고시환율 " + rate.getNoticeRate() + " (100엔당 원) 저장");
			return true;

		} catch (Exception e) {
			System.out.println("[환율] 가져오기 실패 (이전 환율을 계속 사용합니다) : " + e);
			return false;
		} finally {
			if (conn != null) {
				conn.disconnect();
			}
		}
	}

	/**
	 * API 응답(JSON 문자열)에서 KRW, USD 를 읽어 ExchangeRate 로 만든다. 이상하면 null.
	 * 응답은 "1엔 = 몇 KRW / 몇 USD" 로 된 rates 목록이다. (예: "rates":{"USD":0.0066,"KRW":9.0})
	 * JSON 라이브러리 없이 필요한 숫자 두 개만 정규식으로 읽는다.
	 */
	static ExchangeRate parse(String json, LocalDate date) {

		if (json == null || !Pattern.compile("\"result\"\\s*:\\s*\"success\"").matcher(json).find()) {
			return null;
		}
		BigDecimal krwPerYen = findRate(json, "KRW");
		BigDecimal usdPerYen = findRate(json, "USD");
		if (krwPerYen == null || usdPerYen == null) {
			return null;
		}

		// 말이 안 되는 값(0, 단위 오류)이 들어오면 저장하지 않는다 : 1엔 = 2~30원, 0.001~0.05달러
		if (krwPerYen.compareTo(BigDecimal.valueOf(2)) < 0 || krwPerYen.compareTo(BigDecimal.valueOf(30)) > 0
				|| usdPerYen.compareTo(new BigDecimal("0.001")) < 0 || usdPerYen.compareTo(new BigDecimal("0.05")) > 0) {
			return null;
		}

		BigDecimal base = krwPerYen.multiply(BigDecimal.valueOf(100)).setScale(2, RoundingMode.HALF_UP);

		ExchangeRate r = new ExchangeRate();
		r.setRateDate(date);
		r.setBaseRate(base);
		r.setSendRate(base.multiply(BigDecimal.ONE.add(SEND_SPREAD)).setScale(2, RoundingMode.HALF_UP));
		r.setNoticeRate(base.multiply(BigDecimal.ONE.add(NOTICE_SPREAD)).setScale(2, RoundingMode.HALF_UP));
		r.setJpyUsd(usdPerYen.setScale(8, RoundingMode.HALF_UP));
		r.setSource("API");
		return r;
	}

	private static BigDecimal findRate(String json, String code) {
		Matcher m = Pattern.compile("\"" + code + "\"\\s*:\\s*([0-9]+(?:\\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)").matcher(json);
		return m.find() ? new BigDecimal(m.group(1)) : null;
	}
}
