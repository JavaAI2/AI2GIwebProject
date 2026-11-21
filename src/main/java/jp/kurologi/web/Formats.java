package jp.kurologi.web;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/** JSTL fmt:formatDate 는 java.time 을 못 다루므로 문자열로 미리 만들어 둡니다. */
public final class Formats {

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private Formats() {}

    public static String date(LocalDateTime t) { return t == null ? "" : t.format(DATE); }

    public static String dateTime(LocalDateTime t) { return t == null ? "" : t.format(DATE_TIME); }
}
