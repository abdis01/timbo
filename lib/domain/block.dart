import 'dart:convert';
import 'dart:ui' show Offset;

enum BlockType { text, image, voice, checklist, drawing }

class ChecklistItem {
  final String id;
  final String text;
  final bool isChecked;

  ChecklistItem({
    required this.id,
    required this.text,
    this.isChecked = false,
  });

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'isChecked': isChecked};

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    id: json['id'] as String,
    text: json['text'] as String,
    isChecked: json['isChecked'] as bool? ?? false,
  );
}

class DrawingStroke {
  final List<Offset> points;
  final int color;
  final double width;

  DrawingStroke({required this.points, required this.color, this.width = 3.0});

  Map<String, dynamic> toJson() => {
    'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    'color': color,
    'width': width,
  };

  factory DrawingStroke.fromJson(Map<String, dynamic> json) => DrawingStroke(
    points: (json['points'] as List).map((p) => Offset(
      (p['x'] as num).toDouble(),
      (p['y'] as num).toDouble(),
    )).toList(),
    color: json['color'] as int,
    width: (json['width'] as num?)?.toDouble() ?? 3.0,
  );
}

class BlockModel {
  final int id;
  final int timboId;
  final BlockType type;
  final int sortOrder;
  final String? textContent;
  final String? filePath;
  final List<ChecklistItem>? checklistItems;
  final List<DrawingStroke>? drawingStrokes;
  final String? fontFamily;
  final double? positionX;
  final double? positionY;
  final double? blockWidth;
  final double? blockHeight;
  final DateTime createdAt;

  BlockModel({
    required this.id,
    required this.timboId,
    required this.type,
    required this.sortOrder,
    this.textContent,
    this.filePath,
    this.checklistItems,
    this.drawingStrokes,
    this.fontFamily,
    this.positionX,
    this.positionY,
    this.blockWidth,
    this.blockHeight,
    required this.createdAt,
  });

  String get typeString {
    switch (type) {
      case BlockType.text: return 'text';
      case BlockType.image: return 'image';
      case BlockType.voice: return 'voice';
      case BlockType.checklist: return 'checklist';
      case BlockType.drawing: return 'drawing';
    }
  }

  static BlockType typeFromString(String s) {
    switch (s) {
      case 'image': return BlockType.image;
      case 'voice': return BlockType.voice;
      case 'checklist': return BlockType.checklist;
      case 'drawing': return BlockType.drawing;
      default: return BlockType.text;
    }
  }

  static List<DrawingStroke>? parseDrawingData(String? data) {
    if (data == null) return null;
    final parsed = jsonDecode(data) as List;
    return parsed.map((e) => DrawingStroke.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String? encodeDrawingData(List<DrawingStroke>? strokes) {
    if (strokes == null) return null;
    return jsonEncode(strokes.map((e) => e.toJson()).toList());
  }
}
