sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get dataOrNull => switch (this) {
        Ok(:final value) => value,
        Err() => null,
      };

  R fold<R>({
    required R Function(T value) ok,
    required R Function(Object error) err,
  }) {
    return switch (this) {
      Ok(:final value) => ok(value),
      Err(:final error) => err(error),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final Object error;
}
