import '../../core/utils/json_utils.dart';
import '../../core/utils/string_utils.dart';
import '../../domain/models/invoice.dart';

class InvoiceDto {
  const InvoiceDto({
    required this.id,
    required this.status,
    required this.total,
    required this.totalPaid,
    required this.balanceDue,
    required this.createdAt,
    this.invoiceNumber,
    this.patientName,
    this.issueDate,
    this.dueDate,
  });

  final String id;
  final String? invoiceNumber;
  final String status;
  final String? patientName;
  final double total;
  final double totalPaid;
  final double balanceDue;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final DateTime createdAt;

  factory InvoiceDto.fromJson(Map<String, dynamic> json) {
    return InvoiceDto(
      id: asString(json['id']) ?? '',
      invoiceNumber: asString(json['invoice_number']),
      status: asString(json['status']) ?? '',
      patientName: _patientNameFromJson(json['patient']),
      total: _asDouble(json['total']),
      totalPaid: _asDouble(json['total_paid']),
      balanceDue: _asDouble(json['balance_due']),
      issueDate: asDateTime(json['issue_date']),
      dueDate: asDateTime(json['due_date']),
      createdAt: asDateTime(json['created_at']) ?? DateTime.now().toUtc(),
    );
  }

  Invoice toDomain() {
    return Invoice(
      id: id,
      invoiceNumber: invoiceNumber,
      status: status,
      patientName: patientName,
      total: total,
      totalPaid: totalPaid,
      balanceDue: balanceDue,
      issueDate: issueDate,
      dueDate: dueDate,
      createdAt: createdAt,
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

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
