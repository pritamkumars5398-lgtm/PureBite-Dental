import 'package:clinic_flutter/core/constants/api_constants.dart';
import 'package:clinic_flutter/core/errors/app_exception.dart';
import 'package:clinic_flutter/core/utils/page_utils.dart';
import 'package:clinic_flutter/core/utils/result.dart';
import 'package:clinic_flutter/data/models/patient_dto.dart';
import 'package:clinic_flutter/data/services/api/api_client.dart';
import 'package:clinic_flutter/domain/models/patient.dart';

class PatientRepository {
  PatientRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<Patient> _cache = const [];

  List<Patient> get cache => List.unmodifiable(_cache);

  Future<Result<List<Patient>>> listLocal() async => Ok(_cache);

  Future<Result<List<Patient>>> search({String? query, int page = 1}) async {
    try {
      final response = await _api.get(
        ApiConstants.patients,
        query: {
          if (query != null && query.isNotEmpty) ApiConstants.querySearch: query,
          ApiConstants.queryPage: normalizePage(page),
          ApiConstants.queryPageSize: clampPatientPageSize(
            ApiConstants.patientsPageSize,
          ),
        },
      );
      final raw = response.data;
      final list = _parseList(raw);
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

  Future<Result<Patient>> create({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.patients,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'email': email,
        },
      );
      final map = _unwrap(response.data);
      if (map == null) return const Err(AppException('Invalid patient response'));
      final patient = PatientDto.fromJson(map).toDomain();
      _cache = [patient, ..._cache];
      return Ok(patient);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  Future<Result<Patient>> getById(String id) async {
    final cached = _cache.where((p) => p.id == id);
    if (cached.isNotEmpty) return Ok(cached.first);
    try {
      final response = await _api.get(ApiConstants.patient(id));
      final map = _unwrap(response.data);
      if (map == null) return const Err(NotFoundException());
      final patient = PatientDto.fromJson(map).toDomain();
      return Ok(patient);
    } on AppException catch (e) {
      return Err(e);
    }
  }

  Future<Result<void>> pullRemote({String? search}) async {
    final result = await this.search(query: search);
    return result.fold(ok: (_) => const Ok(null), err: Err.new);
  }

  List<Patient> _parseList(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => PatientDto.fromJson(e).toDomain())
            .toList();
      }
    }
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map((e) => PatientDto.fromJson(e).toDomain())
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
