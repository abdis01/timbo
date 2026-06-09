import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timbo_app/config/constants.dart';
import 'package:timbo_app/models/user_model.dart';
import 'package:timbo_app/services/hive_service.dart';
import 'package:timbo_app/services/premium_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('premium_test_');
    SharedPreferences.setMockInitialValues({});
    await HiveService.instance.init(testPath: tempDir.path);
  });

  tearDown(() async {
    await HiveService.instance.dispose();
    tempDir.deleteSync(recursive: true);
  });

  Future<void> saveUser(UserModel user) async {
    await HiveService.instance.saveUser(user);
    // reload from Hive to ensure state is consistent
    HiveService.instance.getUser();
  }

  group('PremiumService', () {
    test('isPremium returns false for free user', () async {
      await saveUser(UserModel(name: 'Test', isPremium: false));
      expect(PremiumService.instance.isPremium(), false);
    });

    test('isPremium returns true for premium user', () async {
      await saveUser(UserModel(name: 'Test', isPremium: true));
      expect(PremiumService.instance.isPremium(), true);
    });

    test('aiDailyLimit returns free limit for free user without trial', () async {
      await saveUser(UserModel(name: 'Test', isPremium: false));
      expect(PremiumService.instance.aiDailyLimit, AppConstants.freeAiDailyLimit);
    });

    test('aiDailyLimit returns premium limit for premium user', () async {
      await saveUser(UserModel(name: 'Test', isPremium: true));
      expect(PremiumService.instance.aiDailyLimit, AppConstants.premiumAiDailyLimit);
    });

    test('aiDailyLimit returns premium limit during trial', () async {
      await saveUser(UserModel(
        name: 'Test',
        isPremium: false,
        trialStartDate: DateTime.now(),
      ));
      expect(PremiumService.instance.aiDailyLimit, AppConstants.premiumAiDailyLimit);
    });

    test('aiDailyLimit returns free limit after trial expires', () async {
      await saveUser(UserModel(
        name: 'Test',
        isPremium: false,
        trialStartDate: DateTime.now().subtract(const Duration(days: 4)),
      ));
      expect(PremiumService.instance.aiDailyLimit, AppConstants.freeAiDailyLimit);
    });

    test('useInteraction increments count', () async {
      await saveUser(UserModel(name: 'Test', aiInteractionsToday: 3));

      await PremiumService.instance.useInteraction();

      final updated = HiveService.instance.getUser();
      expect(updated?.aiInteractionsToday, 4);
    });

    test('getRemainingInteractions returns correct count', () async {
      await saveUser(UserModel(
        name: 'Test',
        isPremium: false,
        aiInteractionsToday: 2,
      ));

      final remaining = PremiumService.instance.getRemainingInteractions();
      expect(remaining, AppConstants.freeAiDailyLimit - 2);
    });

    test('canQuickCapture returns false for null user', () {
      expect(PremiumService.instance.canQuickCapture(), false);
    });

    test('canQuickCapture returns true for premium user', () async {
      await saveUser(UserModel(name: 'Test', isPremium: true));
      expect(PremiumService.instance.canQuickCapture(), true);
    });

    test('getSecondsUntilMidnight returns positive value', () {
      final seconds = PremiumService.instance.getSecondsUntilMidnight();
      expect(seconds, greaterThan(0));
      expect(seconds, lessThanOrEqualTo(86400));
    });

    test('getUpgradePrompt returns correct message for ai_chat', () {
      final prompt = PremiumService.instance.getUpgradePrompt('ai_chat');
      expect(prompt, contains('Premium'));
      expect(prompt, contains(AppConstants.premiumPrice.toStringAsFixed(2)));
    });
  });
}
