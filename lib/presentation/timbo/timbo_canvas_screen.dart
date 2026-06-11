import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../../core/painters/notebook_line_painter.dart';
import '../../core/widgets/offline_banner.dart';
import '../../domain/block.dart';
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

class _UndoAction {
  final int blockId;
  final double? oldX, oldY;
  final double? oldW, oldH;
  final BlockModel? deletedBlock;

  _UndoAction.move(int id, double? x, double? y)
      : blockId = id, oldX = x, oldY = y, deletedBlock = null,
        oldW = null, oldH = null;

  _UndoAction.resize(int id, double? w, double? h)
      : blockId = id, oldW = w, oldH = h, deletedBlock = null,
        oldX = null, oldY = null;

  _UndoAction.delete(this.deletedBlock) : blockId = deletedBlock!.id,
        oldX = null, oldY = null, oldW = null, oldH = null;
}

class TimboCanvasScreen extends ConsumerStatefulWidget {
  final int timboId;
  const TimboCanvasScreen({super.key, required this.timboId});

  @override
  ConsumerState<TimboCanvasScreen> createState() => _TimboCanvasScreenState();
}

class _TimboCanvasScreenState extends ConsumerState<TimboCanvasScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TransformationController _transformController = TransformationController();
  bool _isEditingTitle = false;
  bool _isRecording = false;
  bool _showLines = true;
  bool _hasUnsaved = false;
  int? _selectedBlockId;
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;
  Timer? _titleDebounce;
  final List<_UndoAction> _undoStack = [];
  static const _maxUndo = 20;
  final Set<int> _deletingBlockIds = {};

  @override
  void initState() {
    super.initState();
    final timbo = ref.read(timboProvider(widget.timboId)).valueOrNull;
    if (timbo != null) _titleController.text = timbo.title ?? '';
    _showLines = ref.read(preferencesServiceProvider).linesEnabled;
  }

  @override
  void dispose() {
    _titleDebounce?.cancel();
    _titleController.dispose();
    _transformController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _pushUndo(_UndoAction action) {
    _undoStack.add(action);
    if (_undoStack.length > _maxUndo) _undoStack.removeAt(0);
  }

  Future<void> _undo() async {
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();
    final repo = ref.read(blockRepositoryProvider);

    if (action.oldX != null || action.oldY != null) {
      await repo.updateBlockPosition(action.blockId, action.oldX ?? 0, action.oldY ?? 0);
    } else if (action.oldW != null || action.oldH != null) {
      await repo.updateBlockSize(action.blockId, action.oldW ?? 200, action.oldH ?? 160);
    } else if (action.deletedBlock != null) {
      await repo.restoreBlock(action.deletedBlock!);
    }
  }

  void _markUnsaved() {
    if (!_hasUnsaved) setState(() => _hasUnsaved = true);
  }

  void _markSaved() {
    if (_hasUnsaved) setState(() => _hasUnsaved = false);
  }

  void _onTitleChanged(String val) {
    _markUnsaved();
    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(timboRepositoryProvider).updateTimboTitle(
        widget.timboId, val.trim().isEmpty ? 'Untitled' : val.trim());
    });
  }

  Future<void> _onAddBlock(AddBlockType type) async {
    _markUnsaved();
    switch (type) {
      case AddBlockType.text:
        final id = await ref.read(blockRepositoryProvider).addTextBlock(widget.timboId, '');
        _positionNewBlock(id);
      case AddBlockType.gallery:
        try {
          final image = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (image != null) {
            final id = await ref.read(blockRepositoryProvider).addImageBlock(widget.timboId, image.path);
            _positionNewBlock(id);
          }
        } catch (_) {}
      case AddBlockType.camera:
        try {
          final image = await ImagePicker().pickImage(source: ImageSource.camera);
          if (image != null) {
            final id = await ref.read(blockRepositoryProvider).addImageBlock(widget.timboId, image.path);
            _positionNewBlock(id);
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
        final id = await ref.read(blockRepositoryProvider).addChecklistBlock(widget.timboId, [item]);
        _positionNewBlock(id);
      case AddBlockType.drawing:
        final id = await ref.read(blockRepositoryProvider).addDrawingBlock(widget.timboId, []);
        _positionNewBlock(id);
    }
  }

  void _positionNewBlock(int blockId) {
    final sz = MediaQuery.of(context).size;
    final offset = _transformController.toScene(Offset(sz.width / 2 - 130, sz.height / 2 - 60));
    ref.read(blockRepositoryProvider).updateBlockPosition(blockId, offset.dx, offset.dy);
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    setState(() { _isRecording = true; _recordingPath = path; });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _recordingPath == null) return;
    try {
      await _recorder.stop();
      final id = await ref.read(blockRepositoryProvider).addVoiceBlock(widget.timboId, _recordingPath!);
      _positionNewBlock(id);
    } catch (_) {}
    setState(() { _isRecording = false; _recordingPath = null; });
  }

  void _saveTitle() {
    final title = _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim();
    ref.read(timboRepositoryProvider).updateTimboTitle(widget.timboId, title);
    setState(() => _isEditingTitle = false);
  }

  Future<void> _deleteTimbo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this Timbo?'),
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

  Future<void> _deleteBlock(BlockModel block) async {
    if (_deletingBlockIds.contains(block.id)) return;
    _deletingBlockIds.add(block.id);
    _pushUndo(_UndoAction.delete(block));
    _markUnsaved();
    try {
      await ref.read(blockRepositoryProvider).deleteBlock(block.id);
    } catch (_) {}
    setState(() { _selectedBlockId = null; _deletingBlockIds.remove(block.id); });
  }

  @override
  Widget build(BuildContext context) {
    final timboAsync = ref.watch(timboProvider(widget.timboId));
    final blocksAsync = ref.watch(blocksProvider(widget.timboId));
    final timbo = timboAsync.valueOrNull;
    final blocks = blocksAsync.valueOrNull ?? [];

    if (timbo != null && _titleController.text.isEmpty && timbo.title != null) {
      _titleController.text = timbo.title ?? '';
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
        title: _isEditingTitle
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
                onChanged: _onTitleChanged,
                onSubmitted: (_) => _saveTitle(),
                onTapOutside: (_) => _saveTitle(),
              )
            : GestureDetector(
                onTap: () => setState(() => _isEditingTitle = true),
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
                  _RecordingDot(),
                  const SizedBox(width: 4),
                  Text('Recording', style: TimboTypography.caption.copyWith(color: Colors.red)),
                ],
              ),
            ),
          IconButton(
            icon: Icon(
              _showLines ? Icons.line_style : Icons.dashboard_rounded,
              color: TimboColors.inkLight, size: 20,
            ),
            onPressed: () => setState(() => _showLines = !_showLines),
            tooltip: 'Toggle notebook lines',
          ),
          if (_undoStack.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo, color: TimboColors.ink, size: 20),
              onPressed: _undo,
              tooltip: 'Undo',
            ),
          _BellIcon(hasReminder: timbo?.reminderSet ?? false, onTap: () {
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
          }),
          if (_hasUnsaved)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: TimboColors.ink, size: 20),
              onPressed: () {
                _saveTitle();
                _markSaved();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Saved'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: TimboColors.ink,
                  ),
                );
              },
              tooltip: 'Save',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: TimboColors.ink),
            onSelected: (val) {
              if (val == 'delete') _deleteTimbo();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete Timbo')),
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
              child: _showLines
                  ? CustomPaint(painter: NotebookLinePainter(), child: _buildCanvas(blocks))
                  : _buildCanvas(blocks),
            ),
          AddBlockBar(onAdd: _onAddBlock),
        ],
      ),
    );
  }

  Widget _buildCanvas(List<BlockModel> blocks) {
    final maxDim = _calculateCanvasSize(blocks);
    return GestureDetector(
      onTap: () => setState(() => _selectedBlockId = null),
      child: InteractiveViewer(
        transformationController: _transformController,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.2,
        maxScale: 3.0,
        child: SizedBox(
          width: max(maxDim.dx, MediaQuery.of(context).size.width),
          height: max(maxDim.dy, MediaQuery.of(context).size.height),
          child: Stack(
            children: blocks.map((block) {
              final idx = blocks.indexOf(block);
              final x = block.positionX ?? (idx * 30.0);
              final y = block.positionY ?? (idx * 70.0);
              final w = block.blockWidth ?? _defaultBlockWidth(block);
              final h = block.blockHeight ?? _defaultBlockHeight(block);
              final isSelected = _selectedBlockId == block.id;
              return Positioned(
                left: x, top: y, width: w, height: h,
                child: _CanvasBlock(
                  key: ValueKey(block.id),
                  block: block,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedBlockId == block.id
                      ? _selectedBlockId = null
                      : _selectedBlockId = block.id),
                  onMoveStart: () => _pushUndo(_UndoAction.move(block.id, block.positionX, block.positionY)),
                  onMove: (dx, dy) {
                    final repo = ref.read(blockRepositoryProvider);
                    repo.updateBlockPosition(block.id,
                        (block.positionX ?? idx * 30.0) + dx,
                        (block.positionY ?? idx * 70.0) + dy);
                  },
                  onDelete: () => _deleteBlock(block),
                  onResize: (dw, dh) {
                    final newW = (block.blockWidth ?? _defaultBlockWidth(block)) + dw;
                    final newH = (block.blockHeight ?? _defaultBlockHeight(block)) + dh;
                    _pushUndo(_UndoAction.resize(block.id, block.blockWidth, block.blockHeight));
                    ref.read(blockRepositoryProvider).updateBlockSize(block.id, newW.clamp(80, 600), newH.clamp(60, 600));
                  },
                  child: _buildBlockWidget(block),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Offset _calculateCanvasSize(List<BlockModel> blocks) {
    double maxX = 0, maxY = 0;
    for (int i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      final x = (b.positionX ?? (i * 30.0)) + (b.blockWidth ?? _defaultBlockWidth(b));
      final y = (b.positionY ?? (i * 70.0)) + (b.blockHeight ?? _defaultBlockHeight(b));
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
    return Offset(maxX + 100, maxY + 100);
  }

  double _defaultBlockWidth(BlockModel block) {
    switch (block.type) {
      case BlockType.image: return 200;
      case BlockType.voice: return 220;
      case BlockType.checklist: return 240;
      case BlockType.drawing: return 260;
      case BlockType.text: return 260;
    }
  }

  double _defaultBlockHeight(BlockModel block) {
    switch (block.type) {
      case BlockType.image: return 160;
      case BlockType.voice: return 60;
      case BlockType.checklist: return 100;
      case BlockType.drawing: return 200;
      case BlockType.text: return 80;
    }
  }

  Widget _buildBlockWidget(BlockModel block) {
    switch (block.type) {
      case BlockType.text:
        return TextBlock(
          blockId: block.id, initialContent: block.textContent ?? '',
          fontFamily: block.fontFamily,
        );
      case BlockType.image:
        return ImageBlock(
          blockId: block.id, filePath: block.filePath ?? '',
          onDelete: () => _deleteBlock(block),
          onResize: (w, h) {
            _pushUndo(_UndoAction.resize(block.id, block.blockWidth, block.blockHeight));
            ref.read(blockRepositoryProvider).updateBlockSize(block.id, w, h);
          },
        );
      case BlockType.voice:
        return Padding(
          padding: const EdgeInsets.all(8),
          child: VoiceBlock(blockId: block.id, filePath: block.filePath ?? ''),
        );
      case BlockType.checklist:
        return ChecklistBlock(
          blockId: block.id, initialItems: block.checklistItems ?? [],
          onDelete: () => _deleteBlock(block),
        );
      case BlockType.drawing:
        return DrawingBlock(blockId: block.id, initialStrokes: block.drawingStrokes ?? []);
    }
  }
}

class _CanvasBlock extends StatefulWidget {
  final BlockModel block;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onMoveStart;
  final void Function(double dx, double dy) onMove;
  final VoidCallback onDelete;
  final void Function(double dw, double dh) onResize;
  final Widget child;

  const _CanvasBlock({
    super.key,
    required this.block, required this.isSelected, required this.onTap,
    required this.onMoveStart, required this.onMove, required this.onDelete,
    required this.onResize, required this.child,
  });

  @override
  State<_CanvasBlock> createState() => _CanvasBlockState();
}

class _CanvasBlockState extends State<_CanvasBlock> {
  Offset? _dragStart;
  Offset? _blockStart;
  bool _hasPushedUndo = false;

  void _onPanStart(DragStartDetails d) {
    _dragStart = d.localPosition;
    _blockStart = Offset(widget.block.positionX ?? 0, widget.block.positionY ?? 0);
    _hasPushedUndo = false;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_dragStart == null || _blockStart == null) return;
    if (!_hasPushedUndo) {
      _hasPushedUndo = true;
      widget.onMoveStart();
    }
    final delta = d.localPosition - _dragStart!;
    widget.onMove(delta.dx, delta.dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onLongPress: widget.onDelete,
      child: Container(
        decoration: widget.isSelected
            ? BoxDecoration(
                border: Border.all(color: TimboColors.ink.withValues(alpha: 0.4), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Stack(
          children: [
            widget.child,
            if (widget.isSelected) ...[
              Positioned(
                top: 0, left: 0,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: TimboColors.ink.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                  ),
                ),
              ),
              if (widget.block.type == BlockType.image)
                Positioned(
                  right: 0, bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (d) => widget.onResize(d.delta.dx, d.delta.dy),
                    child: Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(color: TimboColors.ink, shape: BoxShape.circle),
                      child: const Icon(Icons.unfold_more, color: Colors.white, size: 12),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecordingDot extends StatefulWidget {
  @override State<_RecordingDot> createState() => _RecordingDotState();
}
class _RecordingDotState extends State<_RecordingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true); }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
    );
  }
}

class _BellIcon extends StatelessWidget {
  final bool hasReminder; final VoidCallback onTap;
  const _BellIcon({required this.hasReminder, required this.onTap});
  @override Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, color: TimboColors.ink),
          if (hasReminder)
            Positioned(
              right: -3, top: -3,
              child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle)),
            ),
        ],
      ),
      onPressed: onTap,
    );
  }
}
