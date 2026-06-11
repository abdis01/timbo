import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/block.dart';
import '../../domain/timbo.dart';
import '../../providers/timbos_provider.dart';
import '../../providers/blocks_provider.dart';

class TimboCanvasState {
  final TimboModel? timbo;
  final List<BlockModel> blocks;
  final bool isRecording;
  final bool isSaving;

  TimboCanvasState({
    this.timbo,
    this.blocks = const [],
    this.isRecording = false,
    this.isSaving = false,
  });

  TimboCanvasState copyWith({
    TimboModel? timbo,
    List<BlockModel>? blocks,
    bool? isRecording,
    bool? isSaving,
  }) {
    return TimboCanvasState(
      timbo: timbo ?? this.timbo,
      blocks: blocks ?? this.blocks,
      isRecording: isRecording ?? this.isRecording,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class TimboCanvasNotifier extends StateNotifier<TimboCanvasState> {
  final Ref _ref;
  final int timboId;

  TimboCanvasNotifier(this._ref, this.timboId) : super(TimboCanvasState()) {
    _init();
  }

  void _init() {
    _ref.listen(timboProvider(timboId), (_, next) {
      state = state.copyWith(timbo: next.valueOrNull);
    });
    _ref.listen(blocksProvider(timboId), (_, next) {
      state = state.copyWith(blocks: next.valueOrNull ?? []);
    });
  }

  void setRecording(bool v) => state = state.copyWith(isRecording: v);
  void setSaving(bool v) => state = state.copyWith(isSaving: v);

  Future<void> saveTitle(String title) async {
    setSaving(true);
    await _ref.read(timboRepositoryProvider).updateTimboTitle(timboId, title);
    setSaving(false);
  }

  Future<void> deleteTimbo() async {
    await _ref.read(timboRepositoryProvider).deleteTimbo(timboId);
  }

  Future<int> addTextBlock() async {
    return _ref.read(blockRepositoryProvider).addTextBlock(timboId, '');
  }

  Future<int> addImageBlock(String filePath) async {
    return _ref.read(blockRepositoryProvider).addImageBlock(timboId, filePath);
  }

  Future<int> addVoiceBlock(String filePath) async {
    return _ref.read(blockRepositoryProvider).addVoiceBlock(timboId, filePath);
  }

  Future<int> addChecklistBlock() async {
    final item = ChecklistItem(id: const Uuid().v4(), text: '', isChecked: false);
    return _ref.read(blockRepositoryProvider).addChecklistBlock(timboId, [item]);
  }

  Future<void> deleteBlock(int blockId) async {
    await _ref.read(blockRepositoryProvider).deleteBlock(blockId);
  }

  Future<void> updateTextContent(int blockId, String content) async {
    await _ref.read(blockRepositoryProvider).updateTextContent(blockId, content);
  }

  Future<void> updateChecklistJson(int blockId, List<ChecklistItem> items) async {
    await _ref.read(blockRepositoryProvider).updateChecklistJson(blockId, items);
  }
}

final timboCanvasProvider = StateNotifierProvider.family<TimboCanvasNotifier, TimboCanvasState, int>(
  (ref, timboId) => TimboCanvasNotifier(ref, timboId),
);
