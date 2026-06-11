import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart' hide Folder, Timbo, Block, ChatMessage;
import '../database/daos/block_dao.dart';
import '../domain/block.dart';

class BlockRepository {
  final TimboDatabase _db;
  late final BlockDao _dao;

  BlockRepository(this._db) {
    _dao = _db.blockDao;
  }

  Stream<List<BlockModel>> watchBlocks(int timboId) {
    return _dao.watchBlocksByTimbo(timboId).map(
      (list) => list.map((d) {
        final type = BlockModel.typeFromString(d.type);
        List<ChecklistItem>? items;
        if (d.checklistJson != null) {
          final parsed = jsonDecode(d.checklistJson!) as List;
          items = parsed.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>)).toList();
        }
        return BlockModel(
          id: d.id,
          timboId: d.timboId,
          type: type,
          sortOrder: d.sortOrder,
          textContent: d.textContent,
          filePath: d.filePath,
          checklistItems: items,
          drawingStrokes: BlockModel.parseDrawingData(d.drawingData),
          fontFamily: d.fontFamily,
          positionX: d.positionX,
          positionY: d.positionY,
          blockWidth: d.blockWidth,
          blockHeight: d.blockHeight,
          createdAt: d.createdAt,
        );
      }).toList(),
    );
  }

  Future<int> addTextBlock(int timboId, String content, {String? fontFamily}) async {
    final nextOrder = await _dao.getMaxSortOrder(timboId) + 1;
    return _dao.insertBlock(BlocksCompanion(
      timboId: Value(timboId),
      type: const Value('text'),
      sortOrder: Value(nextOrder),
      textContent: Value(content),
      fontFamily: Value(fontFamily),
      createdAt: Value(DateTime.now()),
    ));
  }

  Future<int> addImageBlock(int timboId, String filePath) async {
    final nextOrder = await _dao.getMaxSortOrder(timboId) + 1;
    return _dao.insertBlock(BlocksCompanion(
      timboId: Value(timboId),
      type: const Value('image'),
      sortOrder: Value(nextOrder),
      filePath: Value(filePath),
      createdAt: Value(DateTime.now()),
    ));
  }

  Future<int> addVoiceBlock(int timboId, String filePath) async {
    final nextOrder = await _dao.getMaxSortOrder(timboId) + 1;
    return _dao.insertBlock(BlocksCompanion(
      timboId: Value(timboId),
      type: const Value('voice'),
      sortOrder: Value(nextOrder),
      filePath: Value(filePath),
      createdAt: Value(DateTime.now()),
    ));
  }

  Future<int> addChecklistBlock(int timboId, List<ChecklistItem> items) async {
    final nextOrder = await _dao.getMaxSortOrder(timboId) + 1;
    final json = jsonEncode(items.map((e) => e.toJson()).toList());
    return _dao.insertBlock(BlocksCompanion(
      timboId: Value(timboId),
      type: const Value('checklist'),
      sortOrder: Value(nextOrder),
      checklistJson: Value(json),
      createdAt: Value(DateTime.now()),
    ));
  }

  Future<int> addDrawingBlock(int timboId, List<DrawingStroke> strokes) async {
    final nextOrder = await _dao.getMaxSortOrder(timboId) + 1;
    final data = BlockModel.encodeDrawingData(strokes);
    return _dao.insertBlock(BlocksCompanion(
      timboId: Value(timboId),
      type: const Value('drawing'),
      sortOrder: Value(nextOrder),
      drawingData: Value(data),
      createdAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateTextContent(int blockId, String content) {
    return _dao.updateBlock(BlocksCompanion(
      id: Value(blockId),
      textContent: Value(content),
    ));
  }

  Future<void> updateFontFamily(int blockId, String fontFamily) {
    return _dao.updateBlock(BlocksCompanion(
      id: Value(blockId),
      fontFamily: Value(fontFamily),
    ));
  }

  Future<void> updateChecklistJson(int blockId, List<ChecklistItem> items) {
    final json = jsonEncode(items.map((e) => e.toJson()).toList());
    return _dao.updateBlock(BlocksCompanion(
      id: Value(blockId),
      checklistJson: Value(json),
    ));
  }

  Future<void> updateDrawingData(int blockId, List<DrawingStroke> strokes) {
    final data = BlockModel.encodeDrawingData(strokes);
    return _dao.updateBlock(BlocksCompanion(
      id: Value(blockId),
      drawingData: Value(data),
    ));
  }

  Future<void> updateBlockPosition(int blockId, double x, double y) {
    return _dao.updateBlock(BlocksCompanion(
      id: Value(blockId),
      positionX: Value(x),
      positionY: Value(y),
    ));
  }

  Future<void> updateBlockSize(int blockId, double width, double height) {
    return _dao.updateBlock(BlocksCompanion(
      id: Value(blockId),
      blockWidth: Value(width),
      blockHeight: Value(height),
    ));
  }

  Future<void> reorderBlock(int blockId, int newSortOrder) => _dao.updateSortOrder(blockId, newSortOrder);

  Future<void> deleteBlock(int blockId) => _dao.deleteBlock(blockId);

  Future<int> restoreBlock(BlockModel block) async {
    return _dao.insertBlock(BlocksCompanion(
      timboId: Value(block.timboId),
      type: Value(block.typeString),
      sortOrder: Value(block.sortOrder),
      textContent: Value<String?>(block.textContent),
      filePath: Value<String?>(block.filePath),
      checklistJson: Value<String?>(block.checklistItems != null
          ? jsonEncode(block.checklistItems!.map((e) => e.toJson()).toList())
          : null),
      drawingData: Value<String?>(block.drawingStrokes != null
          ? BlockModel.encodeDrawingData(block.drawingStrokes)
          : null),
      fontFamily: Value<String?>(block.fontFamily),
      positionX: Value<double?>(block.positionX),
      positionY: Value<double?>(block.positionY),
      blockWidth: Value<double?>(block.blockWidth),
      blockHeight: Value<double?>(block.blockHeight),
      createdAt: Value(block.createdAt),
    ));
  }

  Future<List<BlockModel>> searchBlocks(String query) async {
    final results = await _dao.searchBlocks(query);
    return results.map((d) {
      final type = BlockModel.typeFromString(d.type);
      List<ChecklistItem>? items;
      if (d.checklistJson != null) {
        final parsed = jsonDecode(d.checklistJson!) as List;
        items = parsed.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      return BlockModel(
        id: d.id, timboId: d.timboId, type: type,
        sortOrder: d.sortOrder, textContent: d.textContent,
        filePath: d.filePath, checklistItems: items,
        drawingStrokes: BlockModel.parseDrawingData(d.drawingData),
        fontFamily: d.fontFamily,
        positionX: d.positionX, positionY: d.positionY,
        blockWidth: d.blockWidth, blockHeight: d.blockHeight,
        createdAt: d.createdAt,
      );
    }).toList();
  }
}
