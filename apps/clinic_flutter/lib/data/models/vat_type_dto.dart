import '../../core/utils/json_utils.dart';
import '../../domain/models/vat_type.dart';

class VatTypeDto {
  const VatTypeDto({
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

  factory VatTypeDto.fromJson(Map<String, dynamic> json) {
    return VatTypeDto(
      id: asString(json['id']) ?? '',
      clinicId: asString(json['clinic_id']) ?? '',
      names: _names(json['names']),
      rate: _rate(json['rate']),
      isDefault: asBool(json['is_default']),
      isActive: asBool(json['is_active'], fallback: true),
      isSystem: asBool(json['is_system']),
    );
  }

  VatType toDomain() {
    return VatType(
      id: id,
      clinicId: clinicId,
      names: names,
      rate: rate,
      isDefault: isDefault,
      isActive: isActive,
      isSystem: isSystem,
    );
  }

  static Map<String, String> _names(dynamic raw) {
    final map = asMap(raw);
    if (map == null) return const {};
    return {
      for (final entry in map.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
  }

  static double _rate(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }
}
