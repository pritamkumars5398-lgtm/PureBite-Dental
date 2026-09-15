import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/page_utils.dart';
import '../../core/utils/result.dart';
import '../../domain/models/appointment.dart';
import '../services/api/api_client.dart';

class AppointmentRepository {
  AppointmentRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  List<Appointment> _cache = const [];

  Future<Result<List<Appointment>>> listLocal() async => Ok(_cache);

  Future<Result<List<Appointment>>> listRange({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.appointments,
        query: {
          ApiConstants.queryStartDate: toIso(start),
          ApiConstants.queryEndDate: toIso(end),
          ApiConstants.queryPage: 1,
          ApiConstants.queryPageSize: clampAppointmentPageSize(
            ApiConstants.appointmentsPageSize,
          ),
        },
      );
      _cache = _parse(response.data);
      return Ok(_cache);
    } on AppException catch (e) {
      if (_cache.isNotEmpty) return Ok(_cache);
      return Err(e);
    } catch (e) {
      if (_cache.isNotEmpty) return Ok(_cache);
      return Err(e);
    }
  }

  Future<Result<Appointment>> create({
    required String patientId,
    required String professionalId,
    required DateTime startTime,
    required DateTime endTime,
    String? cabinet,
    String? cabinetId,
    String? treatmentType,
    String? color,
    List<String>? plannedItemIds,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.appointments,
        data: {
          'patient_id': patientId,
          'professional_id': professionalId,
          'start_time': toIso(startTime),
          'end_time': toIso(endTime),
          if (cabinet != null && cabinet.isNotEmpty) 'cabinet': cabinet,
          if (cabinetId != null && cabinetId.isNotEmpty) 'cabinet_id': cabinetId,
          if (treatmentType != null && treatmentType.isNotEmpty)
            'treatment_type': treatmentType,
          if (color != null && color.isNotEmpty) 'color': color,
          if (plannedItemIds != null && plannedItemIds.isNotEmpty)
            'planned_item_ids': plannedItemIds,
        },
      );
      final map = _unwrap(response.data);
      if (map == null) {
        return const Err(AppException('Invalid appointment response'));
      }
      final appointment = _fromJson(map);
      _cache = [..._cache, appointment];
      return Ok(appointment);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  Map<String, dynamic>? _unwrap(dynamic raw) {
    final map = asMap(raw);
    if (map == null) return null;
    final data = asMap(map['data']);
    if (data != null) return data;
    if (map.containsKey('id')) return map;
    return null;
  }

  List<Appointment> _parse(dynamic raw) {
    final map = asMap(raw);
    final list = map != null ? asList(map['data']) : asList(raw);
    return list.map(asMap).whereType<Map<String, dynamic>>().map(_fromJson).toList();
  }

  Appointment _fromJson(Map<String, dynamic> json) {
    final patient = asMap(json['patient']);
    final first = asString(patient?['first_name']) ?? '';
    final last = asString(patient?['last_name']) ?? '';
    final name = '$first $last'.trim();
    return Appointment(
      id: asString(json['id']) ?? '',
      clinicId: asString(json['clinic_id']) ?? '',
      patientId: asString(json['patient_id']),
      professionalId: asString(json['professional_id']) ?? '',
      startTime: asDateTime(json['start_time']) ?? DateTime.now(),
      endTime: asDateTime(json['end_time']) ?? DateTime.now(),
      status: asString(json['status']) ?? 'scheduled',
      treatmentType: asString(json['treatment_type']),
      patientName: name.isEmpty ? asString(json['cabinet']) : name,
      cabinet: asString(json['cabinet']),
      color: asString(json['color']),
      updatedAt: asDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }
}
