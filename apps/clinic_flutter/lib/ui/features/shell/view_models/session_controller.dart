import 'dart:async';

import 'package:clinic_flutter/data/repositories/auth_repository.dart';
import 'package:clinic_flutter/data/services/connectivity/connectivity_service.dart';
import 'package:clinic_flutter/domain/models/session.dart';
import 'package:flutter/foundation.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthRepository authRepository,
    required ConnectivityService connectivity,
  })  : _auth = authRepository,
        _connectivity = connectivity {
    _sub = _connectivity.onOnline.listen((online) {
      _online = online;
      notifyListeners();
    });
  }

  final AuthRepository _auth;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _sub;

  Session? _session;
  bool _online = true;
  bool _ready = false;

  Object? lastLoginError;

  Session? get session => _session;
  bool get isAuthenticated => _session != null;
  bool get isOnline => _online;
  bool get isReady => _ready;

  Future<void> restore() async {
    _online = await _connectivity.isOnline;
    final result = await _auth.restore();
    _session = result.dataOrNull;
    _ready = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    lastLoginError = null;
    final result = await _auth.login(email, password);
    _session = result.dataOrNull;
    lastLoginError = result.fold(ok: (_) => null, err: (e) => e);
    notifyListeners();
    return _session != null;
  }

  Future<void> logout() async {
    await _auth.logout();
    _session = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
