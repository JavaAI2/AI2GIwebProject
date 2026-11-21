package jp.kurologi.repository;

import java.util.Optional;

import jp.kurologi.model.Member;
import jp.kurologi.model.UsageStats;

public interface MemberRepository {

    Optional<Member> findById(long id);

    Optional<Member> findByLoginId(String loginId);

    void save(Member member);

    /** 전월 · 당월 · 누적 이용건수 (shipment 집계). */
    UsageStats usageStats(long memberId);
}
