import 'package:cloud_functions/cloud_functions.dart';
import '../../domain/chat_message.dart';

class GroqService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> askAI({
    required String question,
    required String context,
    required List<ChatMessageModel> history,
  }) async {
    final result = await _functions
        .httpsCallable('askTimboAI')
        .call({
          'question': question,
          'timboContext': context,
          'chatHistory': history.map((m) => {'role': m.role, 'content': m.content}).toList(),
        });
    return result.data['reply'] as String;
  }

  Future<String> getDailyInsight(String notes) async {
    final result = await _functions
        .httpsCallable('getDailyInsight')
        .call({'recentNotes': notes});
    return result.data['insight'] as String;
  }
}
