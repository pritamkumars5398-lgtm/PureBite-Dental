import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/result.dart';
import '../../domain/models/cabinet.dart';
import '../models/cabinet_dto.dart';
import '../services/api/api_client.dart';

class CabinetRepository {
  CabinetRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<Cabinet> _cache = const [];

  List<Cabinet> get cache => List.unmodifiable(_cache);

  Future<Result<List<Cabinet>>> listLocal() async => Ok(_cache);

  Future<Result<List<Cabinet>>> list() async {
    try {
      final response = await _api.get(ApiConstants.cabinets);
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

  List<Cabinet> _parseList(dynamic raw) {
    final map = asMap(raw);
    final list = map != null ? asList(map['data']) : asList(raw);
    return list
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .map((e) => CabinetDto.fromJson(e).toDomain())
        .toList();
  }
}
