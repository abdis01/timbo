import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../providers/providers.dart';

class ForegroundShakeDetector {
  StreamSubscription<UserAccelerometerEvent>? _subscription;
  DateTime? _lastShakeTime;
  bool _isListening = false;

  final void Function() onShakeDetected;

  ForegroundShakeDetector({required this.onShakeDetected});

  void startListening(WidgetRef ref) {
    if (_isListening) return;
    _isListening = true;

    _subscription = userAccelerometerEventStream().listen(
      (event) {
        try {
          final shakeEnabled = ref.read(shakeEnabledProvider);
          if (!shakeEnabled) return;

          final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

          if (magnitude > 15.0) {
            final now = DateTime.now();
            if (_lastShakeTime == null || now.difference(_lastShakeTime!).inMilliseconds > 1000) {
              _lastShakeTime = now;
              onShakeDetected();
            }
          }
        } catch (e) {
          debugPrint('Shake detector error: $e');
        }
      },
      onError: (error) {
        debugPrint('Accelerometer stream error: $error');
        _subscription?.cancel();
        _subscription = null;
        _isListening = false;
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _lastShakeTime = null;
  }

  void dispose() {
    stopListening();
  }
}

final foregroundShakeDetectorProvider = Provider<ForegroundShakeDetector>((ref) {
  final detector = ForegroundShakeDetector(onShakeDetected: () {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback not available: $e');
    }
  });

  ref.onDispose(() {
    detector.dispose();
  });

  return detector;
});
