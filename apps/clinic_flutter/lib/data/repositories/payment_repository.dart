import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/page_utils.dart';
import '../../core/utils/result.dart';
import '../../domain/models/payment.dart';
import '../models/payment_dto.dart';
import '../services/api/api_client.dart';

class PaymentRepository {
  PaymentRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<Payment> _cache = const [];
  PaymentAging? _agingCache;

  List<Payment> get cache => List.unmodifiable(_cache);

  Future<Result<List<Payment>>> list({
    int page = 1,
    String? dateFrom,
    String? dateTo,
    String? method,
    String? patientId,
    bool? hasRefunds,
    bool? hasUnallocated,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.payments,
        query: {
          ApiConstants.queryPage: normalizePage(page),
          ApiConstants.queryPageSize: clampPatientPageSize(
            ApiConstants.patientsPageSize,
          ),
          if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
          if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
          if (method != null && method.isNotEmpty) 'method': method,
          if (patientId != null && patientId.isNotEmpty)
            ApiConstants.queryPatientId: patientId,
          'has_refunds': ?hasRefunds,
          'has_unallocated': ?hasUnallocated,
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

  Future<Result<PaymentAging>> aging() async {
    try {
      final response = await _api.get(ApiConstants.paymentsAging);
      final map = _unwrap(response.data);
      if (map == null) return const Err(NotFoundException());
      final aging = PaymentAgingDto.fromJson(map).toDomain();
      _agingCache = aging;
      return Ok(aging);
    } on AppException catch (e) {
      if (_agingCache != null) return Ok(_agingCache!);
      return Err(e);
    } catch (e) {
      if (_agingCache != null) return Ok(_agingCache!);
      return Err(e);
    }
  }

  List<Payment> _parseList(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => PaymentDto.fromJson(e).toDomain())
            .toList();
      }
    }
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map((e) => PaymentDto.fromJson(e).toDomain())
          .toList();
    }
    return const [];
  }

  Map<String, dynamic>? _unwrap(dynamic raw) {
    final map = asMap(raw);
    if (map == null) return null;
    final data = asMap(map['data']);
    if (data != null) return data;
    if (map.containsKey('currency') || map.containsKey('buckets')) return map;
    return null;
  }
}
