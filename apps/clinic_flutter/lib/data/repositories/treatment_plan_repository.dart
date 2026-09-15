import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/page_utils.dart';
import '../../core/utils/result.dart';
import '../../domain/models/treatment_plan.dart';
import '../models/treatment_plan_dto.dart';
import '../services/api/api_client.dart';

class TreatmentPlanRepository {
  TreatmentPlanRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<TreatmentPlan> _cache = const [];

  List<TreatmentPlan> get cache => List.unmodifiable(_cache);

  Future<Result<List<TreatmentPlan>>> listLocal() async => Ok(_cache);

  Future<Result<List<TreatmentPlan>>> list({
    int page = 1,
    String? patientId,
    List<String>? status,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.treatmentPlans,
        query: {
          ApiConstants.queryPage: normalizePage(page),
          ApiConstants.queryPageSize: clampPatientPageSize(
            ApiConstants.patientsPageSize,
          ),
          if (patientId != null && patientId.isNotEmpty)
            ApiConstants.queryPatientId: patientId,
          if (status != null && status.isNotEmpty)
            ApiConstants.queryStatus: status,
        },
      );
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

  List<TreatmentPlan> _parseList(dynamic raw) {
    final map = asMap(raw);
    final list = map != null ? asList(map['data']) : asList(raw);
    return list
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .map((e) => TreatmentPlanDto.fromJson(e).toDomain())
        .toList();
  }
}
