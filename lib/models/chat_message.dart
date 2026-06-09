import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 6)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String content;
  @HiveField(2)
  final bool isUser;
  @HiveField(3)
  final DateTime timestamp;

  ChatMessage({
    String? id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();
}
