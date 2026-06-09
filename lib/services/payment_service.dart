import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/flutterwave_config.dart';
import '../config/constants.dart';
import 'firebase_service.dart';
import 'hive_service.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService _instance = PaymentService._();
  static PaymentService get instance => _instance;

  Future<ChargeResponse?> initiatePremiumPayment(BuildContext context) async {
    final user = HiveService.instance.getUser();
    if (user == null) return null;

    final email = user.email ?? 'user@timbo.app';
    final name = user.name.isNotEmpty ? user.name : 'Timbo User';
    final txRef = 'TMB-${DateTime.now().millisecondsSinceEpoch}-${user.id.substring(0, 8)}';

    final customer = Customer(name: name, phoneNumber: '', email: email);
    final customization = Customization(
      title: 'Timbo Premium',
      description: 'Unlock all premium features',
      logo: '',
    );

    final flutterwave = Flutterwave(
      publicKey: FlutterwaveConfig.publicKey,
      txRef: txRef,
      amount: AppConstants.premiumPrice.toStringAsFixed(0),
      customer: customer,
      paymentOptions: 'card, mobilemoneytz, ussd',
      customization: customization,
      redirectUrl: FlutterwaveConfig.redirectUrl,
      isTestMode: FlutterwaveConfig.publicKey.contains('test'),
      currency: FlutterwaveConfig.currency,
      meta: {'userId': user.id},
    );

    return await flutterwave.charge(context);
  }

  Future<bool> verifyPayment(String txRef) async {
    try {
      final response = await http.post(
        Uri.parse('${FlutterwaveConfig.proxyUrl}/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tx_ref': txRef}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['verified'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> subscribe(BuildContext context) async {
    final response = await initiatePremiumPayment(context);
    if (response == null) return false;

    if (response.success == true && response.status == 'success') {
      final verified = await verifyPayment(response.txRef);
      if (verified) {
        final userId = FirebaseService.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseService.instance.setPremiumStatus(userId, true);
        }
        final user = HiveService.instance.getUser();
        if (user != null) {
          user.isPremium = true;
          await HiveService.instance.saveUser(user);
        }
        return true;
      }
    }
    return false;
  }
}
