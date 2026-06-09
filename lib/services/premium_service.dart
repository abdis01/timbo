import '../config/constants.dart';
import 'hive_service.dart';
import 'firebase_service.dart';

class PremiumService {
  PremiumService._();

  static final PremiumService _instance = PremiumService._();
  static PremiumService get instance => _instance;

  bool isPremium() {
    final user = HiveService.instance.getUser();
    return user?.isPremium ?? false;
  }

  int get aiDailyLimit {
    if (isPremium() || HiveService.instance.isTrialActive()) {
      return AppConstants.premiumAiDailyLimit;
    }
    return AppConstants.freeAiDailyLimit;
  }

  int getRemainingInteractions() {
    final user = HiveService.instance.getUser();
    if (user == null) return 0;
    HiveService.instance.resetDailyLimitsIfNeeded();
    return aiDailyLimit - user.aiInteractionsToday;
  }

  bool isAIExhausted() {
    if (!FirebaseService.instance.isAvailable) return true;
    if (!FirebaseService.instance.isLoggedIn) return true;
    return getRemainingInteractions() <= 0;
  }

  bool canUseAI() {
    if (!FirebaseService.instance.isAvailable) return false;
    if (!FirebaseService.instance.isLoggedIn) return false;
    return HiveService.instance.canUserUseAI();
  }

  Future<void> useInteraction() async {
    await HiveService.instance.updateAIInteractionCount();
  }

  bool canQuickCapture() {
    final user = HiveService.instance.getUser();
    if (user == null) return false;
    if (user.isPremium) return true;
    return HiveService.instance.getTodayCaptureCount() <
        AppConstants.maxFreeQuickCapturesPerDay;
  }

  int getSecondsUntilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now).inSeconds;
  }

  String getFormattedTimeUntilMidnight() {
    final seconds = getSecondsUntilMidnight();
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '$hours h ${minutes}m';
    return '${minutes}m';
  }

  String getUpgradePrompt(String blockedFeature) {
    switch (blockedFeature) {
      case 'ai_chat':
        return 'You\'ve used all your free AI conversations today. '
            'Upgrade to Premium for TZS ${AppConstants.premiumPrice.toStringAsFixed(0)}/month!';
      case 'quick_capture':
        return 'Free users can only capture 20 items per day. '
            'Upgrade to Premium for unlimited captures!';
      case 'cloud_sync':
        return 'Cloud sync is a Premium feature. '
            'Upgrade for TZS ${AppConstants.premiumPrice.toStringAsFixed(0)}/month to keep your data safe across devices!';
      case 'insights':
        return 'Advanced insights and analytics are available with Premium. '
            'Upgrade for TZS ${AppConstants.premiumPrice.toStringAsFixed(0)}/month!';
      case 'finance_analysis':
        return 'Spending analysis is available with Premium. '
            'Upgrade for TZS ${AppConstants.premiumPrice.toStringAsFixed(0)}/month!';
      default:
        return 'This feature is available with Premium for '
            'TZS ${AppConstants.premiumPrice.toStringAsFixed(0)}/month. Upgrade to unlock it!';
    }
  }
}
