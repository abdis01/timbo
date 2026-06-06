import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message.dart';
import '../config/secrets.dart';
import 'hive_service.dart';

class GeminiService {
  GeminiService._();

  static final GeminiService _instance = GeminiService._();
  static GeminiService get instance => _instance;

  GenerativeModel? _model;
  bool _initialized = false;

  static const _apiKey = Secrets.geminiApiKey;
  static const _systemPrompt = '''
You are Timbo, a calm and professional AI secretary. You have access to the user's personal data context below. Only answer questions about the user's data or give helpful productivity advice. Keep responses concise and practical — 2-3 sentences max unless asked for details. If asked about appointments, notes, or finances, reference the context provided. If the user asks something outside of your scope (unrelated to productivity, notes, reminders, or finances), politely redirect. Use a warm but professional tone.
''';

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
      );
      _initialized = true;
    } catch (_) {}
  }

  String buildContext() {
    final user = HiveService.instance.getUser();
    final userName = user?.name ?? 'Friend';
    final notes = HiveService.instance.getAllNotes();
    final now = DateTime.now();
    final income = HiveService.instance.getTotalIncome(now.month, now.year);
    final expenses = HiveService.instance.getTotalExpenses(now.month, now.year);
    final upcoming = HiveService.instance.getUpcomingReminders();
    final today = HiveService.instance.getTodayReminders();
    final captures = HiveService.instance.getAllCaptures();

    final buffer = StringBuffer()
      ..writeln('USER CONTEXT:')
      ..writeln('Name: $userName')
      ..writeln('Premium: ${user?.isPremium ?? false}')
      ..writeln()
      ..writeln('NOTES (last 10):');

    final recentNotes = notes.length > 10 ? notes.sublist(0, 10) : notes;
    for (final n in recentNotes) {
      buffer.writeln(
          '- [${n.category}] ${n.title.isNotEmpty ? n.title : "Untitled"}: ${n.content.length > 100 ? "${n.content.substring(0, 100)}..." : n.content}');
    }

    buffer
      ..writeln()
      ..writeln('FINANCE (${now.month}/${now.year}):')
      ..writeln('Income: \$${income.toStringAsFixed(2)}')
      ..writeln('Expenses: \$${expenses.toStringAsFixed(2)}')
      ..writeln('Balance: \$${(income - expenses).toStringAsFixed(2)}');

    buffer
      ..writeln()
      ..writeln('REMINDERS:')
      ..writeln('Today: ${today.length} reminders');
    if (upcoming.isNotEmpty) {
      for (final r in upcoming.take(5)) {
        buffer.writeln(
            '- ${r.title} at ${r.scheduledAt.hour}:${r.scheduledAt.minute.toString().padLeft(2, '0')} (${r.priority} priority)');
      }
    }

    buffer
      ..writeln()
      ..writeln('RECENT CAPTURES:');
    for (final c in captures.take(5)) {
      buffer.writeln('- [${c.type}] ${c.content}');
    }

    return buffer.toString();
  }

  Future<String> sendMessage(
    String userMessage,
    List<ChatMessage> history,
  ) async {
    if (!_initialized) await initialize();
    if (_model == null) return "I'm having trouble connecting. Please try again.";

    try {
      final context = buildContext();
      final contents = <Content>[];

      contents.add(Content.text('Here is the current user context:\n\n$context'));

      for (final msg in history) {
        contents.add(Content.text(msg.content));
      }

      contents.add(Content.text(userMessage));

      final response = await _model!.generateContent(contents);
      return response.text ?? "I'm not sure how to respond to that.";
    } catch (e) {
      return "I encountered an error. Please try again.";
    }
  }

  bool canSendMessage() {
    return HiveService.instance.canUserUseAI();
  }

  Future<void> useInteraction() async {
    await HiveService.instance.updateAIInteractionCount();
  }

  String getWelcomeMessage(String userName) {
    return "Hey $userName! I've been keeping track of things for you. What would you like to know?";
  }

  Future<String> generateDailyInsight(String type) async {
    if (!_initialized) await initialize();
    if (_model == null) return 'Check your finances and notes to stay on track today!';

    try {
      final context = buildContext();
      final prompt = _systemPrompt + '\n\nBased on this context, give a single $type insight (1-2 sentences):\n\n$context';
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ??
          'You\'re doing great! Keep up with your notes and budget.';
    } catch (_) {
      return 'Stay productive today! Check your reminders and notes.';
    }
  }
}
