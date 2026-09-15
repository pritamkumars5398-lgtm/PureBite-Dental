import 'package:clinic_flutter/core/constants/api_constants.dart';
import 'package:clinic_flutter/core/errors/app_exception.dart';
import 'package:clinic_flutter/core/utils/json_utils.dart';
import 'package:clinic_flutter/core/utils/result.dart';
import 'package:clinic_flutter/data/services/api/api_client.dart';
import 'package:clinic_flutter/data/services/api/api_envelope.dart';

class OdontogramTooth {
  const OdontogramTooth({
    required this.number,
    required this.generalCondition,
    this.surfaces = const {},
  });

  final int number;
  final String generalCondition;
  final Map<String, String> surfaces;
}

class OdontogramTreatment {
  const OdontogramTreatment({
    required this.status,
    required this.toothNumbers,
  });

  final String status;
  final List<int> toothNumbers;
}

class Odontogram {
  const Odontogram({
    required this.patientId,
    required this.teeth,
    required this.treatments,
  });

  final String patientId;
  final List<OdontogramTooth> teeth;
  final List<OdontogramTreatment> treatments;

  bool get hasRecords => teeth.isNotEmpty || treatments.isNotEmpty;
}

class OdontogramRepository {
  OdontogramRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<Result<Odontogram>> getForPatient(String patientId) async {
    try {
      final response = await _api.get(
        ApiConstants.odontogramPatient(patientId),
      );
      final odontogram = _parse(response.data, patientId);
      if (odontogram == null) {
        return const Err(AppException('Invalid odontogram response'));
      }
      return Ok(odontogram);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  Odontogram? _parse(dynamic raw, String fallbackPatientId) {
    final root = asMap(raw);
    if (root == null) return null;
    final data = ApiEnvelope.fromJson(root, asMap).data;
    if (data == null) return null;

    final teeth = asList(data['teeth'])
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .map(_toothFromJson)
        .whereType<OdontogramTooth>()
        .toList();

    final treatments = asList(data['treatments'])
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .map(_treatmentFromJson)
        .toList();

    return Odontogram(
      patientId: asString(data['patient_id']) ?? fallbackPatientId,
      teeth: teeth,
      treatments: treatments,
    );
  }

  OdontogramTooth? _toothFromJson(Map<String, dynamic> json) {
    final number = asInt(json['tooth_number']);
    if (number == null) return null;
    final surfacesRaw = asMap(json['surfaces']) ?? const {};
    final surfaces = <String, String>{
      for (final entry in surfacesRaw.entries)
        if (asString(entry.key) != null && asString(entry.value) != null)
          asString(entry.key)!: asString(entry.value)!,
    };
    return OdontogramTooth(
      number: number,
      generalCondition: asString(json['general_condition']) ?? 'healthy',
      surfaces: surfaces,
    );
  }

  OdontogramTreatment _treatmentFromJson(Map<String, dynamic> json) {
    final nested = asList(json['teeth'])
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .map((tooth) => asInt(tooth['tooth_number']))
        .whereType<int>()
        .toList();
    final single = asInt(json['tooth_number']);
    return OdontogramTreatment(
      status: asString(json['status']) ?? '',
      toothNumbers: nested.isNotEmpty
          ? nested
          : (single != null ? [single] : const []),
    );
  }
}
