class Invoice {
  const Invoice({
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
}
