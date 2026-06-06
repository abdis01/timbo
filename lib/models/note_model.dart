import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String content;
  @HiveField(3)
  String? voiceNotePath;
  @HiveField(4)
  List<String> mediaPaths;
  @HiveField(5)
  String category;
  @HiveField(6)
  DateTime createdAt;
  @HiveField(7)
  DateTime updatedAt;
  @HiveField(8)
  bool isPinned;
  @HiveField(9)
  List<String> tags;

  NoteModel({
    String? id,
    this.title = '',
    this.content = '',
    this.voiceNotePath,
    List<String>? mediaPaths,
    this.category = 'general',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
    List<String>? tags,
  })  : id = id ?? const Uuid().v4(),
        mediaPaths = mediaPaths ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [];

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? voiceNotePath,
    List<String>? mediaPaths,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    List<String>? tags,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      mediaPaths: mediaPaths ?? List.from(this.mediaPaths),
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? List.from(this.tags),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'voiceNotePath': voiceNotePath,
        'mediaPaths': mediaPaths,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isPinned': isPinned,
        'tags': tags,
      };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        voiceNotePath: json['voiceNotePath'] as String?,
        mediaPaths: (json['mediaPaths'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        category: json['category'] as String? ?? 'general',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        isPinned: json['isPinned'] as bool? ?? false,
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}
