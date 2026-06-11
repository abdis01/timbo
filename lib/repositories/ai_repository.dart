import 'dart:async';
import 'package:drift/drift.dart';
import '../database/database.dart' hide Folder, Timbo, Block, ChatMessage;
import '../database/daos/chat_dao.dart';
import '../domain/chat_message.dart';
import '../domain/timbo.dart';
import '../data/remote/groq_service.dart';

class AiRepository {
  final TimboDatabase _db;
  late final ChatDao _dao;

  AiRepository(this._db) {
    _dao = _db.chatDao;
  }

  Stream<List<ChatMessageModel>> watchChatMessages() {
    return _dao.watchAllMessages().map(
      (list) => list.map((d) => ChatMessageModel(
        id: d.id,
        role: d.role,
        content: d.content,
        createdAt: d.createdAt,
      )).toList(),
    );
  }

  Future<int> addMessage(String role, String content) {
    return _dao.insertMessage(ChatMessagesCompanion(
      role: Value(role),
      content: Value(content),
      createdAt: Value(DateTime.now()),
    ));
  }

  Future<void> clearChat() => _dao.clearHistory();

  Future<String> getDailyInsight(List<TimboModel> recentTimbos) async {
    if (recentTimbos.isEmpty) return 'Start writing — I will share thoughts as I learn you.';
    try {
      final context = recentTimbos
          .where((t) => t.title != null && t.title!.isNotEmpty)
          .map((t) => t.title!)
          .join(', ');
      final groq = GroqService();
      return await groq.getDailyInsight(context);
    } catch (_) {
      final count = recentTimbos.length;
      return "You've created $count Timbo${count > 1 ? 's' : ''}. Open AI chat to dive deeper.";
    }
  }
}
