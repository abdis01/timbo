import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  double amount;
  @HiveField(2)
  String type;
  @HiveField(3)
  String category;
  @HiveField(4)
  String description;
  @HiveField(5)
  String? receiptImagePath;
  @HiveField(6)
  DateTime date;
  @HiveField(7)
  DateTime createdAt;
  @HiveField(8)
  bool isRecurring;
  @HiveField(9)
  String? recurringFrequency;
  @HiveField(10)
  DateTime updatedAt;

  ExpenseModel({
    String? id,
    required this.amount,
    this.type = 'expense',
    required this.category,
    this.description = '',
    this.receiptImagePath,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isRecurring = false,
    this.recurringFrequency,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? type,
    String? category,
    String? description,
    String? receiptImagePath,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    String? recurringFrequency,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type,
        'category': category,
        'description': description,
        'receiptImagePath': receiptImagePath,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isRecurring': isRecurring,
        'recurringFrequency': recurringFrequency,
      };

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] as String? ?? 'expense',
        category: json['category'] as String,
        description: json['description'] as String? ?? '',
        receiptImagePath: json['receiptImagePath'] as String?,
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurringFrequency: json['recurringFrequency'] as String?,
      );
}
