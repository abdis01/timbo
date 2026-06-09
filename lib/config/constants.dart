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

  // Reserved for future Stripe/Google Play integration
  static const double premiumPrice = 3.99;
  static const String premiumPriceLabel = '\$3.99/month';

  // Gemini API proxy — key stays on server, never in the app binary
  // Set to null to use direct API (dev mode, key in secrets.dart)
  // Local: "http://localhost:3000"
  // Remote: "https://your-proxy-url.com"
  static const String geminiProxyUrl = 'https://timbo-gemini-proxy.abdimagoye26.workers.dev';
}
