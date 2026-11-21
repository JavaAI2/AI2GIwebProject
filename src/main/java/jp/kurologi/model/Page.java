package jp.kurologi.model;

import java.util.List;

/** 목록 한 페이지 + 페이저에 필요한 값. */
public record Page<T>(List<T> items, int page, int size, long totalCount) {

    public List<T> getItems() { return items; }
    public int getPage() { return page; }
    public long getTotalCount() { return totalCount; }

    public int getTotalPages() { return (int) Math.max(1, (totalCount + size - 1) / size); }
}
