import 'package:clinic_flutter/core/constants/api_constants.dart';
import 'package:clinic_flutter/core/errors/app_exception.dart';
import 'package:clinic_flutter/core/utils/page_utils.dart';
import 'package:clinic_flutter/core/utils/result.dart';
import 'package:clinic_flutter/data/models/quote_dto.dart';
import 'package:clinic_flutter/data/services/api/api_client.dart';
import 'package:clinic_flutter/domain/models/quote.dart';

class QuoteRepository {
  QuoteRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<Quote> _cache = const [];

  List<Quote> get cache => List.unmodifiable(_cache);

  Future<Result<List<Quote>>> listLocal() async => Ok(_cache);

  Future<Result<List<Quote>>> search({String? query, int page = 1}) async {
    try {
      final response = await _api.get(
        ApiConstants.budgets,
        query: {
          if (query != null && query.isNotEmpty) ApiConstants.querySearch: query,
          ApiConstants.queryPage: normalizePage(page),
          ApiConstants.queryPageSize: clampPatientPageSize(
            ApiConstants.patientsPageSize,
          ),
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

  Future<Result<Quote>> getById(String id) async {
    final cached = _cache.where((q) => q.id == id);
    if (cached.isNotEmpty) return Ok(cached.first);
    try {
      final response = await _api.get(ApiConstants.budget(id));
      final map = _unwrap(response.data);
      if (map == null) return const Err(NotFoundException());
      return Ok(QuoteDto.fromJson(map).toDomain());
    } on AppException catch (e) {
      return Err(e);
    }
  }

  Future<Result<void>> pullRemote({String? search}) async {
    final result = await this.search(query: search);
    return result.fold(ok: (_) => const Ok(null), err: Err.new);
  }

  List<Quote> _parseList(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => QuoteDto.fromJson(e).toDomain())
            .toList();
      }
    }
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map((e) => QuoteDto.fromJson(e).toDomain())
          .toList();
    }
    return const [];
  }

  Map<String, dynamic>? _unwrap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      if (raw.containsKey('id')) return raw;
    }
    return null;
  }
}
