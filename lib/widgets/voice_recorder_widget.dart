import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../config/theme.dart';
import '../services/media_service.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final void Function(String filePath, Duration duration) onRecordingComplete;

  const VoiceRecorderWidget({
    super.key,
    required this.onRecordingComplete,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  final Record _recorder = Record();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;
  Duration _recordedDuration = Duration.zero;
  Duration _playPosition = Duration.zero;

  Timer? _timer;
  int _elapsedSeconds = 0;

  late AnimationController _pulseController;
  late AnimationController _colorShiftController;

  double _amplitude = 0.0;
  StreamSubscription<Amplitude>? _amplitudeSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _colorShiftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _playPosition = pos);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    _player.dispose();
    _pulseController.dispose();
    _colorShiftController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    final path =
        '${audioDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(path: path);

    _amplitudeSub =
        _recorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen(
      (amp) {
        if (mounted) {
          setState(() {
            _amplitude = (amp.current + 160) / 160;
            if (_amplitude < 0) _amplitude = 0;
            if (_amplitude > 1) _amplitude = 1;
          });
        }
      },
    );

    setState(() {
      _isRecording = true;
      _elapsedSeconds = 0;
      _recordedPath = null;
      _recordedDuration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _timer?.cancel();
    _amplitudeSub?.cancel();

    if (path != null && mounted) {
      final file = File(path);
      if (await file.exists()) {
        final duration = await _getAudioDuration(path);
        setState(() {
          _recordedPath = path;
          _recordedDuration = duration;
          _isRecording = false;
          _amplitude = 0;
        });
        widget.onRecordingComplete(path, duration);
      }
    }
  }

  Future<Duration> _getAudioDuration(String path) async {
    try {
      final player = AudioPlayer();
      await player.setSource(DeviceFileSource(path));
      final result = await player.getDuration();
      await player.dispose();
      return result ?? Duration(seconds: _elapsedSeconds);
    } catch (_) {
      return Duration(seconds: _elapsedSeconds);
    }
  }

  Future<void> _playRecording() async {
    if (_recordedPath == null) return;
    await _player.play(DeviceFileSource(_recordedPath!));
    setState(() => _isPlaying = true);
  }

  Future<void> _stopPlayback() async {
    await _player.stop();
    setState(() {
      _isPlaying = false;
      _playPosition = Duration.zero;
    });
  }

  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;
    final danger = context.dangerColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        if (_isRecording)
          _buildRecordingState(primary, danger, textPrimary, isDark)
        else if (_recordedPath != null)
          _buildPlaybackState(primary, textPrimary, textSecondary, isDark)
        else
          _buildIdleState(primary, textSecondary),
      ],
    );
  }

  Widget _buildIdleState(Color primary, Color textSecondary) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.05);
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _startRecording,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mic_rounded, size: 48, color: primary),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to start recording',
          style: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        ),
      ],
    );
  }

  Widget _buildRecordingState(
      Color primary, Color danger, Color textPrimary, bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: danger.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stop_rounded,
                size: 48, color: danger),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to stop',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: danger,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildWaveform(primary, isDark),
        const SizedBox(height: 12),
        Text(
          _formatDuration(_elapsedSeconds),
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildWaveform(Color primary, bool isDark) {
    return AnimatedBuilder(
      animation: _colorShiftController,
      builder: (context, child) {
        final t = _colorShiftController.value;
        final color = Color.lerp(
          const Color(0xFF4FC3F7),
          const Color(0xFF7C4DFF),
          t,
        )!;
        return SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (i) {
              final baseHeight = 8.0 + (_amplitude * 24.0);
              final offset = (i - 2).abs() / 2.0;
              final barHeight = baseHeight * (1.0 - offset * 0.4);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 6,
                  height: barHeight.clamp(4.0, 40.0),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildPlaybackState(
      Color primary, Color textPrimary, Color textSecondary, bool isDark) {
    final progress = _recordedDuration.inMilliseconds > 0
        ? _playPosition.inMilliseconds / _recordedDuration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _isPlaying ? _stopPlayback : _playRecording,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voice Note',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDuration(
                              _isPlaying
                                  ? _playPosition.inSeconds
                                  : _recordedDuration.inSeconds),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    MediaService.instance
                        .getFileSizeFormatted(_recordedPath!),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: textSecondary.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _recordedPath = null;
              _recordedDuration = Duration.zero;
              _playPosition = Duration.zero;
            });
          },
          child: Text(
            'Record again',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
