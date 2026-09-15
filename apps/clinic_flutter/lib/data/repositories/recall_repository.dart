import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/result.dart';
import '../../domain/models/recall.dart';
import '../models/recall_dto.dart';
import '../services/api/api_client.dart';

class RecallRepository {
  RecallRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<Recall> _cache = const [];
  RecallDashboardStats? _dashboardCache;

  Future<Result<List<Recall>>> list() async {
    try {
      final response = await _api.get(ApiConstants.recalls);
      _cache = _parseList(response.data);
      return Ok(_cache);
    } on AppException catch (e) {
      if (_cache.isNotEmpty) return Ok(_cache);
      return Err(e);
    } catch (e) {
      if (_cache.isNotEmpty) return Ok(_cache);
      return Err(e);
    }
  }

  Future<Result<RecallDashboardStats>> dashboard() async {
    try {
      final response = await _api.get(ApiConstants.recallsDashboard);
      final map = _unwrap(response.data);
      if (map == null) {
        return const Err(AppException('Expected recall dashboard stats'));
      }
      final stats = RecallDashboardStatsDto.fromJson(map).toDomain();
      _dashboardCache = stats;
      return Ok(stats);
    } on AppException catch (e) {
      final cached = _dashboardCache;
      if (cached != null) return Ok(cached);
      return Err(e);
    } catch (e) {
      final cached = _dashboardCache;
      if (cached != null) return Ok(cached);
      return Err(e);
    }
  }

  List<Recall> _parseList(dynamic raw) {
    final map = asMap(raw);
    final list = map != null ? asList(map['data']) : asList(raw);
    return list
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .map(RecallDto.fromJson)
        .map((dto) => dto.toDomain())
        .toList();
  }

  Map<String, dynamic>? _unwrap(dynamic raw) {
    final map = asMap(raw);
    if (map == null) return null;
    final data = asMap(map['data']);
    if (data != null) return data;
    if (map.containsKey('due_this_week')) return map;
    return null;
  }
}
