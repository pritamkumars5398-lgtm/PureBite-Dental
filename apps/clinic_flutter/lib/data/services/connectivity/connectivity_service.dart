import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps [Connectivity] and exposes a simple online/offline signal.
///
/// [ConnectivityResult.none] (and other non-data transports) count as offline.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<bool> get onOnline {
    _ensureListening();
    return _onlineController.stream;
  }

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _onlineController.close();
  }

  void _ensureListening() {
    if (_subscription != null) return;

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (!_onlineController.isClosed) {
        _onlineController.add(_isOnline(results));
      }
    });

    unawaited(
      _connectivity.checkConnectivity().then((results) {
        if (!_onlineController.isClosed) {
          _onlineController.add(_isOnline(results));
        }
      }),
    );
  }

  static bool _isOnline(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
  }
}
