import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../config/secrets.dart';
import 'hive_service.dart';
import 'firebase_service.dart';

extension on String {
  Content asContent(String role) => Content(role, [TextPart(this)]);
}

class GeminiService {
  GeminiService._();

  static final GeminiService _instance = GeminiService._();
  static GeminiService get instance => _instance;

  GenerativeModel? _model;
  bool _initialized = false;
  String _apiKey = Secrets.geminiApiKey;
  String _cachedContext = '';
  DateTime _lastContextBuild = DateTime.now().subtract(const Duration(minutes: 1));
  String? _proxyUrl;

  void configure({String? proxyUrl}) {
    _proxyUrl = (proxyUrl != null && proxyUrl.isNotEmpty) ? proxyUrl : null;
  }

  static const _systemPrompt = '''
You are Timbo, the user's personal AI secretary and assistant. You have complete access to everything in their life — their notes, finances, reminders, daily captures, and activities.

Your role is to be helpful, proactive, and warm. When answering questions:
- Always check the user's context data first before responding
- Reference specific notes, expenses, reminders, or captures when relevant
- Give concise, natural answers (2-4 sentences unless asked for details)
- Offer suggestions and proactive tips based on what you see in their data
- If asked about finances, compare categories and give insights
- If asked about reminders, tell them what's upcoming or overdue
- If asked about notes, find relevant content and summarize

Never make up data — only reference what's in the context provided. Be friendly and conversational, like a trusted assistant who knows them well.
''';

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _fetchApiKeyFromRemoteConfig();
    } catch (_) {}
    try {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Gemini init error: $e');
    }
  }

  Future<void> _fetchApiKeyFromRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setDefaults({'gemini_api_key': _apiKey});
      await remoteConfig.fetchAndActivate();
      final fetched = remoteConfig.getString('gemini_api_key');
      if (fetched.isNotEmpty && fetched != _apiKey) {
        _apiKey = fetched;
      }
    } catch (_) {}
  }

  String buildContext() {
    if (DateTime.now().difference(_lastContextBuild).inSeconds < 30) {
      return _cachedContext;
    }
    final user = HiveService.instance.getUser();
    final userName = user?.name ?? 'Friend';
    final notes = HiveService.instance.getAllNotes();
    final now = DateTime.now();
    final income = HiveService.instance.getTotalIncome(now.month, now.year);
    final expenses = HiveService.instance.getTotalExpenses(now.month, now.year);
    final byCategory = HiveService.instance.getExpensesByCategory(now.month, now.year);
    final upcoming = HiveService.instance.getUpcomingReminders();
    final today = HiveService.instance.getTodayReminders();
    final captures = HiveService.instance.getAllCaptures();
    final isPremium = user?.isPremium ?? false;
    final isTrial = HiveService.instance.isTrialActive();

    final buffer = StringBuffer()
      ..writeln('USER CONTEXT:')
      ..writeln('Name: $userName')
      ..writeln('Premium: $isPremium')
      ..writeln('Free trial active: $isTrial')
      ..writeln();

    buffer.writeln('ALL NOTES (${notes.length} total):');
    final displayNotes = notes.take(20);
    for (final n in displayNotes) {
      final preview = n.content.length > 150
          ? '${n.content.substring(0, 150)}...'
          : n.content;
      buffer.writeln(
          '- [${n.category}] "${n.title.isNotEmpty ? n.title : "Untitled"}": $preview');
    }

    buffer
      ..writeln()
      ..writeln('FINANCE (${now.month}/${now.year}):')
      ..writeln('Income: \$${income.toStringAsFixed(2)}')
      ..writeln('Total Expenses: \$${expenses.toStringAsFixed(2)}')
      ..writeln('Balance: \$${(income - expenses).toStringAsFixed(2)}')
      ..writeln('Spending by category:');
    for (final entry in byCategory.entries) {
      final pct = expenses > 0
          ? (entry.value / expenses * 100).toStringAsFixed(0)
          : '0';
      buffer.writeln('- ${entry.key}: \$${entry.value.toStringAsFixed(2)} ($pct%)');
    }

    buffer
      ..writeln()
      ..writeln('REMINDERS:');
    if (today.isNotEmpty) {
      buffer.writeln('Today\'s reminders (${today.length}):');
      for (final r in today) {
        buffer.writeln(
            '- ${r.title} at ${r.scheduledAt.hour}:${r.scheduledAt.minute.toString().padLeft(2, '0')} (${r.priority} priority)${r.description.isNotEmpty ? " - ${r.description}" : ""}');
      }
    }
    if (upcoming.isNotEmpty) {
      buffer.writeln('Upcoming reminders:');
      for (final r in upcoming) {
        final d = r.scheduledAt;
        buffer.writeln(
            '- ${r.title} on ${d.month}/${d.day} at ${d.hour}:${d.minute.toString().padLeft(2, '0')} (${r.priority})${r.description.isNotEmpty ? " - ${r.description}" : ""}');
      }
    }

    buffer
      ..writeln()
      ..writeln('RECENT CAPTURES (last 10):');
    for (final c in captures.take(10)) {
      buffer.writeln('- [${c.type}] ${c.content}');
    }

    _cachedContext = buffer.toString();
    _lastContextBuild = DateTime.now();
    return _cachedContext;
  }

  Future<String> sendMessage(
    String userMessage,
    List<ChatMessage> history,
  ) async {
    if (!FirebaseService.instance.isLoggedIn) {
      return 'Create an account to chat with Timbo AI.';
    }
    if (_proxyUrl != null) {
      return _sendViaProxy(userMessage, history);
    }
    if (!_initialized) await initialize();
    if (_model == null) return "I'm having trouble connecting. Please try again.";

    try {
      final context = buildContext();
      final contents = <Content>[];

      contents.add('Here is the current user context:\n\n$context'.asContent('user'));

      for (final msg in history) {
        contents.add(msg.content.asContent(msg.isUser ? 'user' : 'model'));
      }

      contents.add(userMessage.asContent('user'));

      final response = await _model!.generateContent(contents);
      return response.text ?? "I'm not sure how to respond to that.";
    } catch (e) {
      return "I encountered an error. Please try again.";
    }
  }

  Future<String> _sendViaProxy(
    String userMessage,
    List<ChatMessage> history,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'Create an account to chat with Timbo AI.';
      final token = await user.getIdToken();

      final context = buildContext();
      final historyData = [
        {
          'role': 'user',
          'content': 'Here is the current user context:\n\n$context',
        },
        ...history.map((m) => {
          'role': m.isUser ? 'user' : 'model',
          'content': m.content,
        }),
      ];

      final response = await http.post(
        Uri.parse('$_proxyUrl/geminiChat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'prompt': userMessage,
          'history': historyData,
          'systemPrompt': _systemPrompt,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return (body['reply'] as String?) ?? "I'm not sure how to respond.";
      }

      return 'AI service is busy. Try again in a moment.';
    } catch (_) {
      return 'AI service unavailable. Trying direct connection...';
    }
  }

  bool canSendMessage() {
    if (!FirebaseService.instance.isLoggedIn) return false;
    return HiveService.instance.canUserUseAI();
  }

  Future<void> useInteraction() async {
    await HiveService.instance.updateAIInteractionCount();
  }

  String getWelcomeMessage(String userName) {
    return "Hey $userName! I've been keeping track of things for you. What would you like to know?";
  }

  Future<String> generateDailyInsight(String type) async {
    if (!FirebaseService.instance.isLoggedIn) return 'Sign in to get daily AI insights.';
    if (_proxyUrl != null) return _generateViaProxy(type);
    if (!_initialized) await initialize();
    if (_model == null) return 'Check your finances and notes to stay on track today!';

    try {
      final context = buildContext();
      final prompt = '$_systemPrompt\n\nBased on this context, give a single $type insight (1-2 sentences):\n\n$context';
      final response = await _model!.generateContent([Content('user', [TextPart(prompt)])]);
      return response.text ??
          'You\'re doing great! Keep up with your notes and budget.';
    } catch (_) {
      return 'Stay productive today! Check your reminders and notes.';
    }
  }

  Future<String> _generateViaProxy(String type) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'Sign in to get daily AI insights.';
      final token = await user.getIdToken();
      final context = buildContext();
      final prompt = '$_systemPrompt\n\nBased on this context, give a single $type insight (1-2 sentences):\n\n$context';

      final response = await http.post(
        Uri.parse('$_proxyUrl/geminiGenerate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return (body['text'] as String?) ?? 'You\'re doing great! Keep up with your notes and budget.';
      }
      return 'AI service is busy. Try again later.';
    } catch (_) {
      return 'Stay productive today! Check your reminders and notes.';
    }
  }
}
