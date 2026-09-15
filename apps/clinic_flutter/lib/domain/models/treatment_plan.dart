class TreatmentPlan {
  const TreatmentPlan({
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

  String get displayTitle {
    final value = title?.trim();
    if (value != null && value.isNotEmpty) return value;
    return planNumber;
  }
}
