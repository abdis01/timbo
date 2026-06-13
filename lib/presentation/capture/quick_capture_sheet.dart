import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';
import '../../providers/timbos_provider.dart';
import '../../providers/blocks_provider.dart';
import '../../providers/folders_provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/reminder_service.dart';

class QuickCaptureSheet extends ConsumerStatefulWidget {
  final String? initialText;

  const QuickCaptureSheet({super.key, this.initialText});

  @override
  ConsumerState<QuickCaptureSheet> createState() => _QuickCaptureSheetState();
}

class _QuickCaptureSheetState extends ConsumerState<QuickCaptureSheet> {
  final TextEditingController _textController = TextEditingController();
  bool _useAi = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      if (_useAi) {
        await _processWithAi(text);
      } else {
        await _saveAsNote(text);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveAsNote(String text) async {
    final folder = await ref.read(folderRepositoryProvider).getOrCreateTodayFolder();
    final timboId = await ref.read(timboRepositoryProvider).createTimbo(folderId: folder.id, title: text.length > 50 ? '${text.substring(0, 50)}...' : text);
    await ref.read(blockRepositoryProvider).addTextBlock(timboId, text);
  }

  Future<void> _processWithAi(String text) async {
    try {
      final resp = await http.post(
        Uri.parse('${AppConstants.aiProxyUrl}/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': text,
          'history': [],
          'systemPrompt': 'Parse user input into structured data. Reply with JSON only.',
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final reply = data['reply'] as String? ?? '';
        final parsed = jsonDecode(reply.replaceAll('```json', '').replaceAll('```', '').trim()) as Map<String, dynamic>;
        final type = parsed['type'] as String? ?? 'note';
        final content = parsed['content'] as String? ?? text;

        final folder = await ref.read(folderRepositoryProvider).getOrCreateTodayFolder();
        final timboId = await ref.read(timboRepositoryProvider).createTimbo(
          folderId: folder.id,
          title: content.length > 50 ? '${content.substring(0, 50)}...' : content,
        );
        await ref.read(blockRepositoryProvider).addTextBlock(timboId, content);

        if (type == 'reminder') {
          final reminderTitle = parsed['reminderTitle'] as String? ?? 'Timbo Reminder';
          final reminderTimeStr = parsed['reminderTime'] as String?;
          if (reminderTimeStr != null) {
            final scheduledAt = DateTime.parse(reminderTimeStr);
            await ref.read(timboRepositoryProvider).setReminder(
              timboId, scheduledAt.millisecondsSinceEpoch, reminderTitle,
            );
            await ReminderService.instance.scheduleReminder(
              id: timboId,
              title: reminderTitle,
              body: content,
              scheduledAt: scheduledAt,
            );
          }
        }
      } else {
        await _saveAsNote(text);
      }
    } catch (_) {
      await _saveAsNote(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: TimboColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: TimboColors.borderLight, borderRadius: BorderRadius.circular(2)), alignment: Alignment.center),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('Quick Capture', style: TimboTypography.heading2)),
                if (isOnline)
                  GestureDetector(
                    onTap: () => setState(() => _useAi = !_useAi),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _useAi ? TimboColors.ink : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: TimboColors.ink.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: _useAi ? Colors.white : TimboColors.inkLight),
                          const SizedBox(width: 4),
                          Text('AI', style: TextStyle(fontSize: 12, color: _useAi ? Colors.white : TimboColors.inkLight)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              autofocus: true,
              maxLines: 4,
              minLines: 2,
              decoration: InputDecoration(
                hintText: _useAi ? 'e.g. "remind me to buy milk at 5pm"' : 'Write a quick note...',
                hintStyle: TimboTypography.body.copyWith(color: TimboColors.inkFaint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: TimboColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: TimboColors.ink),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              style: TimboTypography.body,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: TimboColors.ink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                disabledBackgroundColor: TimboColors.ink.withValues(alpha: 0.4),
              ),
              child: _isProcessing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_useAi ? 'Save with AI' : 'Save Note', style: TimboTypography.button),
            ),
          ],
        ),
      ),
    );
  }
}
