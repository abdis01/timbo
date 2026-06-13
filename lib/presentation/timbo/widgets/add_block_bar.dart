import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

enum AddBlockType { text, gallery, camera, voice, checklist }

class AddBlockBar extends StatelessWidget {
  final void Function(AddBlockType type) onAdd;

  const AddBlockBar({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: TimboColors.appBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Action(icon: Icons.text_fields, label: 'Text', onTap: () => onAdd(AddBlockType.text)),
            _Action(icon: Icons.photo_library_outlined, label: 'Gallery', onTap: () => onAdd(AddBlockType.gallery)),
            _Action(icon: Icons.camera_alt_outlined, label: 'Camera', onTap: () => onAdd(AddBlockType.camera)),
            _Action(icon: Icons.mic_outlined, label: 'Voice', onTap: () => onAdd(AddBlockType.voice)),
            _Action(icon: Icons.checklist_outlined, label: 'List', onTap: () => onAdd(AddBlockType.checklist)),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Action({required this.icon, required this.label, required this.onTap});

  @override
  State<_Action> createState() => _ActionState();
}

class _ActionState extends State<_Action> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 120), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TimboColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TimboColors.ink.withValues(alpha: 0.06)),
                ),
                child: Icon(widget.icon, size: 20, color: TimboColors.ink),
              ),
              const SizedBox(height: 3),
              Text(widget.label, style: TimboTypography.caption.copyWith(fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }
}
