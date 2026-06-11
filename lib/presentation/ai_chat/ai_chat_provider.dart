import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/chat_message.dart';
import '../../providers/timbos_provider.dart';
import '../../providers/providers.dart';
import '../../providers/ai_provider.dart';

class AiChatState {
  final List<ChatMessageModel> messages;
  final bool isLoading;
  final bool isOffline;

  AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isOffline = false,
  });

  AiChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isLoading,
    bool? isOffline,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final Ref _ref;

  AiChatNotifier(this._ref) : super(AiChatState()) {
    _ref.listen(chatMessagesProvider, (_, next) {
      state = state.copyWith(messages: next.valueOrNull ?? []);
    });
    _ref.listen(isOnlineProvider, (_, next) {
      state = state.copyWith(isOffline: !next);
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (state.isOffline || state.isLoading) return;

    final repo = _ref.read(aiRepositoryProvider);
    final timboRepo = _ref.read(timboRepositoryProvider);

    await repo.addMessage('user', text.trim());
    state = state.copyWith(isLoading: true);

    try {
      final recentTimbos = await timboRepo.getRecentTimbos(20);
      final context = recentTimbos
          .where((t) => t.title != null && t.title!.isNotEmpty)
          .map((t) => t.title!)
          .join('\n');

      final currentMessages = [...state.messages, ChatMessageModel(id: -1, role: 'user', content: text.trim(), createdAt: DateTime.now())];

      final groq = _ref.read(groqServiceProvider);
      final reply = await groq.askAI(
        question: text.trim(),
        context: context.isEmpty ? 'No notes yet.' : context,
        history: currentMessages.take(currentMessages.length - 1).toList(),
      );

      await repo.addMessage('assistant', reply);
    } catch (_) {
      await repo.addMessage('assistant', 'Sorry, I could not reach the AI right now. Please try again.');
    }

    state = state.copyWith(isLoading: false);
  }

  Future<void> clearChat() async {
    await _ref.read(aiRepositoryProvider).clearChat();
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier(ref);
});
