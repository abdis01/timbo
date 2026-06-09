import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class PremiumUpgradeData {
  final IconData icon;
  final String title;
  final String subtitle;
  const PremiumUpgradeData(this.icon, this.title, this.subtitle);
}

class PremiumUpgradeSheet extends StatefulWidget {
  final void Function(String phone, String provider) onSubscribe;
  const PremiumUpgradeSheet({super.key, required this.onSubscribe});

  @override
  State<PremiumUpgradeSheet> createState() => _PremiumUpgradeSheetState();
}

class _PremiumUpgradeSheetState extends State<PremiumUpgradeSheet> {
  final _phoneController = TextEditingController();
  String _selectedProvider = 'Mpesa';
  bool _loading = false;

  final _providers = ['Mpesa', 'Tigo', 'Airtel'];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gold = context.warningColor;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;

    const comparisons = [
      _ComparisonData('AI Conversations', '5/day', 'Unlimited'),
      _ComparisonData('Insights', '1/day', 'All unlocked'),
      _ComparisonData('Quick Captures', '20/day', 'Unlimited'),
      _ComparisonData('Cloud Sync', '\u2717', '\u2713'),
      _ComparisonData('Spending Analysis', '\u2717', '\u2713'),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(Icons.workspace_premium_rounded, size: 48, color: gold),
          const SizedBox(height: 12),
          Text(
            'Timbo Premium',
            style: TextStyle(fontFamily: 'Satoshi',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Unlock the full Timbo experience',
            style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'TZS ${AppConstants.premiumPrice.toStringAsFixed(0)}/month',
            style: TextStyle(fontFamily: 'Satoshi',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: gold,
            ),
          ),
          const SizedBox(height: 20),
          _ComparisonTable(comparisons: comparisons, gold: gold, cs: cs),
          const SizedBox(height: 20),
          // Phone number input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '255712345678',
                prefixIcon: const Icon(Icons.phone_android_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              style: TextStyle(fontFamily: 'Satoshi', color: textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          // Provider selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedProvider,
              decoration: InputDecoration(
                labelText: 'Mobile Money Provider',
                prefixIcon: const Icon(Icons.mobile_friendly_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              items: _providers.map((p) => DropdownMenuItem(
                value: p,
                child: Text(p),
              )).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedProvider = v);
              },
              style: TextStyle(fontFamily: 'Satoshi', color: textPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll receive a USSD prompt on your phone.\nEnter your PIN to confirm payment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Satoshi', fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gold, gold.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSubscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Pay TZS ${AppConstants.premiumPrice.toStringAsFixed(0)} via $_selectedProvider',
                          style: TextStyle(fontFamily: 'Satoshi',
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe Later',
                style: TextStyle(fontFamily: 'Satoshi',
                    fontSize: 13, color: textSecondary)),
          ),
        ],
      ),
    );
  }

  void _handleSubscribe() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }
    final fullPhone = phone.startsWith('255') ? phone : '255$phone';
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    widget.onSubscribe(fullPhone, _selectedProvider);
  }
}

class _ComparisonData {
  final String feature;
  final String free;
  final String premium;
  const _ComparisonData(this.feature, this.free, this.premium);
}

class _ComparisonTable extends StatelessWidget {
  final List<_ComparisonData> comparisons;
  final Color gold;
  final ColorScheme cs;

  const _ComparisonTable({
    required this.comparisons,
    required this.gold,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: gold.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text('Feature',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text('You',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Satoshi',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Premium',
                              style: TextStyle(fontFamily: 'Satoshi',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black)),
                        ),
                        const SizedBox(height: 2),
                        Text('Most Popular',
                            style: TextStyle(fontFamily: 'Satoshi',
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: gold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ...comparisons.map((c) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(c.feature,
                            style: TextStyle(fontFamily: 'Satoshi',
                                fontSize: 13, color: cs.onSurface)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(c.free,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Satoshi',
                                fontSize: 13, color: Colors.grey)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(c.premium,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Satoshi',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: gold)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
