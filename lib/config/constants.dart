class AppConstants {
  static const String appName = 'Timbo';
  static const String premiumProductId = 'timbo_premium';

  static const int freeAiDailyLimit = 5;
  static const int premiumAiDailyLimit = 50;
  static const int maxFreeQuickCapturesPerDay = 20;

  static const String hiveNotesBox = 'timbo_notes';
  static const String hiveExpensesBox = 'timbo_expenses';
  static const String hiveRemindersBox = 'timbo_reminders';
  static const String hiveCapturesBox = 'timbo_captures';
  static const String hiveUserBox = 'timbo_user';

  static const String userKey = 'current_user';

  static const String hiveChatBox = 'timbo_chat';

  // AzamPay mobile money pricing (TZS)
  static const double premiumPrice = 10000;
  static const String premiumPriceLabel = 'TZS 10,000/month';

  // AI proxy — key stays on server, never in the app binary
  // Set to null to use direct API (dev mode, key in secrets.dart)
  // Local: "http://localhost:3000"
  // Remote: "https://your-proxy-url.com"
  static const String aiProxyUrl = 'https://timbo-gemini-proxy.abdimagoye26.workers.dev';
}
