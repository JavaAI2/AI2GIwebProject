package jp.kurologi.repository;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

import jp.kurologi.model.Charge;
import jp.kurologi.model.Payment;

public class InMemoryPaymentRepository implements PaymentRepository {

    private final Map<Long, Charge> charges = new ConcurrentHashMap<>();
    private final Map<Long, Payment> payments = new ConcurrentHashMap<>();
    private final AtomicLong chargeSeq = new AtomicLong();
    private final AtomicLong paymentSeq = new AtomicLong();

    @Override
    public List<Charge> findPendingCharges(long memberId) {
        return charges.values().stream()
                .filter(c -> c.getMemberId() == memberId && c.getStatus() == Charge.Status.PENDING)
                .sorted(Comparator.comparing(Charge::getCreatedAt))
                .toList();
    }

    @Override
    public List<Charge> findCharges(long memberId, List<Long> ids) {
        return ids.stream().distinct()
                .map(charges::get)
                .filter(c -> c != null && c.getMemberId() == memberId)
                .toList();
    }

    @Override
    public void saveCharge(Charge charge) {
        if (charge.getId() == 0) charge.setId(chargeSeq.incrementAndGet());
        charges.put(charge.getId(), charge);
    }

    @Override
    public List<Payment> findPayments(long memberId) {
        return payments.values().stream()
                .filter(p -> p.getMemberId() == memberId)
                .sorted(Comparator.comparing(Payment::getCreatedAt).reversed())
                .toList();
    }

    @Override
    public Optional<Payment> findPayment(long id) {
        return Optional.ofNullable(payments.get(id));
    }

    @Override
    public Payment savePayment(Payment payment) {
        if (payment.getId() == 0) payment.setId(paymentSeq.incrementAndGet());
        payments.put(payment.getId(), payment);
        return payment;
    }
}
