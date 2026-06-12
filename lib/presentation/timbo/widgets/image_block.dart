import 'dart:io';
import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

class ImageBlock extends StatefulWidget {
  final int blockId;
  final String filePath;
  final String? caption;
  final VoidCallback? onDelete;
  final bool readOnly;

  const ImageBlock({
    super.key,
    required this.blockId,
    required this.filePath,
    this.caption,
    this.onDelete,
    this.readOnly = false,
  });

  @override
  State<ImageBlock> createState() => _ImageBlockState();
}

class _ImageBlockState extends State<ImageBlock> {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreen(context),
      onLongPress: !widget.readOnly ? () => _showDeleteDialog(context) : null,
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
