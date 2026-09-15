import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';

class ApiClient {
  ApiClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Dio get dio => _dio;

  factory ApiClient.create({String? baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: ApiConstants.defaultBaseUrl,
            ),
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        contentType: ApiConstants.json,
      ),
    );
    return ApiClient(dio: dio);
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) {
    return _wrap(
      () => _dio.get<dynamic>(
        path,
        queryParameters: query,
        options: _options(skipAuth),
      ),
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool skipAuth = false,
    Options? options,
  }) {
    return _wrap(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: _merge(options, skipAuth),
      ),
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    bool skipAuth = false,
  }) {
    return _wrap(
      () => _dio.put<dynamic>(path, data: data, options: _options(skipAuth)),
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    bool skipAuth = false,
  }) {
    return _wrap(
      () => _dio.patch<dynamic>(path, data: data, options: _options(skipAuth)),
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    bool skipAuth = false,
  }) {
    return _wrap(
      () => _dio.delete<dynamic>(path, options: _options(skipAuth)),
    );
  }

  Options _options(bool skipAuth) {
    return Options(extra: {ApiConstants.extraSkipAuth: skipAuth});
  }

  Options _merge(Options? options, bool skipAuth) {
    final extra = <String, dynamic>{
      ...?options?.extra,
      ApiConstants.extraSkipAuth:
          skipAuth || options?.extra?[ApiConstants.extraSkipAuth] == true,
    };
    return (options ?? Options()).copyWith(extra: extra);
  }

  Future<Response<dynamic>> _wrap(Future<Response<dynamic>> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  AppException _map(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String message = e.message ?? 'Request failed';
    if (data is Map) {
      message = (data['message'] ?? data['detail'] ?? message).toString();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.unknown && e.error is Exception) {
      final refused = message.contains('Connection refused') ||
          message.contains('Failed host lookup') ||
          (e.error?.toString().contains('Connection refused') ?? false);
      return NetworkException(
        refused
            ? 'Cannot reach ${ApiConstants.defaultBaseUrl}. Start the DentalPin API.'
            : message,
        cause: e,
      );
    }
    switch (status) {
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(
          message,
          subscriptionExpired: message == 'subscription_expired',
        );
      case 404:
        return NotFoundException(message);
      case 422:
        return ValidationException(message);
      default:
        return AppException(message, statusCode: status, cause: e);
    }
  }
}
