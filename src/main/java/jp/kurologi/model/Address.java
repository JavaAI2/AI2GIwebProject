package jp.kurologi.model;
/**1123232ㄴㅇㄹㄴㅇㄹ3*/
/** 나의 주소록 — 받는 사람(한국) 주소. */
public class Address {

    private long id;
    private long memberId;
    private String name;
    private String zipcode;
    private String address1;
    private String address2;
    private String country = "South Korea";
    private String phone;
    private String customsCode;   // 개인통관고유부호 P + 12자리

    /** 카드에 표시하는 한 줄 주소: (우편번호) 기본주소 상세주소 */
    public String getFullAddress() {
        StringBuilder sb = new StringBuilder();
        if (zipcode != null && !zipcode.isBlank()) sb.append('(').append(zipcode).append(") ");
        sb.append(address1 == null ? "" : address1);
        if (address2 != null && !address2.isBlank()) sb.append(' ').append(address2);
        return sb.toString();
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public long getMemberId() { return memberId; }
    public void setMemberId(long memberId) { this.memberId = memberId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getZipcode() { return zipcode; }
    public void setZipcode(String zipcode) { this.zipcode = zipcode; }
    public String getAddress1() { return address1; }
    public void setAddress1(String address1) { this.address1 = address1; }
    public String getAddress2() { return address2; }
    public void setAddress2(String address2) { this.address2 = address2; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getCustomsCode() { return customsCode; }
    public void setCustomsCode(String customsCode) { this.customsCode = customsCode; }
}
