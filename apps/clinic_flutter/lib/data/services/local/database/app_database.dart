/// Drift schema lives in [tables.dart]. Codegen is deferred until
/// `dart run build_runner build` succeeds on this SDK.
///
/// Repositories currently cache in memory so the app compiles without
/// `app_database.g.dart`.
class AppDatabase {
  Future<void> close() async {}
}
