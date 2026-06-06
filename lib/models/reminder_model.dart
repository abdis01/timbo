import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 2)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String description;
  @HiveField(3)
  DateTime scheduledAt;
  @HiveField(4)
  bool isRecurring;
  @HiveField(5)
  String? recurringType;
  @HiveField(6)
  List<int>? recurringDays;
  @HiveField(7)
  bool isCompleted;
  @HiveField(8)
  bool isActive;
  @HiveField(9)
  String priority;
  @HiveField(10)
  DateTime createdAt;
  @HiveField(11)
  DateTime updatedAt;

  ReminderModel({
    String? id,
    required this.title,
    this.description = '',
    required this.scheduledAt,
    this.isRecurring = false,
    this.recurringType,
    this.recurringDays,
    this.isCompleted = false,
    this.isActive = true,
    this.priority = 'medium',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledAt,
    bool? isRecurring,
    String? recurringType,
    List<int>? recurringDays,
    bool? isCompleted,
    bool? isActive,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      recurringDays: recurringDays ?? this.recurringDays,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'scheduledAt': scheduledAt.toIso8601String(),
        'isRecurring': isRecurring,
        'recurringType': recurringType,
        'recurringDays': recurringDays,
        'isCompleted': isCompleted,
        'isActive': isActive,
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurringType: json['recurringType'] as String?,
        recurringDays: (json['recurringDays'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList(),
        isCompleted: json['isCompleted'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        priority: json['priority'] as String? ?? 'medium',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
}
