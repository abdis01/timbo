import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../core/widgets/sketch_container.dart';

class VoiceBlock extends StatefulWidget {
  final int blockId;
  final String filePath;

  const VoiceBlock({
    super.key,
    required this.blockId,
    required this.filePath,
  });

  @override
  State<VoiceBlock> createState() => _VoiceBlockState();
}

class _VoiceBlockState extends State<VoiceBlock> with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late final AnimationController _waveController;
  final _random = Random(42);

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setFilePath(widget.filePath);
      _duration = _player.duration ?? Duration.zero;
      _player.positionStream.listen((p) => setState(() => _position = p));
      _player.playerStateStream.listen((state) {
        setState(() => _isPlaying = state.playing);
        if (state.playing) _waveController.repeat(reverse: true);
        else _waveController.stop();
        if (state.processingState == ProcessingState.completed) {
          _player.seek(Duration.zero);
          _player.pause();
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _player.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) _player.pause();
    else _player.play();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SketchContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _waveController,
              builder: (_, __) => Row(
                children: List.generate(5, (i) {
                  _random.nextDouble();
                  final h = _isPlaying ? 4 + _waveController.value * 12 : 6.0;
                  return Container(
                    width: 3,
                    height: h,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: TimboColors.ink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatDuration(_isPlaying ? _position : _duration),
              style: TimboTypography.heading3,
            ),
            const Spacer(),
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: TimboColors.ink,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
