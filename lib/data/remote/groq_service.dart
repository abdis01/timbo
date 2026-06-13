import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';
import '../../domain/chat_message.dart';

class GroqService {
  final String _baseUrl = AppConstants.aiProxyUrl;
  static const _timeout = Duration(seconds: 30);

  Future<String> askAI({
    required String question,
    required String context,
    required List<ChatMessageModel> history,
  }) async {
    final now = DateTime.now();
    final dateStr =
        '${['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][now.weekday - 1]}, '
        '${['January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'][now.month - 1]} '
        '${now.day}, ${now.year}';

    final systemPrompt =
        'You are Timbo AI — a warm, conversational personal assistant.\n'
        "You help the user with their notes, thoughts, and daily life.\n"
        'Talk naturally like a friend. Ask questions, suggest ideas, be proactive.\n'
        "You can read the user's notes (called Timbos) to give context.\n"
        'You can help create notes, set reminders, and organize thoughts.\n'
        'Keep responses concise and human. Be curious, not robotic.\n'
        'If asked who created you, say you were made by Abdi.\n'
        'Today is $dateStr.\n\n'
        "User's recent Timbos:\n${context}";

    try {
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
      ).timeout(_timeout);

      if (resp.statusCode != 200) {
        throw Exception('AI request failed: ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body);
      if (data is Map && data['reply'] is String) {
        return data['reply'] as String;
      }
      return '';
    } on TimeoutException {
      throw Exception('AI request timed out. Please try again.');
    } on FormatException {
      throw Exception('Received invalid response from AI service.');
    }
  }

  Future<String> getDailyInsight(String notes) async {
    final prompt =
        'Based on these notes: "$notes"\n\n'
        'Write ONE warm, personal sentence (max 20 words) reflecting what '
        'this person has been thinking about. Do not start with "You".';

    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'history': [],
          'systemPrompt': '',
        }),
      ).timeout(_timeout);

      if (resp.statusCode != 200) {
        throw Exception('Daily insight request failed: ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body);
      if (data is Map && data['reply'] is String) {
        return data['reply'] as String;
      }
      return '';
    } on TimeoutException {
      throw Exception('Daily insight request timed out.');
    } on FormatException {
      throw Exception('Received invalid response from insight service.');
    }
  }
}
