import 'package:flutter_test/flutter_test.dart';
import 'package:timbo_app/data/remote/groq_service.dart';

void main() {
  group('GroqService', () {
    final service = GroqService();

    test('askAI returns a non-empty reply', () async {
      final reply = await service.askAI(
        question: 'Say hello in 5 words or less',
        context: 'No notes yet.',
        history: [],
      );
      expect(reply, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('getDailyInsight returns a non-empty sentence', () async {
      final insight = await service.getDailyInsight('Went for a walk. Had coffee.');
      expect(insight, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
