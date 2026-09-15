import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/result.dart';
import '../../domain/models/session.dart';
import '../services/api/api_client.dart';
import '../services/local/token_storage.dart';

class AuthRepository {
  AuthRepository({required ApiClient api, required TokenStorage storage})
      : _api = api,
        _storage = storage;

  final ApiClient _api;
  final TokenStorage _storage;

  Future<Result<Session>> login(String email, String password) async {
    try {
      final response = await _api.post(
        ApiConstants.login,
        data: _oauthPasswordBody(email, password),
        skipAuth: true,
        options: Options(
          contentType: ApiConstants.formUrlEncoded,
          headers: {ApiConstants.contentType: ApiConstants.formUrlEncoded},
        ),
      );
      final tokens = asMap(response.data);
      final access = asString(tokens?['access_token']);
      final refresh = asString(tokens?['refresh_token']);
      if (access == null || refresh == null) {
        return const Err(AppException('Invalid login response'));
      }
      await _storage.saveTokens(access: access, refresh: refresh);
      return restore();
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  Future<Result<Session>> restore() async {
    try {
      final token = await _storage.readAccess();
      if (token == null) {
        return const Err(UnauthorizedException());
      }
      final response = await _api.get(ApiConstants.me);
      final session = _parseMe(response.data);
      if (session == null) {
        return const Err(AppException('Invalid session'));
      }
      await _storage.saveClinicId(session.selectedClinicId);
      return Ok(session);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(e);
    }
  }

  Future<bool> refresh() async {
    try {
      final refreshToken = await _storage.readRefresh();
      if (refreshToken == null) return false;
      final response = await _api.post(
        ApiConstants.refresh,
        data: {'refresh_token': refreshToken},
        skipAuth: true,
      );
      final tokens = asMap(response.data);
      final access = asString(tokens?['access_token']);
      final refresh = asString(tokens?['refresh_token']) ?? refreshToken;
      if (access == null) return false;
      await _storage.saveTokens(access: access, refresh: refresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() => _storage.clear();

  static String _oauthPasswordBody(String email, String password) {
    return 'username=${Uri.encodeQueryComponent(email)}'
        '&password=${Uri.encodeQueryComponent(password)}';
  }

  Session? _parseMe(dynamic raw) {
    var map = asMap(raw);
    if (map == null) return null;
    if (map['data'] is Map) {
      map = asMap(map['data']);
    }
    if (map == null) return null;
    final userMap = asMap(map['user']);
    if (userMap == null) return null;
    final user = User(
      id: asString(userMap['id']) ?? '',
      email: asString(userMap['email']) ?? '',
      firstName: asString(userMap['first_name']) ?? '',
      lastName: asString(userMap['last_name']) ?? '',
      professionalId: asString(userMap['professional_id']),
      isActive: asBool(userMap['is_active'], fallback: true),
    );
    final clinicsRaw = asList(map['clinics']);
    final clinics = clinicsRaw
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .map(
          (c) => ClinicMembership(
            id: asString(c['id']) ?? '',
            name: asString(c['name']) ?? '',
            role: asString(c['role']) ?? '',
            subscriptionActive: asBool(c['subscription_active'], fallback: true),
            subscriptionEndDate: asString(c['subscription_end_date']),
          ),
        )
        .toList();
    final permissions = asList(map['permissions']).map((e) => e.toString()).toList();
    final selected = clinics.isNotEmpty ? clinics.first.id : '';
    return Session(
      user: user,
      clinics: clinics,
      permissions: permissions,
      selectedClinicId: selected,
    );
  }
}
