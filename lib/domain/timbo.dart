class TimboModel {
  final int id;
  final int folderId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool reminderSet;
  final int? reminderTimestamp;
  final String? reminderLabel;

  TimboModel({
    required this.id,
    required this.folderId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.reminderSet,
    this.reminderTimestamp,
    this.reminderLabel,
  });
}
