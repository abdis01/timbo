import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'quick_capture_model.g.dart';

@HiveType(typeId: 3)
class QuickCaptureModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String type;
  @HiveField(2)
  String content;
  @HiveField(3)
  String? mediaPath;
  @HiveField(4)
  double? amount;
  @HiveField(5)
  String? category;
  @HiveField(6)
  DateTime capturedAt;
  @HiveField(7)
  bool isProcessed;
  @HiveField(8)
  String? suggestedCategory;
  @HiveField(9)
  DateTime updatedAt;

  QuickCaptureModel({
    String? id,
    required this.type,
    required this.content,
    this.mediaPath,
    this.amount,
    this.category,
    DateTime? capturedAt,
    DateTime? updatedAt,
    this.isProcessed = false,
    this.suggestedCategory,
  })  : id = id ?? const Uuid().v4(),
        capturedAt = capturedAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  QuickCaptureModel copyWith({
    String? id,
    String? type,
    String? content,
    String? mediaPath,
    double? amount,
    String? category,
    DateTime? capturedAt,
    DateTime? updatedAt,
    bool? isProcessed,
    String? suggestedCategory,
  }) {
    return QuickCaptureModel(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaPath: mediaPath ?? this.mediaPath,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      capturedAt: capturedAt ?? this.capturedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProcessed: isProcessed ?? this.isProcessed,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'content': content,
        'mediaPath': mediaPath,
        'amount': amount,
        'category': category,
        'capturedAt': capturedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isProcessed': isProcessed,
        'suggestedCategory': suggestedCategory,
      };

  factory QuickCaptureModel.fromJson(Map<String, dynamic> json) =>
      QuickCaptureModel(
        id: json['id'] as String,
        type: json['type'] as String,
        content: json['content'] as String,
        mediaPath: json['mediaPath'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
        category: json['category'] as String?,
        capturedAt: json['capturedAt'] != null
            ? DateTime.parse(json['capturedAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        isProcessed: json['isProcessed'] as bool? ?? false,
        suggestedCategory: json['suggestedCategory'] as String?,
      );
}
