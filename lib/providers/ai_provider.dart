import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/remote/groq_service.dart';
import '../domain/chat_message.dart';
import '../repositories/ai_repository.dart';
import 'providers.dart';
import 'timbos_provider.dart';

final groqServiceProvider = Provider<GroqService>((ref) => GroqService());

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(databaseProvider));
});

final chatMessagesProvider = StreamProvider<List<ChatMessageModel>>((ref) {
  return ref.watch(aiRepositoryProvider).watchChatMessages();
});

final aiInsightProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(timboRepositoryProvider);
  final timbos = await repo.getRecentTimbos(20);
  return ref.watch(aiRepositoryProvider).getDailyInsight(timbos);
});

final isAiLoadingProvider = StateProvider<bool>((ref) => false);
