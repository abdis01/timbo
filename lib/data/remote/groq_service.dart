import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';
import '../../domain/chat_message.dart';

class GroqService {
  final String _baseUrl = AppConstants.aiProxyUrl;

  Future<String> askAI({
    required String question,
    required String context,
    required List<ChatMessageModel> history,
  }) async {
    final systemPrompt =
        'You are Timbo AI — a warm, intelligent personal notebook assistant.\n'
        'You help the user make sense of their thoughts, notes, and ideas.\n'
        'Speak in short, clear sentences. Be helpful, not chatty.\n'
        "You have access to the user's notes (called Timbos).\n"
        'Answer based on what you know from their notes. If unsure, say so.\n\n'
        "User's recent Timbos:\n${context}";

    final resp = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': question,
        'history': history
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
        'systemPrompt': systemPrompt,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('AI request failed: ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return (data['reply'] as String?) ?? '';
  }

  Future<String> getDailyInsight(String notes) async {
    final prompt =
        'Based on these notes: "$notes"\n\n'
        'Write ONE warm, personal sentence (max 20 words) reflecting what '
        'this person has been thinking about. Do not start with "You".';

    final resp = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'history': [],
        'systemPrompt': '',
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Daily insight request failed: ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return (data['reply'] as String?) ?? '';
  }
}
