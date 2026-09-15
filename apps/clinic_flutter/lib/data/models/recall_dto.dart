import '../../core/utils/json_utils.dart';
import '../../core/utils/string_utils.dart';
import '../../domain/models/recall.dart';

class RecallDto {
  const RecallDto({
    required this.id,
    required this.patientName,
    required this.status,
    required this.reason,
    this.dueDate,
  });

  final String id;
  final String patientName;
  final String status;
  final String reason;
  final DateTime? dueDate;

  factory RecallDto.fromJson(Map<String, dynamic> json) {
    return RecallDto(
      id: asString(json['id']) ?? '',
      patientName: _patientNameFromJson(json['patient']),
      status: asString(json['status']) ?? 'pending',
      reason: asString(json['reason']) ?? 'other',
      dueDate: asDateTime(json['due_date']) ?? asDateTime(json['due_month']),
    );
  }

  Recall toDomain() {
    return Recall(
      id: id,
      patientName: patientName,
      status: status,
      reason: reason,
      dueDate: dueDate,
    );
  }

  static String _patientNameFromJson(dynamic patient) {
    final map = asMap(patient);
    if (map == null) return '';
    return fullName(
      asString(map['first_name']) ?? '',
      asString(map['last_name']) ?? '',
    );
  }
}

class RecallDashboardStatsDto {
  const RecallDashboardStatsDto({
    required this.dueThisWeek,
    required this.dueThisMonth,
    required this.overdue,
    required this.scheduledThisMonth,
    required this.completedThisMonth,
    required this.conversionRate,
  });

  final int dueThisWeek;
  final int dueThisMonth;
  final int overdue;
  final int scheduledThisMonth;
  final int completedThisMonth;
  final double conversionRate;

  factory RecallDashboardStatsDto.fromJson(Map<String, dynamic> json) {
    return RecallDashboardStatsDto(
      dueThisWeek: asInt(json['due_this_week']) ?? 0,
      dueThisMonth: asInt(json['due_this_month']) ?? 0,
      overdue: asInt(json['overdue']) ?? 0,
      scheduledThisMonth: asInt(json['scheduled_this_month']) ?? 0,
      completedThisMonth: asInt(json['completed_this_month']) ?? 0,
      conversionRate: _asDouble(json['conversion_rate']),
    );
  }

  RecallDashboardStats toDomain() {
    return RecallDashboardStats(
      dueThisWeek: dueThisWeek,
      dueThisMonth: dueThisMonth,
      overdue: overdue,
      scheduledThisMonth: scheduledThisMonth,
      completedThisMonth: completedThisMonth,
      conversionRate: conversionRate,
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
