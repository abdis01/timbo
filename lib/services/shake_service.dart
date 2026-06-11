import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShakeService {
  static const _channel = MethodChannel('com.timbo.app/shake');
  final _controller = StreamController<void>.broadcast();
  Stream<void> get onShake => _controller.stream;

  void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onShake') {
        try { HapticFeedback.lightImpact(); } catch (_) {}
        _controller.add(null);
      }
    });
  }

  void dispose() => _controller.close();
}

final shakeServiceProvider = Provider<ShakeService>((ref) {
  final service = ShakeService()..initialize();
  ref.onDispose(service.dispose);
  return service;
});
