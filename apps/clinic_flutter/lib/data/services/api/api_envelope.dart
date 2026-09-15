/// Standard success wrappers from the DentalPin API.
///
/// Login tokens are parsed elsewhere (unwrapped). See docs/03-api-constants.md.
class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.data,
    this.message,
  });

  final T data;
  final String? message;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic value) parse,
  ) {
    if (json.containsKey('data')) {
      return ApiEnvelope(
        data: parse(json['data']),
        message: json['message'] as String?,
      );
    }
    return ApiEnvelope(data: parse(json));
  }
}

class PaginatedEnvelope<T> {
  const PaginatedEnvelope({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    this.message,
  });

  final List<T> data;
  final int total;
  final int page;
  final int pageSize;
  final String? message;

  factory PaginatedEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic value) parse,
  ) {
    final items = json['data'];
    if (items is! List) {
      throw FormatException('Expected paginated list in response');
    }

    return PaginatedEnvelope(
      data: items.map(parse).toList(growable: false),
      total: _asInt(json['total']),
      page: _asInt(json['page']),
      pageSize: _asInt(json['page_size']),
      message: json['message'] as String?,
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Expected int, got $value');
}
