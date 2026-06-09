import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../widgets/quick_capture_popup.dart';
import 'hive_service.dart';

class ShakeService {
  ShakeService._();
  static final ShakeService _instance = ShakeService._();
  static ShakeService get instance => _instance;

  StreamSubscription<AccelerometerEvent>? _subscription;
  bool _isListening = false;
  VoidCallback? _onShake;

  static const double shakeThreshold = 15.0;
  static const Duration debounceDuration = Duration(seconds: 2);

  DateTime _lastShakeTime = DateTime.now().subtract(debounceDuration);

  GlobalKey<NavigatorState>? navigatorKey;

  void initialize() {
    _startListener();
  }

  void startListening() {
    if (!_isListening) {
      _startListener();
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  void _startListener() {
    if (kIsWeb) return;
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) return;
    _subscription?.cancel();

    try {
      _subscription =
          accelerometerEventStream(samplingPeriod: const Duration(milliseconds: 100))
              .listen(_onAccelerometerEvent);
      _isListening = true;
    } catch (_) {
      _isListening = false;
    }
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    if (magnitude < shakeThreshold) return;

    final now = DateTime.now();
    if (now.difference(_lastShakeTime) < debounceDuration) return;
    _lastShakeTime = now;

    if (!isEnabled()) return;

    _onShake?.call();

    if (navigatorKey?.currentContext != null) {
      QuickCapturePopup.show(navigatorKey!.currentContext!);
    }
  }

  bool isEnabled() {
    final user = HiveService.instance.getUser();
    return user?.shakeToCapture ?? false;
  }

  void dispose() {
    stopListening();
  }
}
