import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';

void showUpgradeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PremiumUpgradeSheet(
      onSubscribe: () => subscribeToPremium(context),
    ),
  );
}

Future<void> subscribeToPremium(BuildContext context) async {
  try {
    HapticFeedback.mediumImpact();
    final success = await PaymentService.instance.subscribe(context);
    if (!context.mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to Timbo Premium!'),
          backgroundColor: Color(0xFF149E53),
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
