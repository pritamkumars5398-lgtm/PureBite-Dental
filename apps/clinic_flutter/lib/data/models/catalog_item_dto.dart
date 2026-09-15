import '../../core/utils/json_utils.dart';
import '../../domain/models/catalog_item.dart';

class CatalogItemDto {
  const CatalogItemDto({
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

  factory CatalogItemDto.fromJson(Map<String, dynamic> json) {
    return CatalogItemDto(
      id: asString(json['id']) ?? '',
      clinicId: asString(json['clinic_id']) ?? '',
      categoryId: asString(json['category_id']) ?? '',
      internalCode: asString(json['internal_code']) ?? '',
      names: _asStringMap(json['names']),
      defaultPrice: _asDouble(json['default_price']),
      defaultDurationMinutes: asInt(json['default_duration_minutes']),
      treatmentScope: asString(json['treatment_scope']),
      isActive: asBool(json['is_active'], fallback: true),
      updatedAt: asDateTime(json['updated_at']) ?? DateTime.now().toUtc(),
    );
  }

  CatalogItem toDomain() {
    return CatalogItem(
      id: id,
      clinicId: clinicId,
      categoryId: categoryId,
      internalCode: internalCode,
      names: names,
      defaultPrice: defaultPrice,
      defaultDurationMinutes: defaultDurationMinutes,
      treatmentScope: treatmentScope,
      isActive: isActive,
      updatedAt: updatedAt,
    );
  }

  static Map<String, String> _asStringMap(dynamic value) {
    final map = asMap(value);
    if (map == null) return const {};
    return {
      for (final entry in map.entries)
        if ((asString(entry.value) ?? '').isNotEmpty)
          entry.key: asString(entry.value)!,
    };
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
