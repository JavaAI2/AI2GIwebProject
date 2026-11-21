package jp.kurologi.model;

public enum MemberType {
    PERSONAL("개인"),
    BUSINESS("사업자");

    private final String label;

    MemberType(String label) { this.label = label; }

    public String getLabel() { return label; }
}
