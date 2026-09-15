class VatType {
  const VatType({
    required this.id,
    required this.clinicId,
    required this.names,
    required this.rate,
    required this.isDefault,
    required this.isActive,
    required this.isSystem,
  });

  final String id;
  final String clinicId;
  final Map<String, String> names;
  final double rate;
  final bool isDefault;
  final bool isActive;
  final bool isSystem;

  String localizedName([String locale = 'en']) {
    final language = locale.split('_').first;
    final exact = names[locale];
    if (exact != null && exact.isNotEmpty) return exact;
    final byLang = names[language];
    if (byLang != null && byLang.isNotEmpty) return byLang;
    final en = names['en'];
    if (en != null && en.isNotEmpty) return en;
    final es = names['es'];
    if (es != null && es.isNotEmpty) return es;
    if (names.isEmpty) return '';
    return names.values.first;
  }

  String get rateLabel {
    if (rate == rate.truncateToDouble()) {
      return '${rate.toInt()}%';
    }
    return '$rate%';
  }
}
