class AgingBucket {
  const AgingBucket({
    required this.label,
    required this.total,
    required this.patientCount,
  });

  final String label;
  final String total;
  final int patientCount;
}

class AgingReport {
  const AgingReport({required this.currency, required this.buckets});

  final String currency;
  final List<AgingBucket> buckets;

  static const empty = AgingReport(currency: '', buckets: []);
}
