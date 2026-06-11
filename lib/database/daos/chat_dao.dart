import 'package:drift/drift.dart';
import '../tables/chat_messages_table.dart';
import '../database.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [ChatMessages])
class ChatDao extends DatabaseAccessor<TimboDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  Stream<List<ChatMessage>> watchAllMessages() {
    return (select(chatMessages)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)])
    ).watch();
  }

  Future<int> insertMessage(ChatMessagesCompanion msg) => into(chatMessages).insert(msg);

  Future<void> clearHistory() => delete(chatMessages).go();
}
