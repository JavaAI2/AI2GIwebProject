package jp.kurologi.repository;

import java.util.Optional;

import jp.kurologi.model.Address;
import jp.kurologi.model.Page;

public interface AddressRepository {

    enum SearchField { NAME, ADDRESS }

    /** 회원의 주소록 검색. keyword 가 비어 있으면 전체. 최신 등록순. */
    Page<Address> search(long memberId, SearchField field, String keyword, int page, int size);

    /** 다른 회원의 주소는 찾지 않습니다 (memberId 로 소유자 확인). */
    Optional<Address> findById(long memberId, long id);

    Address save(Address address);

    boolean delete(long memberId, long id);
}
