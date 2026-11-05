package jp.kurologi.model;

import java.util.List;
/**ㄴㄷㄹㄴㅇㄹㄴ수정6*/
/** 일본 사서함(센터) 주소 — 회원 공통, 사서함번호·수취인만 회원마다 다릅니다. */
public record MailboxCenter(String name, String zipcode, String address, String phone) {

    public static final List<MailboxCenter> ALL = List.of(
            new MailboxCenter("항공 - 도쿄(JP)", "100-0000", "東京都千代田区サンプル町1-2-3 NIPPON BUY 3F", "03-1234-5678"),
            new MailboxCenter("해상 - 후쿠오카 제1센터(JP)", "810-0000", "福岡県福岡市中央区サンプル町4-5-6 NIPPON BUY 3F", "092-123-4567"),
            new MailboxCenter("해상 - 후쿠오카 제2센터(JP)", "811-0000", "福岡県糟屋郡サンプル町7-8-9 NIPPON BUY", "092-234-5678"));

    public String getName() { return name; }
    public String getZipcode() { return zipcode; }
    public String getAddress() { return address; }
    public String getPhone() { return phone; }
}
