import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';

typedef TokenReader = Future<String?> Function();
typedef TokenRefresher = Future<bool> Function();

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Future<String?> Function() readAccessToken,
    required Future<bool> Function() refresh,
    required Future<void> Function() onLogout,
  })  : _readAccessToken = readAccessToken,
        _refresh = refresh,
        _onLogout = onLogout;

  static const String _extraRetried = '_authRetried';

  final TokenReader _readAccessToken;
  final TokenRefresher _refresh;
  final Future<void> Function() _onLogout;

  /// Set to the owning [Dio] when registered (e.g. `authInterceptor.dio = dio`).
  Dio? dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[ApiConstants.extraSkipAuth] != true) {
      final token = await _readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.authorization] =
            '${ApiConstants.bearerPrefix}$token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;
    if (options.extra[ApiConstants.extraSkipAuth] == true) {
      handler.next(err);
      return;
    }

    if (options.extra[_extraRetried] == true) {
      _onLogout().whenComplete(() => handler.next(err));
      return;
    }

    final path = options.path;
    if (path == ApiConstants.login || path == ApiConstants.refresh) {
      handler.next(err);
      return;
    }

    final client = dio;
    if (client == null) {
      handler.next(err);
      return;
    }

    _refresh().then((refreshed) async {
      if (!refreshed) {
        await _onLogout();
        handler.next(err);
        return;
      }

      final token = await _readAccessToken();
      options.extra[_extraRetried] = true;
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.authorization] =
            '${ApiConstants.bearerPrefix}$token';
      } else {
        options.headers.remove(ApiConstants.authorization);
      }

      client.fetch<dynamic>(options).then(
        handler.resolve,
        onError: (Object error) {
          if (error is DioException) {
            handler.next(error);
            return;
          }
          handler.next(
            DioException(
              requestOptions: options,
              error: error,
            ),
          );
        },
      );
    }).catchError((Object error, StackTrace stackTrace) {
      handler.next(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    });
  }
}
