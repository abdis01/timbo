import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  final _onlineController = StreamController<bool>.broadcast();
  bool _isOnline = true;

  Stream<bool> get onOnlineChanged => _onlineController.stream;
  bool get isOnline => _isOnline;

  SyncService();

  void initialize() {
    _sub = Connectivity().onConnectivityChanged.listen(
      (results) {
        try {
          final online = !results.contains(ConnectivityResult.none);
          if (online && !_isOnline) {
            _isOnline = true;
            if (!_onlineController.isClosed) _onlineController.add(true);
          } else if (!online) {
            _isOnline = false;
            if (!_onlineController.isClosed) _onlineController.add(false);
          }
        } catch (e) {
          debugPrint('Connectivity error: $e');
        }
      },
      onError: (error) {
        debugPrint('Connectivity stream error: $error');
      },
    );
  }

  void dispose() {
    _sub?.cancel();
    if (!_onlineController.isClosed) _onlineController.close();
  }
}
