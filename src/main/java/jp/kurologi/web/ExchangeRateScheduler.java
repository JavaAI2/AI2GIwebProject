package jp.kurologi.web;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import jp.kurologi.service.ExchangeRateService;

/**
 * 서버가 켜질 때 시작해서 "오늘 환율이 있는지" 를 주기적으로 확인하는 리스너.
 *   - 서버 시작 10초 뒤 첫 확인, 그 뒤 1시간마다 확인한다.
 *   - 오늘 환율이 이미 DB 에 있으면 아무것도 하지 않는다 (외부 API 는 하루에 한 번만 호출).
 *   - 자정이 지나면 다음 확인 때 새 날짜 환율을 받아 온다. 받기 실패하면 1시간 뒤 다시 시도한다.
 * 서버가 꺼질 때(contextDestroyed) 스레드를 같이 멈춰서, 이클립스에서 재배포해도 스레드가 쌓이지 않는다.
 */
@WebListener
public class ExchangeRateScheduler implements ServletContextListener {

	private ScheduledExecutorService scheduler;

	@Override
	public void contextInitialized(ServletContextEvent sce) {
		scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
			Thread t = new Thread(r, "exchange-rate-refresh");
			t.setDaemon(true);   // 서버 종료를 막지 않는다
			return t;
		});

		scheduler.scheduleWithFixedDelay(() -> {
			try {
				ExchangeRateService.refreshIfNeeded();
			} catch (Throwable t) {
				t.printStackTrace();   // 예외를 잡지 않으면 이후 반복이 모두 멈춘다
			}
		}, 10, 3600, TimeUnit.SECONDS);
	}

	@Override
	public void contextDestroyed(ServletContextEvent sce) {
		if (scheduler != null) {
			scheduler.shutdownNow();
		}
	}
}
