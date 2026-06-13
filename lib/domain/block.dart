enum BlockType { text, image, voice, checklist }

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

class BlockModel {
  final int id;
  final int timboId;
  final BlockType type;
  final int sortOrder;
  final String? textContent;
  final String? filePath;
  final List<ChecklistItem>? checklistItems;
  final String? fontFamily;
  final DateTime createdAt;

  BlockModel({
    required this.id,
    required this.timboId,
    required this.type,
    required this.sortOrder,
    this.textContent,
    this.filePath,
    this.checklistItems,
    this.fontFamily,
    required this.createdAt,
  });

  String get typeString {
    switch (type) {
      case BlockType.text: return 'text';
      case BlockType.image: return 'image';
      case BlockType.voice: return 'voice';
      case BlockType.checklist: return 'checklist';
    }
  }

  static BlockType typeFromString(String s) {
    switch (s) {
      case 'image': return BlockType.image;
      case 'voice': return BlockType.voice;
      case 'checklist': return BlockType.checklist;
      default: return BlockType.text;
    }
  }
}
