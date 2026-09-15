class Recall {
  const Recall({
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
}

class RecallDashboardStats {
  const RecallDashboardStats({
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
}
