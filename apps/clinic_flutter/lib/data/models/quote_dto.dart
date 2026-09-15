import 'package:clinic_flutter/core/utils/json_utils.dart';
import 'package:clinic_flutter/core/utils/string_utils.dart';
import 'package:clinic_flutter/domain/models/quote.dart';

class QuoteDto {
  const QuoteDto({
    required this.id,
    required this.number,
    required this.patientName,
    required this.status,
    required this.total,
  });

  final String id;
  final String number;
  final String patientName;
  final String status;
  final String total;

  factory QuoteDto.fromJson(Map<String, dynamic> json) {
    final patient = asMap(json['patient']);
    final firstName = asString(patient?['first_name']) ?? '';
    final lastName = asString(patient?['last_name']) ?? '';
    return QuoteDto(
      id: asString(json['id']) ?? '',
      number: asString(json['budget_number']) ?? '',
      patientName: fullName(firstName, lastName),
      status: asString(json['status']) ?? '',
      total: asString(json['total']) ?? '',
    );
  }

  Quote toDomain() {
    return Quote(
      id: id,
      number: number,
      patientName: patientName,
      status: status,
      total: total,
    );
  }
}
