import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/result.dart';
import '../../domain/models/aging_report.dart';
import '../services/api/api_client.dart';
import '../services/api/api_envelope.dart';

class ReportsRepository {
  ReportsRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<Result<AgingReport>> aging() async {
    try {
      final response = await _api.get(ApiConstants.paymentsAging);
      return Ok(_parse(response.data));
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  AgingReport _parse(dynamic raw) {
    final map = asMap(raw);
    if (map == null) return AgingReport.empty;
    final payload = ApiEnvelope.fromJson(map, asMap).data ?? map;
    return AgingReport(
      currency: asString(payload['currency']) ?? '',
      buckets: asList(payload['buckets'])
          .map(asMap)
          .whereType<Map<String, dynamic>>()
          .map(
            (bucket) => AgingBucket(
              label: asString(bucket['label']) ?? '',
              total: asString(bucket['total']) ?? '0',
              patientCount: asInt(bucket['patient_count']) ?? 0,
            ),
          )
          .toList(),
    );
  }
}
