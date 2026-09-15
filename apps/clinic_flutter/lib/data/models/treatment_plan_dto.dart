import '../../core/utils/json_utils.dart';
import '../../core/utils/string_utils.dart';
import '../../domain/models/treatment_plan.dart';

class TreatmentPlanDto {
  const TreatmentPlanDto({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.planNumber,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.itemCount,
    required this.completedCount,
    required this.total,
    this.title,
    this.budgetId,
    this.assignedProfessionalId,
    this.patientName,
    this.budgetNumber,
    this.budgetStatus,
  });

  final String id;
  final String clinicId;
  final String patientId;
  final String planNumber;
  final String? title;
  final String status;
  final String? budgetId;
  final String? assignedProfessionalId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int itemCount;
  final int completedCount;
  final double total;
  final String? patientName;
  final String? budgetNumber;
  final String? budgetStatus;

  factory TreatmentPlanDto.fromJson(Map<String, dynamic> json) {
    final patient = asMap(json['patient']);
    final budget = asMap(json['budget']);
    return TreatmentPlanDto(
      id: asString(json['id']) ?? '',
      clinicId: asString(json['clinic_id']) ?? '',
      patientId: asString(json['patient_id']) ?? '',
      planNumber: asString(json['plan_number']) ?? '',
      title: asString(json['title']),
      status: asString(json['status']) ?? '',
      budgetId: asString(json['budget_id']),
      assignedProfessionalId: asString(json['assigned_professional_id']),
      createdBy: asString(json['created_by']) ?? '',
      createdAt: asDateTime(json['created_at']) ?? DateTime.now().toUtc(),
      updatedAt: asDateTime(json['updated_at']) ?? DateTime.now().toUtc(),
      itemCount: asInt(json['item_count']) ?? 0,
      completedCount: asInt(json['completed_count']) ?? 0,
      total: _asDouble(json['total']),
      patientName: _patientNameFromJson(patient),
      budgetNumber: asString(budget?['budget_number']),
      budgetStatus: asString(budget?['status']),
    );
  }

  TreatmentPlan toDomain() {
    return TreatmentPlan(
      id: id,
      clinicId: clinicId,
      patientId: patientId,
      planNumber: planNumber,
      title: title,
      status: status,
      budgetId: budgetId,
      assignedProfessionalId: assignedProfessionalId,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      itemCount: itemCount,
      completedCount: completedCount,
      total: total,
      patientName: patientName,
      budgetNumber: budgetNumber,
      budgetStatus: budgetStatus,
    );
  }

  static String? _patientNameFromJson(Map<String, dynamic>? patient) {
    if (patient == null) return null;
    final name = fullName(
      asString(patient['first_name']) ?? '',
      asString(patient['last_name']) ?? '',
    );
    return emptyToNull(name);
  }
}

double _asDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
