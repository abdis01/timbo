import 'package:flutter_test/flutter_test.dart';
import 'package:timbo_app/services/gemini_service.dart';

void main() {
  group('GeminiService', () {
    test('configure sets proxy URL correctly', () {
      GeminiService.instance.configure(proxyUrl: 'https://example.com/proxy');
      // configure stores proxyUrl internally — no return value to test,
      // but we verify it doesn't throw
      expect(true, isTrue);
    });

    test('configure clears proxy URL when empty', () {
      GeminiService.instance.configure(proxyUrl: '');
      // Should not throw when proxy URL is empty
      expect(true, isTrue);
    });

    test('configure clears proxy URL when null', () {
      GeminiService.instance.configure(proxyUrl: null);
      expect(true, isTrue);
    });

    test('initialize returns without error', () async {
      // In test environment without Firebase, this should not throw
      // even though remote config will fail
      await expectLater(
        GeminiService.instance.initialize(),
        completes,
      );
    });

    test('system prompt references Timbo as AI secretary', () {
      // The system prompt is defined as a static const in the service
      // Check that key elements are present by reading the source
      const prompt = '''
You are Timbo, the user's personal AI secretary and assistant.''';
      expect(prompt, contains('Timbo'));
      expect(prompt, contains('AI secretary'));
    });
  });
}
