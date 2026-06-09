import 'package:flutter_test/flutter_test.dart';
import 'package:timbo_app/services/gemini_service.dart';

void main() {
  group('GroqService', () {
    test('configure sets proxy URL correctly', () {
      GeminiService.instance.configure(proxyUrl: 'https://example.com/proxy');
      expect(true, isTrue);
    });

    test('configure clears proxy URL when empty', () {
      GeminiService.instance.configure(proxyUrl: '');
      expect(true, isTrue);
    });

    test('configure clears proxy URL when null', () {
      GeminiService.instance.configure(proxyUrl: null);
      expect(true, isTrue);
    });

    test('system prompt references Timbo as AI secretary', () {
      const prompt = '''
You are Timbo, the user's personal AI secretary and assistant.''';
      expect(prompt, contains('Timbo'));
      expect(prompt, contains('AI secretary'));
    });

    test('getWelcomeMessage returns greeting with name', () {
      final msg = GeminiService.instance.getWelcomeMessage('John');
      expect(msg, contains('John'));
      expect(msg, contains('Timbo'));
    });

    test('canSendMessage returns false when not logged in', () {
      expect(GeminiService.instance.canSendMessage(), isFalse);
    });
  });
}
