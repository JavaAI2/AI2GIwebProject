package jp.kurologi.service;

import java.util.Map;

/** 사용자 입력 오류 — 화면에 그대로 보여줘도 되는 메시지만 담습니다. */
public class ValidationException extends RuntimeException {

    private final Map<String, String> fieldErrors;

    public ValidationException(String message) {
        this(message, Map.of());
    }

    public ValidationException(Map<String, String> fieldErrors) {
        this(fieldErrors.values().iterator().next(), fieldErrors);
    }

    private ValidationException(String message, Map<String, String> fieldErrors) {
        super(message);
        this.fieldErrors = Map.copyOf(fieldErrors);
    }

    public Map<String, String> getFieldErrors() { return fieldErrors; }
}
