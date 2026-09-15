import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/result.dart';
import '../../domain/models/vat_type.dart';
import '../models/vat_type_dto.dart';
import '../services/api/api_client.dart';

class VatTypeRepository {
  VatTypeRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<VatType> _cache = const [];

  List<VatType> get cache => List.unmodifiable(_cache);

  Future<Result<List<VatType>>> listLocal() async => Ok(_cache);

  Future<Result<List<VatType>>> list() async {
    try {
      final response = await _api.get(ApiConstants.vatTypes);
      final list = _parseList(response.data);
      _cache = list;
      return Ok(list);
    } on AppException catch (e) {
      if (_cache.isNotEmpty) return Ok(_cache);
      return Err(e);
    } catch (e) {
      if (_cache.isNotEmpty) return Ok(_cache);
      return Err(e);
    }
  }

  List<VatType> _parseList(dynamic raw) {
    final map = asMap(raw);
    final list = map != null ? asList(map['data']) : asList(raw);
    return list
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .map((e) => VatTypeDto.fromJson(e).toDomain())
        .toList();
  }
}
