import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/payment_config.dart';
import '../config/constants.dart';
import 'firebase_service.dart';
import 'hive_service.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService _instance = PaymentService._();
  static PaymentService get instance => _instance;

  String? _currentExternalId;

  Future<Map<String, dynamic>> initiateMnoCheckout({
    required String phoneNumber,
    required String provider,
  }) async {
    final user = HiveService.instance.getUser();
    if (user == null) return {'success': false, 'error': 'User not found'};

    final externalId =
        'TMB-${DateTime.now().millisecondsSinceEpoch}-${user.id.substring(0, 6)}';
    _currentExternalId = externalId;

    try {
      final response = await http.post(
        Uri.parse('${PaymentConfig.proxyUrl}/azampay-checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'amount': AppConstants.premiumPrice.toStringAsFixed(0),
          'currency': PaymentConfig.currency,
          'provider': provider,
          'external_id': externalId,
          'app_name': PaymentConfig.appName,
          'client_id': PaymentConfig.clientId,
          'client_secret': PaymentConfig.clientSecret,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'error': 'Server error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> verifyPayment(String externalId) async {
    try {
      final response = await http.get(
        Uri.parse('${PaymentConfig.proxyUrl}/azampay-verify?external_id=$externalId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['verified'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> subscribe({
    required String phoneNumber,
    required String provider,
  }) async {
    final result = await initiateMnoCheckout(
      phoneNumber: phoneNumber,
      provider: provider,
    );

    if (result['success'] != true) {
      return false;
    }

    final externalId = (result['external_id'] as String?) ?? _currentExternalId;
    if (externalId == null) return false;

    for (var i = 0; i < 40; i++) {
      final verified = await verifyPayment(externalId);
      if (verified) {
        final uid = FirebaseService.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseService.instance.setPremiumStatus(uid, true);
        }
        final user = HiveService.instance.getUser();
        if (user != null) {
          user.isPremium = true;
          await HiveService.instance.saveUser(user);
        }
        return true;
      }
      await Future.delayed(const Duration(seconds: 3));
    }
    return false;
  }
}
