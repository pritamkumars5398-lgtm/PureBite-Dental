import '../../core/utils/json_utils.dart';
import '../../domain/models/cabinet.dart';

class CabinetDto {
  const CabinetDto({required this.id, required this.name, this.color});

  final String id;
  final String name;
  final String? color;

  factory CabinetDto.fromJson(Map<String, dynamic> json) {
    return CabinetDto(
      id: asString(json['id']) ?? '',
      name: asString(json['name']) ?? '',
      color: asString(json['color']),
    );
  }

  Cabinet toDomain() {
    return Cabinet(id: id, name: name, color: color);
  }
}
