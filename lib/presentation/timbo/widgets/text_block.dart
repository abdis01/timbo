import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../providers/blocks_provider.dart';

class TextBlock extends ConsumerStatefulWidget {
  final int blockId;
  final String initialContent;
  final String? fontFamily;
  final bool readOnly;

  const TextBlock({
    super.key,
    required this.blockId,
    required this.initialContent,
    this.fontFamily,
    this.readOnly = false,
  });

  @override
  ConsumerState<TextBlock> createState() => _TextBlockState();
}

class _TextBlockState extends ConsumerState<TextBlock> {
  late TextEditingController _controller;
  Timer? _debounce;
  String? _fontFamily;

  static const _fonts = [
    'Inter',
    'Caveat',
    'Merriweather',
    'Fira Code',
    'Playfair Display',
    'Source Sans 3',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _fontFamily = widget.fontFamily;
  }

  @override
  void didUpdateWidget(TextBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialContent != oldWidget.initialContent &&
        widget.initialContent != _controller.text) {
      _controller.text = widget.initialContent;
    }
    if (widget.fontFamily != oldWidget.fontFamily) {
      _fontFamily = widget.fontFamily;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(blockRepositoryProvider).updateTextContent(widget.blockId, val.trim());
    });
  }

  TextStyle _resolveStyle() {
    final base = TimboTypography.body.copyWith(height: 1.6);
    switch (_fontFamily) {
      case 'Caveat': return GoogleFonts.caveat(textStyle: base.copyWith(fontSize: 18));
      case 'Merriweather': return GoogleFonts.merriweather(textStyle: base);
      case 'Fira Code': return GoogleFonts.firaCode(textStyle: base);
      case 'Playfair Display': return GoogleFonts.playfairDisplay(textStyle: base);
      case 'Source Sans 3': return GoogleFonts.sourceSans3(textStyle: base);
      default: return GoogleFonts.inter(textStyle: base);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _controller.text.trim();
    if (widget.readOnly) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: content.isEmpty
            ? const SizedBox.shrink()
            : Text(content, style: _resolveStyle()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: GestureDetector(
              onTap: _showFontPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TimboColors.ink.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.text_fields, size: 12, color: TimboColors.inkFaint),
                    const SizedBox(width: 4),
                    Text(
                      _fontFamily ?? 'Inter',
                      style: TextStyle(fontSize: 10, color: TimboColors.inkFaint),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.expand_more, size: 12, color: TimboColors.inkFaint),
                  ],
                ),
              ),
            ),
          ),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Write something...',
            hintStyle: TimboTypography.body.copyWith(color: TimboColors.inkFaint),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            isCollapsed: true,
          ),
          style: _resolveStyle(),
          maxLines: null,
          minLines: 1,
          onChanged: _onChanged,
        ),
      ],
    );
  }

  void _showFontPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TimboColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Font Style', style: TimboTypography.heading3),
            const SizedBox(height: 16),
            ..._fonts.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                selected: _fontFamily == f || (_fontFamily == null && f == 'Inter'),
                selectedTileColor: TimboColors.ink.withValues(alpha: 0.06),
                title: Text(f, style: TextStyle(
                  fontFamily: f == 'Inter' ? null : f,
                  fontSize: 16,
                  color: TimboColors.ink,
                )),
                trailing: (_fontFamily == f || (_fontFamily == null && f == 'Inter'))
                    ? const Icon(Icons.check, size: 18, color: TimboColors.ink)
                    : null,
                onTap: () {
                  final selected = f == 'Inter' ? null : f;
                  setState(() => _fontFamily = selected);
                  ref.read(blockRepositoryProvider).updateFontFamily(widget.blockId, f);
                  Navigator.pop(ctx);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}
