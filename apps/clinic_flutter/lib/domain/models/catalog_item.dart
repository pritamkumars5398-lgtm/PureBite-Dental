class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.clinicId,
    required this.categoryId,
    required this.internalCode,
    required this.names,
    required this.isActive,
    required this.updatedAt,
    this.defaultPrice,
    this.defaultDurationMinutes,
    this.treatmentScope,
  });

  final String id;
  final String clinicId;
  final String categoryId;
  final String internalCode;
  final Map<String, String> names;
  final double? defaultPrice;
  final int? defaultDurationMinutes;
  final String? treatmentScope;
  final bool isActive;
  final DateTime updatedAt;

  String localizedName([String? locale]) {
    final preferred = locale == null ? null : names[locale];
    if (preferred != null && preferred.isNotEmpty) return preferred;
    final es = names['es'];
    if (es != null && es.isNotEmpty) return es;
    final en = names['en'];
    if (en != null && en.isNotEmpty) return en;
    for (final value in names.values) {
      if (value.isNotEmpty) return value;
    }
    return internalCode;
  }
}
