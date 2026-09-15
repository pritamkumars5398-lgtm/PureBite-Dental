import 'package:clinic_flutter/core/constants/api_constants.dart';
import 'package:clinic_flutter/core/errors/app_exception.dart';
import 'package:clinic_flutter/core/utils/page_utils.dart';
import 'package:clinic_flutter/core/utils/result.dart';
import 'package:clinic_flutter/data/models/invoice_dto.dart';
import 'package:clinic_flutter/data/services/api/api_client.dart';
import 'package:clinic_flutter/domain/models/invoice.dart';

class InvoiceRepository {
  InvoiceRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<Invoice> _cache = const [];

  List<Invoice> get cache => List.unmodifiable(_cache);

  Future<Result<List<Invoice>>> listLocal() async => Ok(_cache);

  Future<Result<List<Invoice>>> search({String? query, int page = 1}) async {
    try {
      final response = await _api.get(
        ApiConstants.invoices,
        query: {
          if (query != null && query.isNotEmpty)
            ApiConstants.querySearch: query,
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

  List<Invoice> _parseList(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => InvoiceDto.fromJson(e).toDomain())
            .toList();
      }
    }
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map((e) => InvoiceDto.fromJson(e).toDomain())
          .toList();
    }
    return const [];
  }
}
