import '../../core/utils/json_utils.dart';
import '../../core/utils/string_utils.dart';
import '../../domain/models/payment.dart';

double _asMoney(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

class PaymentAllocationDto {
  const PaymentAllocationDto({
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

  factory PaymentAllocationDto.fromJson(Map<String, dynamic> json) {
    return PaymentAllocationDto(
      id: asString(json['id']) ?? '',
      targetType: asString(json['target_type']) ?? '',
      targetId: asString(json['target_id']),
      amount: _asMoney(json['amount']),
      createdAt: asDateTime(json['created_at']) ?? DateTime.now().toUtc(),
      createdBy: asString(json['created_by']) ?? '',
      method: asString(json['method']),
    );
  }

  PaymentAllocation toDomain() {
    return PaymentAllocation(
      id: id,
      targetType: targetType,
      targetId: targetId,
      amount: amount,
      createdAt: createdAt,
      createdBy: createdBy,
      method: method,
    );
  }
}

class PaymentDto {
  const PaymentDto({
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
  final List<PaymentAllocationDto> allocations;
  final double refundedTotal;
  final double netAmount;
  final String? patientName;

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      id: asString(json['id']) ?? '',
      clinicId: asString(json['clinic_id']) ?? '',
      patientId: asString(json['patient_id']) ?? '',
      amount: _asMoney(json['amount']),
      currency: asString(json['currency']) ?? '',
      method: asString(json['method']) ?? '',
      paymentDate: asDateTime(json['payment_date']) ?? DateTime.now().toUtc(),
      reference: asString(json['reference']),
      notes: asString(json['notes']),
      recordedBy: asString(json['recorded_by']) ?? '',
      createdAt: asDateTime(json['created_at']) ?? DateTime.now().toUtc(),
      updatedAt: asDateTime(json['updated_at']) ?? DateTime.now().toUtc(),
      allocations: asList(json['allocations'])
          .map(asMap)
          .whereType<Map<String, dynamic>>()
          .map(PaymentAllocationDto.fromJson)
          .toList(),
      refundedTotal: _asMoney(json['refunded_total']),
      netAmount: _asMoney(json['net_amount']),
      patientName: _patientNameFromJson(json['patient']),
    );
  }

  Payment toDomain() {
    return Payment(
      id: id,
      clinicId: clinicId,
      patientId: patientId,
      amount: amount,
      currency: currency,
      method: method,
      paymentDate: paymentDate,
      reference: emptyToNull(reference),
      notes: emptyToNull(notes),
      recordedBy: recordedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      allocations: allocations.map((a) => a.toDomain()).toList(),
      refundedTotal: refundedTotal,
      netAmount: netAmount,
      patientName: patientName,
    );
  }

  static String? _patientNameFromJson(dynamic patient) {
    final map = asMap(patient);
    if (map == null) return null;
    final name = fullName(
      asString(map['first_name']) ?? '',
      asString(map['last_name']) ?? '',
    );
    return emptyToNull(name);
  }
}

class PaymentAgingBucketDto {
  const PaymentAgingBucketDto({
    required this.label,
    required this.total,
    required this.patientCount,
  });

  final String label;
  final double total;
  final int patientCount;

  factory PaymentAgingBucketDto.fromJson(Map<String, dynamic> json) {
    return PaymentAgingBucketDto(
      label: asString(json['label']) ?? '',
      total: _asMoney(json['total']),
      patientCount: asInt(json['patient_count']) ?? 0,
    );
  }

  PaymentAgingBucket toDomain() {
    return PaymentAgingBucket(
      label: label,
      total: total,
      patientCount: patientCount,
    );
  }
}

class PaymentAgingDto {
  const PaymentAgingDto({
    required this.currency,
    required this.buckets,
  });

  final String currency;
  final List<PaymentAgingBucketDto> buckets;

  factory PaymentAgingDto.fromJson(Map<String, dynamic> json) {
    return PaymentAgingDto(
      currency: asString(json['currency']) ?? '',
      buckets: asList(json['buckets'])
          .map(asMap)
          .whereType<Map<String, dynamic>>()
          .map(PaymentAgingBucketDto.fromJson)
          .toList(),
    );
  }

  PaymentAging toDomain() {
    return PaymentAging(
      currency: currency,
      buckets: buckets.map((b) => b.toDomain()).toList(),
    );
  }
}
