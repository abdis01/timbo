import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_model.g.dart';

@HiveType(typeId: 4)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String? email;
  @HiveField(3)
  bool isPremium;
  @HiveField(4)
  DateTime joinedAt;
  @HiveField(5)
  int aiInteractionsToday;
  @HiveField(6)
  DateTime lastInteractionReset;
  @HiveField(7)
  bool darkModeEnabled;
  @HiveField(8)
  bool cloudSyncEnabled;
  @HiveField(9)
  bool shakeToCapture;
  @HiveField(10)
  String? preferredCaptureType;
  @HiveField(11)
  int totalNotes;
  @HiveField(12)
  int totalExpenses;
  @HiveField(13)
  int totalReminders;
  @HiveField(14)
  String? photoUrl;
  @HiveField(15)
  DateTime? trialStartDate;

  UserModel({
    String? id,
    this.name = '',
    this.email,
    this.isPremium = false,
    DateTime? joinedAt,
    this.aiInteractionsToday = 0,
    DateTime? lastInteractionReset,
    this.darkModeEnabled = false,
    this.cloudSyncEnabled = false,
    this.shakeToCapture = false,
    this.preferredCaptureType,
    this.totalNotes = 0,
    this.totalExpenses = 0,
    this.totalReminders = 0,
    this.photoUrl,
    this.trialStartDate,
  })  : id = id ?? const Uuid().v4(),
        joinedAt = joinedAt ?? DateTime.now(),
        lastInteractionReset = lastInteractionReset ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isPremium,
    DateTime? joinedAt,
    int? aiInteractionsToday,
    DateTime? lastInteractionReset,
    bool? darkModeEnabled,
    bool? cloudSyncEnabled,
    bool? shakeToCapture,
    String? preferredCaptureType,
    int? totalNotes,
    int? totalExpenses,
    int? totalReminders,
    String? photoUrl,
    DateTime? trialStartDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isPremium: isPremium ?? this.isPremium,
      joinedAt: joinedAt ?? this.joinedAt,
      aiInteractionsToday:
          aiInteractionsToday ?? this.aiInteractionsToday,
      lastInteractionReset:
          lastInteractionReset ?? this.lastInteractionReset,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      shakeToCapture: shakeToCapture ?? this.shakeToCapture,
      preferredCaptureType:
          preferredCaptureType ?? this.preferredCaptureType,
      totalNotes: totalNotes ?? this.totalNotes,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalReminders: totalReminders ?? this.totalReminders,
      photoUrl: photoUrl ?? this.photoUrl,
      trialStartDate: trialStartDate ?? this.trialStartDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'isPremium': isPremium,
        'joinedAt': joinedAt.toIso8601String(),
        'aiInteractionsToday': aiInteractionsToday,
        'lastInteractionReset': lastInteractionReset.toIso8601String(),
        'darkModeEnabled': darkModeEnabled,
        'cloudSyncEnabled': cloudSyncEnabled,
        'shakeToCapture': shakeToCapture,
        'preferredCaptureType': preferredCaptureType,
        'totalNotes': totalNotes,
        'totalExpenses': totalExpenses,
        'totalReminders': totalReminders,
        'photoUrl': photoUrl,
        'trialStartDate': trialStartDate?.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        email: json['email'] as String?,
        isPremium: json['isPremium'] as bool? ?? false,
        joinedAt: json['joinedAt'] != null
            ? DateTime.parse(json['joinedAt'] as String)
            : null,
        aiInteractionsToday: json['aiInteractionsToday'] as int? ?? 0,
        lastInteractionReset: json['lastInteractionReset'] != null
            ? DateTime.parse(json['lastInteractionReset'] as String)
            : null,
        darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
        cloudSyncEnabled: json['cloudSyncEnabled'] as bool? ?? false,
        shakeToCapture: json['shakeToCapture'] as bool? ?? false,
        preferredCaptureType: json['preferredCaptureType'] as String?,
        totalNotes: json['totalNotes'] as int? ?? 0,
        totalExpenses: json['totalExpenses'] as int? ?? 0,
        totalReminders: json['totalReminders'] as int? ?? 0,
        photoUrl: json['photoUrl'] as String?,
        trialStartDate: json['trialStartDate'] != null
            ? DateTime.parse(json['trialStartDate'] as String)
            : null,
      );
}
