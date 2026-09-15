import 'package:clinic_flutter/core/constants/api_constants.dart';
import 'package:clinic_flutter/core/errors/app_exception.dart';
import 'package:clinic_flutter/core/utils/json_utils.dart';
import 'package:clinic_flutter/core/utils/result.dart';
import 'package:clinic_flutter/data/models/catalog_item_dto.dart';
import 'package:clinic_flutter/data/services/api/api_client.dart';
import 'package:clinic_flutter/data/services/api/api_envelope.dart';
import 'package:clinic_flutter/domain/models/catalog_item.dart';

class CatalogRepository {
  CatalogRepository({required ApiClient api}) : _api = api;

  static const int _pageSize = 100;

  final ApiClient _api;
  List<CatalogItem> _cache = const [];

  List<CatalogItem> get cache => List.unmodifiable(_cache);

  Future<Result<List<CatalogItem>>> listLocal() async => Ok(_cache);

  Future<Result<List<CatalogItem>>> list({int page = 1}) async {
    try {
      final response = await _api.get(
        ApiConstants.catalogItems,
        query: {
          ApiConstants.queryPage: page,
          ApiConstants.queryPageSize: _pageSize,
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

  List<CatalogItem> _parseList(dynamic raw) {
    final map = asMap(raw);
    if (map != null && map['data'] is List) {
      try {
        final envelope = PaginatedEnvelope.fromJson(
          map,
          (value) => CatalogItemDto.fromJson(asMap(value) ?? {}).toDomain(),
        );
        return envelope.data;
      } on FormatException {
        // Fall through to a defensive list parse.
      }
    }
    final items = map != null ? asList(map['data']) : asList(raw);
    return items
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .map((e) => CatalogItemDto.fromJson(e).toDomain())
        .toList();
  }
}
