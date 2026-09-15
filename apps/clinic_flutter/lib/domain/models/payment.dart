class PaymentAllocation {
  const PaymentAllocation({
    required this.id,
    required this.targetType,
    required this.amount,
    required this.createdAt,
    required this.createdBy,
    this.targetId,
    this.method,
  });

  final String id;
  final String targetType;
  final String? targetId;
  final double amount;
  final DateTime createdAt;
  final String createdBy;
  final String? method;
}

class Payment {
  const Payment({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.paymentDate,
    required this.recordedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.refundedTotal,
    required this.netAmount,
    this.reference,
    this.notes,
    this.patientName,
    this.allocations = const [],
  });

  final String id;
  final String clinicId;
  final String patientId;
  final double amount;
  final String currency;
  final String method;
  final DateTime paymentDate;
  final String? reference;
  final String? notes;
  final String recordedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PaymentAllocation> allocations;
  final double refundedTotal;
  final double netAmount;
  final String? patientName;

  bool get hasRefunds => refundedTotal > 0;
}

class PaymentAgingBucket {
  const PaymentAgingBucket({
    required this.label,
    required this.total,
    required this.patientCount,
  });

  final String label;
  final double total;
  final int patientCount;
}

class PaymentAging {
  const PaymentAging({
    required this.currency,
    required this.buckets,
  });

  final String currency;
  final List<PaymentAgingBucket> buckets;
}
