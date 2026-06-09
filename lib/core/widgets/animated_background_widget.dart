import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AnimatedBackgroundWidget extends StatefulWidget {
  final Widget backgroundImage;
  final int particleCount;

  const AnimatedBackgroundWidget({
    super.key,
    required this.backgroundImage,
    this.particleCount = 20,
  });

  @override
  State<AnimatedBackgroundWidget> createState() =>
      _AnimatedBackgroundWidgetState();
}

class _AnimatedBackgroundWidgetState extends State<AnimatedBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;
  List<_Particle> _particles = [];
  final Random _random = Random();
  StreamSubscription? _accelerometerSub;
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  void initState() {
    super.initState();

    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _opacityAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeInOut),
    );
    _opacityController.repeat(reverse: true);

    _initParticles();

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        _accelerometerSub = accelerometerEventStream().listen((event) {
        if (mounted) {
          setState(() {
            _tiltX = (event.x.clamp(-5.0, 5.0) / 5.0) * 3;
            _tiltY = (event.y.clamp(-5.0, 5.0) / 5.0) * 3;
          });
        }
        });
      } catch (_) {
        _accelerometerSub = null;
      }
    }
  }

  void _initParticles() {
    _particles = List.generate(widget.particleCount, (i) => _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 2 + 1,
          speed: _random.nextDouble() * 0.003 + 0.001,
          opacity: _random.nextDouble() * 0.5 + 0.1,
        ));
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _accelerometerSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    for (var p in _particles) {
      p.y -= p.speed;
      if (p.y < -0.05) {
        p.y = 1.05;
        p.x = _random.nextDouble();
      }
    }

    return AnimatedBuilder(
      animation: _opacityController,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_tiltY * 0.0174533)
            ..rotateY(-_tiltX * 0.0174533),
          alignment: Alignment.center,
          child: Stack(
            children: [
              Opacity(
                opacity: _opacityAnimation.value,
                child: widget.backgroundImage,
              ),
              ...List.generate(
                _particles.length,
                (i) => Positioned(
                  left: _particles[i].x * screenSize.width,
                  top: _particles[i].y * screenSize.height,
                  child: Opacity(
                    opacity: _particles[i].opacity,
                    child: Container(
                      width: _particles[i].size,
                      height: _particles[i].size,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}
