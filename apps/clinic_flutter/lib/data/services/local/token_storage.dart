import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/storage_keys.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              mOptions: MacOsOptions(useDataProtectionKeyChain: false),
            );

  final FlutterSecureStorage _storage;
  final Map<String, String> _memory = {};

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    _memory[StorageKeys.accessToken] = access;
    _memory[StorageKeys.refreshToken] = refresh;
    await _write(StorageKeys.accessToken, access);
    await _write(StorageKeys.refreshToken, refresh);
  }

  Future<String?> readAccess() => _read(StorageKeys.accessToken);

  Future<String?> readRefresh() => _read(StorageKeys.refreshToken);

  Future<void> saveClinicId(String id) async {
    _memory[StorageKeys.selectedClinicId] = id;
    await _write(StorageKeys.selectedClinicId, id);
  }

  Future<String?> readClinicId() => _read(StorageKeys.selectedClinicId);

  Future<void> clear() async {
    _memory.clear();
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value).timeout(
            const Duration(seconds: 2),
          );
    } catch (_) {
      // macOS sandbox Keychain can reject or stall writes; memory still covers this session.
    }
  }

  Future<String?> _read(String key) async {
    final cached = _memory[key];
    if (cached != null) return cached;
    try {
      final value = await _storage.read(key: key).timeout(
            const Duration(seconds: 2),
          );
      if (value != null) _memory[key] = value;
      return value;
    } catch (_) {
      return null;
    }
  }
}
