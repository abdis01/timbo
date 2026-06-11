import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database.dart';
import 'capture_service.dart';

class SyncService {
  final TimboDatabase _db;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  final _onlineController = StreamController<bool>.broadcast();
  bool _isOnline = true;

  Stream<bool> get onOnlineChanged => _onlineController.stream;
  bool get isOnline => _isOnline;

  SyncService(this._db);

  void initialize() {
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (online && !_isOnline) {
        _isOnline = true;
        _onlineController.add(true);
        _syncPending();
      } else if (!online) {
        _isOnline = false;
        _onlineController.add(false);
      }
    });
  }

  Future<void> _syncPending() async {
    final service = CaptureService(_db);
    await service.processPendingCaptures();
  }

  void dispose() {
    _sub?.cancel();
    _onlineController.close();
  }
}
