import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ShakeCallback = void Function();

class ShakeService {
  static const _channel = MethodChannel('com.timbo.app/shake');

  ShakeCallback? onShake;

  Future<void> init() async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onShake':
          onShake?.call();
          break;
      }
    });
  }

  Future<void> start() async {
    try {
      await _channel.invokeMethod('startShakeService');
    } catch (e) {
      debugPrint('Failed to start shake service: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopShakeService');
    } catch (e) {
      debugPrint('Failed to stop shake service: $e');
    }
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
  }
}

final shakeServiceProvider = Provider<ShakeService>((ref) {
  return ShakeService();
});
