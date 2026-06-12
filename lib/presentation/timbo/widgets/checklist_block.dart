import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/block.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../providers/blocks_provider.dart';

class CheckboxPainter extends CustomPainter {
  final bool isChecked;
  final double drawProgress;

  CheckboxPainter(this.isChecked, {this.drawProgress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    if (isChecked && drawProgress > 0) {
      final p = drawProgress;
      if (p <= 0.5) {
        final t = p * 2;
        canvas.drawLine(
          Offset(size.width * 0.2, size.height * 0.2),
          Offset.lerp(
            Offset(size.width * 0.2, size.height * 0.2),
            Offset(size.width * 0.8, size.height * 0.8),
            t,
          )!,
          paint,
        );
      } else {
        final t = (p - 0.5) * 2;
        canvas.drawLine(
          Offset(size.width * 0.2, size.height * 0.2),
          Offset(size.width * 0.8, size.height * 0.8),
          paint,
        );
        canvas.drawLine(
          Offset(size.width * 0.8, size.height * 0.2),
          Offset.lerp(
            Offset(size.width * 0.8, size.height * 0.2),
            Offset(size.width * 0.2, size.height * 0.8),
            t,
          )!,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CheckboxPainter old) =>
      old.isChecked != isChecked || old.drawProgress != drawProgress;
}

class ChecklistBlock extends ConsumerStatefulWidget {
  final int blockId;
  final List<ChecklistItem> initialItems;
  final VoidCallback? onDelete;
  final bool readOnly;

  const ChecklistBlock({
    super.key,
    required this.blockId,
    required this.initialItems,
    this.onDelete,
    this.readOnly = false,
  });

  @override
  ConsumerState<ChecklistBlock> createState() => _ChecklistBlockState();
}

class _ChecklistBlockState extends ConsumerState<ChecklistBlock>
    with SingleTickerProviderStateMixin {
  late List<_ChecklistItemState> _items;
  AnimationController? _checkAnimController;
  int? _animatingIndex;

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems
        .map((e) => _ChecklistItemState(
              id: e.id,
              text: e.text,
              isChecked: e.isChecked,
              controller: TextEditingController(text: e.text),
            ))
        .toList();
  }

  @override
  void didUpdateWidget(ChecklistBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialItems.length != _items.length ||
        !widget.initialItems.map((e) => e.id).toSet().containsAll(_items.map((e) => e.id))) {
      _items = widget.initialItems
          .map((e) => _ChecklistItemState(
                id: e.id,
                text: e.text,
                isChecked: e.isChecked,
                controller: TextEditingController(text: e.text),
              ))
          .toList();
    }
  }

  @override
  void dispose() {
    _checkAnimController?.dispose();
    for (final item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    ref.read(blockRepositoryProvider).updateChecklistJson(
      widget.blockId,
      _items.map((e) => ChecklistItem(id: e.id, text: e.text, isChecked: e.isChecked)).toList(),
    );
  }

  void _toggle(int index) {
    final isChecked = _items[index].isChecked;
    setState(() => _items[index].isChecked = !isChecked);
    _save();
    _animatingIndex = index;
    _checkAnimController?.dispose();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _checkAnimController!.forward();
    _checkAnimController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _animatingIndex = null);
      }
    });
  }

  void _addItem() {
    final item = _ChecklistItemState(
      id: const Uuid().v4(),
      text: '',
      isChecked: false,
      controller: TextEditingController(),
    );
    setState(() => _items.add(item));
    _save();
  }

  void _updateText(int index, String val) {
    _items[index].text = val;
    _save();
  }

  void _removeItem(int index) {
    _items[index].controller.dispose();
    setState(() => _items.removeAt(index));
    _save();
    if (_items.isEmpty && widget.onDelete != null) {
      widget.onDelete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _items.length; i++) ...[
            _buildItem(i),
            if (i < _items.length - 1) const SizedBox(height: 2),
          ],
          if (!widget.readOnly) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: _addItem,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 28),
                    Icon(Icons.add, size: 16, color: TimboColors.inkFaint),
                    const SizedBox(width: 8),
                    Text('Add item', style: TimboTypography.bodySmall.copyWith(color: TimboColors.inkFaint)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    final isAnimating = _animatingIndex == index;
    final progress = isAnimating && _checkAnimController != null
        ? _checkAnimController!.value
        : (item.isChecked ? 1.0 : 0.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: GestureDetector(
            onTap: () => _toggle(index),
            child: CustomPaint(
              size: const Size(20, 20),
              painter: CheckboxPainter(item.isChecked, drawProgress: progress),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: widget.readOnly
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    item.text,
                    style: TimboTypography.body.copyWith(
                      height: 1.4,
                      decoration: item.isChecked ? TextDecoration.lineThrough : null,
                      color: item.isChecked ? TimboColors.checked : TimboColors.ink,
                    ),
                  ),
                )
              : TextField(
                  controller: item.controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  style: TimboTypography.body.copyWith(
                    height: 1.4,
                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    color: item.isChecked ? TimboColors.checked : TimboColors.ink,
                  ),
                  onChanged: (val) => _updateText(index, val),
                ),
        ),
        if (!widget.readOnly)
          GestureDetector(
            onTap: () => _removeItem(index),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: TimboColors.inkFaint),
            ),
          ),
      ],
    );
  }
}

class _ChecklistItemState {
  final String id;
  String text;
  bool isChecked;
  TextEditingController controller;

  _ChecklistItemState({
    required this.id,
    required this.text,
    required this.isChecked,
    required this.controller,
  });
}
