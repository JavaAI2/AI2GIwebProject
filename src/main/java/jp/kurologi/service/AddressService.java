package jp.kurologi.service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

import jp.kurologi.model.Address;
import jp.kurologi.model.Page;
import jp.kurologi.repository.AddressRepository;
import jp.kurologi.repository.AddressRepository.SearchField;

import static jp.kurologi.service.AccountService.trim;

/** 나의 주소록 — 검색 · 추가 · 수정 · 삭제. */
public class AddressService {

    public static final int PAGE_SIZE = 8;   // 4열 × 2줄

    private static final Pattern ZIPCODE = Pattern.compile("^\\d{5}$");
    private static final Pattern PHONE = Pattern.compile("^0\\d{1,2}-?\\d{3,4}-?\\d{4}$");
    /** 개인통관고유부호: P + 숫자 12자리 */
    private static final Pattern CUSTOMS_CODE = Pattern.compile("^P\\d{12}$");

    private final AddressRepository addresses;

    public AddressService(AddressRepository addresses) {
        this.addresses = addresses;
    }

    public Page<Address> search(long memberId, String field, String keyword, int page) {
        SearchField f = "address".equals(field) ? SearchField.ADDRESS : SearchField.NAME;
        return addresses.search(memberId, f, keyword, Math.max(1, page), PAGE_SIZE);
    }

    /** form.id 가 0 이면 새 주소, 아니면 수정. 다른 회원의 주소는 수정할 수 없습니다. */
    public Address save(long memberId, Address form) {
        Address target = form.getId() == 0
                ? new Address()
                : addresses.findById(memberId, form.getId())
                        .orElseThrow(() -> new ValidationException("주소를 찾을 수 없습니다."));

        Map<String, String> errors = new LinkedHashMap<>();
        String name = trim(form.getName());
        String zipcode = trim(form.getZipcode());
        String address1 = trim(form.getAddress1());
        String phone = trim(form.getPhone());
        String customsCode = trim(form.getCustomsCode()).toUpperCase();

        if (name.isEmpty() || name.length() > 30) errors.put("name", "받는 사람 이름을 30자 이내로 입력해 주세요.");
        if (!ZIPCODE.matcher(zipcode).matches()) errors.put("zipcode", "우편번호 5자리를 입력해 주세요.");
        if (address1.isEmpty()) errors.put("address1", "주소를 입력해 주세요.");
        if (!PHONE.matcher(phone).matches()) errors.put("phone", "전화번호 형식이 올바르지 않습니다. 예) 010-1234-5678");
        if (!CUSTOMS_CODE.matcher(customsCode).matches()) {
            errors.put("customsCode", "개인통관고유부호는 P로 시작하는 13자리입니다. 예) P123456789012");
        }
        if (!errors.isEmpty()) throw new ValidationException(errors);

        target.setMemberId(memberId);
        target.setName(name);
        target.setZipcode(zipcode);
        target.setAddress1(address1);
        target.setAddress2(trim(form.getAddress2()));
        target.setCountry(trim(form.getCountry()).isEmpty() ? "South Korea" : trim(form.getCountry()));
        target.setPhone(phone);
        target.setCustomsCode(customsCode);
        return addresses.save(target);
    }

    public void delete(long memberId, long id) {
        if (!addresses.delete(memberId, id)) throw new ValidationException("주소를 찾을 수 없습니다.");
    }
}
