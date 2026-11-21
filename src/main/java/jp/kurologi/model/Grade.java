package jp.kurologi.model;
/**수정*/
/** 회원등급 — 서비스안내/info_grade.html (2026.03.30 개정) 기준. */
public enum Grade {
    BASIC("베이직(Basic)"),
    PARTNER("파트너(Partner)"),
    FAMILY("패밀리(Family)"),
    ROYAL_FAMILY("로얄패밀리(Royal Family)");

    /** 전월 발송량이 이 값 이상이면 로얄패밀리 자동 적용. */
    public static final int ROYAL_FAMILY_THRESHOLD = 500;

    private final String label;

    Grade(String label) { this.label = label; }

    public String getLabel() { return label; }

    /** 괄호 앞 한글 이름만 (예: 로얄패밀리) */
    public String getLabelShort() { return label.substring(0, label.indexOf('(')); }
}
