import 'dart:io';
import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class ImageBlock extends StatefulWidget {
  final int blockId;
  final String filePath;
  final String? caption;
  final VoidCallback? onDelete;
  final void Function(double width, double height)? onResize;
  final bool readOnly;

  const ImageBlock({
    super.key,
    required this.blockId,
    required this.filePath,
    this.caption,
    this.onDelete,
    this.onResize,
    this.readOnly = false,
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
    final isInteractive = !widget.readOnly;
    return GestureDetector(
      onTapDown: isInteractive ? (_) => _controller.forward() : null,
      onTapUp: isInteractive ? (_) {
        _controller.reverse();
        _showFullScreen(context);
      } : null,
      onTapCancel: isInteractive ? () => _controller.reverse() : null,
      onLongPress: isInteractive ? () => _showDeleteDialog(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            File(widget.filePath),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: TimboColors.surfaceAlt,
              child: const Center(child: Icon(Icons.broken_image, color: TimboColors.inkFaint)),
            ),
          ),
        ),
      ),
    );
  }
}
