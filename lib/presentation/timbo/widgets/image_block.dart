import 'dart:io';
import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class ImageBlock extends StatefulWidget {
  final int blockId;
  final String filePath;
  final String? caption;
  final VoidCallback? onDelete;
  final void Function(double width, double height)? onResize;

  const ImageBlock({
    super.key,
    required this.blockId,
    required this.filePath,
    this.caption,
    this.onDelete,
    this.onResize,
  });

  @override
  State<ImageBlock> createState() => _ImageBlockState();
}

class _ImageBlockState extends State<ImageBlock> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  double _width = 200;
  double _height = 160;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(File(widget.filePath)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete image?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) widget.onDelete?.call();
  }

  void _onResizeUpdate(double deltaW, double deltaH) {
    setState(() {
      _width = (_width + deltaW).clamp(80, 600);
      _height = (_height + deltaH).clamp(80, 600);
    });
    widget.onResize?.call(_width, _height);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _showFullScreen(context);
      },
      onTapCancel: () => _controller.reverse(),
      onLongPress: () => _showDeleteDialog(context),
      onScaleUpdate: widget.onResize != null
          ? (details) {
              if (details.pointerCount == 2) {
                final scale = details.scale;
                _onResizeUpdate((scale - 1.0) * 10, (scale - 1.0) * 8);
              }
            }
          : null,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SizedBox(
            width: _width,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    File(widget.filePath),
                    width: _width,
                    height: _height,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: _height,
                      color: TimboColors.surfaceAlt,
                      child: const Center(child: Icon(Icons.broken_image, color: TimboColors.inkFaint)),
                    ),
                  ),
                ),
                if (widget.onResize != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onPanUpdate: (d) => _onResizeUpdate(d.delta.dx, d.delta.dy),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: TimboColors.ink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward, color: Colors.white, size: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
