import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../../core/widgets/offline_banner.dart';
import '../../domain/block.dart';
import '../../domain/timbo.dart';
import '../../providers/timbos_provider.dart';
import '../../providers/blocks_provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import 'widgets/text_block.dart';
import 'widgets/image_block.dart';
import 'widgets/voice_block.dart';
import 'widgets/checklist_block.dart';
import 'widgets/drawing_block.dart';
import 'widgets/add_block_bar.dart';
import 'widgets/reminder_sheet.dart';

class TimboCanvasScreen extends ConsumerStatefulWidget {
  final int timboId;
  const TimboCanvasScreen({super.key, required this.timboId});

  @override
  ConsumerState<TimboCanvasScreen> createState() => _TimboCanvasScreenState();
}

class _TimboCanvasScreenState extends ConsumerState<TimboCanvasScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool _isEditing = false;
  bool _isRecording = false;
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;
  final TextEditingController _bodyController = TextEditingController();
  bool _initialTitleLoaded = false;

  @override
  void initState() {
    super.initState();
    final timbo = ref.read(timboProvider(widget.timboId)).valueOrNull;
    if (timbo != null) _loadTimbo(timbo);
  }

  void _loadTimbo(TimboModel timbo) {
    _titleController.text = timbo.title ?? '';
    _initialTitleLoaded = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _save() async {
    final title = _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim();
    await ref.read(timboRepositoryProvider).updateTimboTitle(widget.timboId, title);
    if (!mounted) return;
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saved'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: TimboColors.ink,
      ),
    );
  }

  Future<void> _onAddBlock(AddBlockType type) async {
    switch (type) {
      case AddBlockType.text:
        await ref.read(blockRepositoryProvider).addTextBlock(widget.timboId, '');
      case AddBlockType.gallery:
        try {
          final image = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (image != null) {
            await ref.read(blockRepositoryProvider).addImageBlock(widget.timboId, image.path);
          }
        } catch (_) {}
      case AddBlockType.camera:
        try {
          final image = await ImagePicker().pickImage(source: ImageSource.camera);
          if (image != null) {
            await ref.read(blockRepositoryProvider).addImageBlock(widget.timboId, image.path);
          }
        } catch (_) {}
      case AddBlockType.voice:
        if (_isRecording) {
          await _stopRecording();
        } else {
          await _startRecording();
        }
      case AddBlockType.checklist:
        final item = ChecklistItem(id: const Uuid().v4(), text: '', isChecked: false);
        await ref.read(blockRepositoryProvider).addChecklistBlock(widget.timboId, [item]);
      case AddBlockType.drawing:
        await ref.read(blockRepositoryProvider).addDrawingBlock(widget.timboId, []);
    }
  }

  Future<void> _startRecording() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Microphone permission is required to record'), behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    try {
      await _recorder.start(const RecordConfig(), path: path);
      setState(() { _isRecording = true; _recordingPath = path; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _recordingPath == null) return;
    try {
      final path = await _recorder.stop();
      if (path != null) {
        await ref.read(blockRepositoryProvider).addVoiceBlock(widget.timboId, path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save recording: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
    setState(() { _isRecording = false; _recordingPath = null; });
  }

  Future<void> _deleteTimbo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(timboRepositoryProvider).deleteTimbo(widget.timboId);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timboAsync = ref.watch(timboProvider(widget.timboId));
    final blocksAsync = ref.watch(blocksProvider(widget.timboId));
    final timbo = timboAsync.valueOrNull;
    final blocks = blocksAsync.valueOrNull ?? [];

    if (timbo != null && !_initialTitleLoaded) {
      _loadTimbo(timbo);
    }

    return Scaffold(
      backgroundColor: TimboColors.surface,
      appBar: AppBar(
        backgroundColor: TimboColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TimboColors.ink),
          onPressed: () => context.pop(),
        ),
        title: _isEditing
            ? TextField(
                controller: _titleController,
                autofocus: true,
                style: TimboTypography.heading3,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'Untitled',
                  hintStyle: TimboTypography.heading3.copyWith(color: TimboColors.inkFaint),
                ),
              )
            : GestureDetector(
                onTap: () {},
                child: Text(
                  timbo?.title?.isNotEmpty == true ? timbo!.title! : 'Untitled',
                  style: TimboTypography.heading3,
                ),
              ),
        actions: [
          if (_isRecording)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Recording', style: TimboTypography.caption.copyWith(color: Colors.red)),
                ],
              ),
            ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: timbo?.reminderSet == true ? const Color(0xFFFFD700) : TimboColors.inkLight, size: 20),
            onPressed: () {
              showModalBottomSheet(
                context: context, isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ReminderSheet(
                  timboId: widget.timboId,
                  reminderSet: timbo?.reminderSet ?? false,
                  reminderTimestamp: timbo?.reminderTimestamp,
                  reminderLabel: timbo?.reminderLabel,
                ),
              );
            },
            tooltip: 'Set reminder',
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, color: TimboColors.ink, size: 22),
              onPressed: _save,
              tooltip: 'Save',
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: TimboColors.ink, size: 20),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: TimboColors.ink),
            onSelected: (val) {
              if (val == 'delete') _deleteTimbo();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete note')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          if (timbo == null)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _isEditing ? _buildEditor(blocks) : _buildPreview(blocks),
            ),
          if (_isEditing) AddBlockBar(onAdd: _onAddBlock),
        ],
      ),
    );
  }

  Widget _buildPreview(List<BlockModel> blocks) {
    if (blocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No content yet', style: TimboTypography.bodySmall.copyWith(color: TimboColors.inkFaint)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Add content'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: blocks.length,
      itemBuilder: (_, i) {
        final block = blocks[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildBlockWidget(block, readOnly: true),
        );
      },
    );
  }

  Widget _buildEditor(List<BlockModel> blocks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: blocks.length,
      itemBuilder: (_, i) {
        final block = blocks[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildBlockWidget(block, readOnly: false),
        );
      },
    );
  }

  Widget _buildBlockWidget(BlockModel block, {required bool readOnly}) {
    switch (block.type) {
      case BlockType.text:
        return TextBlock(
          blockId: block.id,
          initialContent: block.textContent ?? '',
          fontFamily: block.fontFamily,
          readOnly: readOnly,
        );
      case BlockType.image:
        return ImageBlock(blockId: block.id, filePath: block.filePath ?? '', readOnly: readOnly);
      case BlockType.voice:
        return VoiceBlock(blockId: block.id, filePath: block.filePath ?? '');
      case BlockType.checklist:
        return ChecklistBlock(blockId: block.id, initialItems: block.checklistItems ?? [], readOnly: readOnly);
      case BlockType.drawing:
        return DrawingBlock(blockId: block.id, initialStrokes: block.drawingStrokes ?? [], readOnly: readOnly);
    }
  }
}
