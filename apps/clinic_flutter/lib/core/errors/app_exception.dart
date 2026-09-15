class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.cause});

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized'])
      : super(statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException(
    super.message, {
    this.subscriptionExpired = false,
  }) : super(statusCode: 403);

  final bool subscriptionExpired;
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found']) : super(statusCode: 404);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {this.errors = const []})
      : super(statusCode: 422);

  final List<String> errors;
}
