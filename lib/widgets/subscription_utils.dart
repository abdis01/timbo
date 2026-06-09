import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';
import 'premium_upgrade_sheet.dart';

void showUpgradeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PremiumUpgradeSheet(
      onSubscribe: (phone, provider) => subscribeToPremium(
        context, phone: phone, provider: provider,
      ),
    ),
  );
}

Future<void> subscribeToPremium(
  BuildContext context, {
  required String phone,
  required String provider,
}) async {
  try {
    HapticFeedback.mediumImpact();
    final success = await PaymentService.instance.subscribe(
      phoneNumber: phone,
      provider: provider,
    );
    if (!context.mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to Timbo Premium!'),
          backgroundColor: Color(0xFF149E53),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment pending. Check your phone and try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    }
  }
}
