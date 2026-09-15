import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/result.dart';
import '../../domain/models/clinic.dart';
import '../services/api/api_client.dart';

class ClinicRepository {
  ClinicRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  Clinic? _cache;

  Clinic? get cache => _cache;

  Future<Result<Clinic>> fetchCurrent() async {
    try {
      final response = await _api.get(ApiConstants.clinics);
      final clinics = _parseList(response.data);
      if (clinics.isEmpty) {
        return const Err(NotFoundException());
      }
      _cache = clinics.first;
      return Ok(_cache!);
    } on AppException catch (e) {
      if (_cache != null) return Ok(_cache!);
      return Err(e);
    } catch (e) {
      if (_cache != null) return Ok(_cache!);
      return Err(e);
    }
  }

  Future<Result<Clinic>> update(ClinicUpdate data) async {
    try {
      final response = await _api.put(
        ApiConstants.clinics,
        data: _updateBody(data),
      );
      final clinic = _parseOne(response.data);
      if (clinic == null) {
        return const Err(AppException('Invalid clinic response'));
      }
      _cache = clinic;
      return Ok(clinic);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  Map<String, dynamic> _updateBody(ClinicUpdate data) {
    return {
      if (data.name != null) 'name': data.name,
      if (data.taxId != null) 'tax_id': data.taxId,
      if (data.legalName != null) 'legal_name': data.legalName,
      if (data.phone != null) 'phone': data.phone,
      if (data.email != null) 'email': data.email,
      if (data.timezone != null) 'timezone': data.timezone,
      if (data.address != null) 'address': data.address,
    };
  }

  List<Clinic> _parseList(dynamic raw) {
    final map = asMap(raw);
    final list = map != null ? asList(map['data']) : asList(raw);
    return list
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .map(_fromJson)
        .toList();
  }

  Clinic? _parseOne(dynamic raw) {
    final map = asMap(raw);
    if (map == null) return null;
    final data = asMap(map['data']) ?? (map.containsKey('id') ? map : null);
    if (data == null) return null;
    return _fromJson(data);
  }

  Clinic _fromJson(Map<String, dynamic> json) {
    final addressRaw = asMap(json['address']);
    final address = <String, String>{};
    if (addressRaw != null) {
      for (final entry in addressRaw.entries) {
        final value = asString(entry.value);
        if (value != null) address[entry.key] = value;
      }
    }
    return Clinic(
      id: asString(json['id']) ?? '',
      name: asString(json['name']) ?? '',
      taxId: asString(json['tax_id']) ?? '',
      legalName: asString(json['legal_name']),
      phone: asString(json['phone']),
      email: asString(json['email']),
      timezone: asString(json['timezone']) ?? '',
      currency: asString(json['currency']) ?? '',
      address: address,
    );
  }
}
