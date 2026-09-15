import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/result.dart';
import '../services/api/api_client.dart';
import '../services/api/api_envelope.dart';

class CopilotRepository {
  CopilotRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<Result<List<String>>> pending() async {
    try {
      final response = await _api.get(ApiConstants.copilotPending);
      final map = asMap(response.data);
      if (map == null) return const Ok([]);
      final envelope = ApiEnvelope.fromJson(map, asList);
      final labels = envelope.data
          .map(_pendingLabel)
          .whereType<String>()
          .where((text) => text.isNotEmpty)
          .toList();
      return Ok(labels);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  Future<Result<String>> startSession({Map<String, dynamic>? context}) async {
    try {
      final response = await _api.post(
        ApiConstants.copilotSessions,
        data: {'context': context ?? <String, dynamic>{}},
      );
      final map = asMap(response.data);
      if (map == null) {
        return const Err(AppException('Invalid session response'));
      }
      final data = ApiEnvelope.fromJson(map, asMap).data;
      final id = asString(data?['id']);
      if (id == null || id.isEmpty) {
        return const Err(AppException('Invalid session response'));
      }
      return Ok(id);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  Future<Result<void>> sendMessage(String conversationId, String text) async {
    try {
      await _api.post(
        ApiConstants.copilotSessionMessages(conversationId),
        data: {'content': text},
        options: Options(responseType: ResponseType.plain),
      );
      return const Ok(null);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  String? _pendingLabel(dynamic item) {
    if (item is String) return item;
    final map = asMap(item);
    if (map == null) return null;
    return asString(map['title']) ??
        asString(map['number']) ??
        asString(map['kind']);
  }
}
