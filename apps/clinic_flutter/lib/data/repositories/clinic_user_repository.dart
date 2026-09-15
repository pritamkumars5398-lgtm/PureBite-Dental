import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/result.dart';
import '../../domain/models/clinic_staff_user.dart';
import '../models/clinic_user_dto.dart';
import '../services/api/api_client.dart';
import '../services/api/api_envelope.dart';

class ClinicUserRepository {
  ClinicUserRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<ClinicStaffUser> _cache = const [];

  List<ClinicStaffUser> get cache => List.unmodifiable(_cache);

  Future<Result<List<ClinicStaffUser>>> listLocal() async => Ok(_cache);

  Future<Result<List<ClinicStaffUser>>> list() async {
    try {
      final response = await _api.get(ApiConstants.clinicUsers);
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

  List<ClinicStaffUser> _parseList(dynamic raw) {
    ClinicStaffUser parseItem(dynamic value) {
      return ClinicUserDto.fromJson(asMap(value) ?? const {}).toDomain();
    }

    final map = asMap(raw);
    if (map != null && map['data'] is List) {
      try {
        return PaginatedEnvelope.fromJson(map, parseItem).data;
      } on FormatException {
        return asList(map['data']).map(parseItem).toList();
      }
    }
    if (raw is List) {
      return raw.map(parseItem).toList();
    }
    return const [];
  }
}
