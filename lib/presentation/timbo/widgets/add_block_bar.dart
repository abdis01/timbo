import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

enum AddBlockType { text, gallery, camera, voice, checklist, drawing }

class AddBlockBar extends StatelessWidget {
  final void Function(AddBlockType type) onAdd;

  const AddBlockBar({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TimboColors.appBackground,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Action(icon: Icons.text_fields, label: 'Text', onTap: () => onAdd(AddBlockType.text)),
            _Action(icon: Icons.photo_library_outlined, label: 'Gallery', onTap: () => onAdd(AddBlockType.gallery)),
            _Action(icon: Icons.camera_alt_outlined, label: 'Camera', onTap: () => onAdd(AddBlockType.camera)),
            _Action(icon: Icons.mic_outlined, label: 'Voice', onTap: () => onAdd(AddBlockType.voice)),
            _Action(icon: Icons.checklist_outlined, label: 'Checklist', onTap: () => onAdd(AddBlockType.checklist)),
            _Action(icon: Icons.brush_outlined, label: 'Draw', onTap: () => onAdd(AddBlockType.drawing)),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Action({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
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
              child: Icon(icon, size: 20, color: TimboColors.ink),
            ),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 9, color: TimboColors.inkLight)),
          ],
        ),
      ),
    );
  }
}
