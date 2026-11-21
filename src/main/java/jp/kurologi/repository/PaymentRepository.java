package jp.kurologi.repository;

import java.util.List;
import java.util.Optional;

import jp.kurologi.model.Charge;
import jp.kurologi.model.Payment;

public interface PaymentRepository {

    List<Charge> findPendingCharges(long memberId);

    /** 요청한 id 중 이 회원 소유인 것만 돌려줍니다. */
    List<Charge> findCharges(long memberId, List<Long> ids);

    void saveCharge(Charge charge);

    List<Payment> findPayments(long memberId);

    Optional<Payment> findPayment(long id);

    Payment savePayment(Payment payment);
}
