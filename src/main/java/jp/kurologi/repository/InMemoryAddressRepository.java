package jp.kurologi.repository;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

import jp.kurologi.model.Address;
import jp.kurologi.model.Page;

public class InMemoryAddressRepository implements AddressRepository {

    private final Map<Long, Address> addresses = new ConcurrentHashMap<>();
    private final AtomicLong seq = new AtomicLong();

    @Override
    public Page<Address> search(long memberId, SearchField field, String keyword, int page, int size) {
        String q = keyword == null ? "" : keyword.trim();
        List<Address> all = addresses.values().stream()
                .filter(a -> a.getMemberId() == memberId)
                .filter(a -> q.isEmpty() || (field == SearchField.ADDRESS
                        ? a.getFullAddress().contains(q)
                        : a.getName().contains(q)))
                .sorted(Comparator.comparingLong(Address::getId).reversed())
                .toList();
        int from = Math.min((page - 1) * size, all.size());
        int to = Math.min(from + size, all.size());
        return new Page<>(all.subList(from, to), page, size, all.size());
    }

    @Override
    public Optional<Address> findById(long memberId, long id) {
        return Optional.ofNullable(addresses.get(id)).filter(a -> a.getMemberId() == memberId);
    }

    @Override
    public Address save(Address address) {
        if (address.getId() == 0) address.setId(seq.incrementAndGet());
        addresses.put(address.getId(), address);
        return address;
    }

    @Override
    public boolean delete(long memberId, long id) {
        return findById(memberId, id).map(a -> addresses.remove(a.getId()) != null).orElse(false);
    }
}
