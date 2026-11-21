package jp.kurologi.repository;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import jp.kurologi.model.Member;
import jp.kurologi.model.UsageStats;

/** 개발용 저장소 — 서버를 재시작하면 사라집니다. DB 구현으로 교체하세요. */
public class InMemoryMemberRepository implements MemberRepository {

    private final Map<Long, Member> members = new ConcurrentHashMap<>();
    private final Map<Long, UsageStats> usage = new ConcurrentHashMap<>();

    @Override
    public Optional<Member> findById(long id) {
        return Optional.ofNullable(members.get(id)).filter(m -> !m.isWithdrawn());
    }

    @Override
    public Optional<Member> findByLoginId(String loginId) {
        return members.values().stream()
                .filter(m -> !m.isWithdrawn() && m.getLoginId().equals(loginId))
                .findFirst();
    }

    @Override
    public void save(Member member) {
        members.put(member.getId(), member);
    }

    @Override
    public UsageStats usageStats(long memberId) {
        return usage.getOrDefault(memberId, UsageStats.EMPTY);
    }

    public void putUsageStats(long memberId, UsageStats stats) {
        usage.put(memberId, stats);
    }
}
