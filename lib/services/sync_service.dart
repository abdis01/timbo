import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  final _onlineController = StreamController<bool>.broadcast();
  bool _isOnline = true;

  Stream<bool> get onOnlineChanged => _onlineController.stream;
  bool get isOnline => _isOnline;

  SyncService();

  void initialize() {
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (online && !_isOnline) {
        _isOnline = true;
        _onlineController.add(true);
      } else if (!online) {
        _isOnline = false;
        _onlineController.add(false);
      }
    });
  }

  void dispose() {
    _sub?.cancel();
    _onlineController.close();
  }
}
