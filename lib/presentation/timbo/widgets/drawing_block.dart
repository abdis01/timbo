import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/block.dart';
import '../../../theme/colors.dart';
import '../../../providers/blocks_provider.dart';

class DrawingBlock extends ConsumerStatefulWidget {
  final int blockId;
  final List<DrawingStroke> initialStrokes;
  final bool readOnly;

  const DrawingBlock({
    super.key,
    required this.blockId,
    required this.initialStrokes,
    this.readOnly = false,
  });

  @override
  ConsumerState<DrawingBlock> createState() => _DrawingBlockState();
}

class _DrawingBlockState extends ConsumerState<DrawingBlock> {
  List<DrawingStroke> _strokes = [];
  DrawingStroke? _currentStroke;
  Color _currentColor = TimboColors.ink;
  double _currentWidth = 3.0;

  static const _colors = [
    Color(0xFF1A1A1A),
    Color(0xFFD32F2F),
    Color(0xFF1976D2),
    Color(0xFF388E3C),
    Color(0xFFF57C00),
    Color(0xFF7B1FA2),
    Color(0xFFC2185B),
    Color(0xFF0097A7),
  ];

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.initialStrokes);
  }

  void _save() {
    ref.read(blockRepositoryProvider).updateDrawingData(widget.blockId, _strokes);
  }

  void _onPanStart(DragStartDetails d) {
    _currentStroke = DrawingStroke(
      points: [d.localPosition],
      color: _currentColor.toARGB32(),
      width: _currentWidth,
    );
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _currentStroke!.points.add(d.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_currentStroke != null) {
      setState(() {
        _strokes.add(_currentStroke!);
        _currentStroke = null;
      });
      _save();
    }
  }

  void _clear() {
    setState(() => _strokes.clear());
    _save();
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() => _strokes.removeLast());
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: TimboColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TimboColors.ink.withValues(alpha: 0.08)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.readOnly
                  ? CustomPaint(
                      painter: _DrawingPainter(strokes: _strokes),
                      size: const Size(double.infinity, 200),
                    )
                  : GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(
                        painter: _DrawingPainter(
                          strokes: _strokes,
                          currentStroke: _currentStroke,
                        ),
                        size: const Size(double.infinity, 200),
                      ),
                    ),
            ),
          ),
          if (!widget.readOnly) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ..._colors.map((c) => GestureDetector(
                  onTap: () => setState(() => _currentColor = c),
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _currentColor == c ? TimboColors.ink : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                )),
                const Spacer(),
                _ToolButton(icon: Icons.undo_rounded, onTap: _undo),
                const SizedBox(width: 8),
                _ToolButton(icon: Icons.delete_outline_rounded, onTap: _clear),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ToolButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: TimboColors.ink.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: TimboColors.inkLight),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  _DrawingPainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [...strokes, if (currentStroke != null) currentStroke!]) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = Color(stroke.color)
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path();
      path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter old) => old.strokes != strokes || old.currentStroke != currentStroke;
}
