package jp.kurologi.web;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import jp.kurologi.repository.DbMemberRepository;
import jp.kurologi.repository.DbPaymentRepository;
import jp.kurologi.repository.InMemoryAddressRepository;
import jp.kurologi.repository.MemberRepository;
import jp.kurologi.repository.PaymentRepository;
import jp.kurologi.service.AccountService;
import jp.kurologi.service.AddressService;
import jp.kurologi.service.PaymentService;

/**
 * 저장소 · 서비스 조립. Spring 을 쓰지 않으므로 여기서 직접 new 합니다.
 *
 * 회원 저장소   : DbMemberRepository  (KURO_MEMBER 테이블)
 * 결제 저장소   : DbPaymentRepository (CHARGE, PAYMENT 테이블) -> 서버를 재시작해도 청구건 · 결제내역이 남습니다.
 * 주소록 저장소 : 아직 메모리용이라 서버를 재시작하면 사라집니다.
 *
 * (수정) 시연용 청구서(seedSampleCharges)는 삭제했습니다. 청구건은 구매대행 · 배송대행 접수신청 때 만들어집니다.
 */
@WebListener
public class App implements ServletContextListener {

    private static final String KEY = App.class.getName();

    public final MemberRepository members;
    public final AccountService accounts;
    public final PaymentService payments;
    public final AddressService addresses;

    private final PaymentRepository paymentRepo;

    public App() {
        MemberRepository memberRepo = new DbMemberRepository();
        this.paymentRepo = new DbPaymentRepository();
        var addressRepo = new InMemoryAddressRepository();
        this.members = memberRepo;
        this.accounts = new AccountService(memberRepo, paymentRepo);
        this.payments = new PaymentService(memberRepo, paymentRepo);
        this.addresses = new AddressService(addressRepo);
    }

    public static App of(ServletContext ctx) {
        return (App) ctx.getAttribute(KEY);
    }

    @Override
    public void contextInitialized(ServletContextEvent e) {
        e.getServletContext().setAttribute(KEY, this);
    }
}
