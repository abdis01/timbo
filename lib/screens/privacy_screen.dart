import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Privacy & Terms',
            style: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('Privacy Policy', textPrimary, textSecondary),
          const SizedBox(height: 8),
          _body(
            'Timbo ("we", "our", "app") respects your privacy. This policy explains how we handle your data.',
            textSecondary,
          ),
          const SizedBox(height: 20),
          _sectionTitle('Data We Collect', textPrimary),
          _body(
            '• Account information: email address and display name when you sign up.\n'
            '• Content you create: notes, expenses, reminders, voice recordings, photos, and quick captures.\n'
            '• Usage data: AI interaction counts, feature usage statistics.\n'
            '• Device information: app version, crash reports for debugging.',
            textSecondary,
          ),
          const SizedBox(height: 20),
          _sectionTitle('How We Use Your Data', textPrimary),
          _body(
            '• To provide app functionality: sync your data across devices, generate AI insights.\n'
            '• To improve the app: analyze crash reports and usage patterns.\n'
            '• To communicate: send you reminder notifications you requested.',
            textSecondary,
          ),
          const SizedBox(height: 20),
          _sectionTitle('Data Storage & Security', textPrimary),
          _body(
            'Your data is stored locally on your device using Hive and optionally synced to Firebase Firestore if you enable cloud sync. Data in transit is encrypted via HTTPS. We do not sell your personal data to third parties.',
            textSecondary,
          ),
          const SizedBox(height: 20),
          _sectionTitle('Third-Party Services', textPrimary),
          _body(
            '• Firebase (Google): authentication, cloud storage, crash reporting.\n'
            '• Gemini AI (Google): AI chat and insights (anonymous, no personal data sent).',
            textSecondary,
          ),
          const SizedBox(height: 20),
          _sectionTitle('Your Rights', textPrimary),
          _body(
            'You can delete your account and all associated data at any time from Settings > Delete Account. This removes your data from our servers.',
            textSecondary,
          ),
          const SizedBox(height: 32),
          Divider(color: textSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          _section('Terms of Service', textPrimary, textSecondary),
          const SizedBox(height: 8),
          _body(
            'By using Timbo, you agree to these terms.',
            textSecondary,
          ),
          const SizedBox(height: 20),
          _sectionTitle('Acceptable Use', textPrimary),
          _body(
            'You agree not to misuse the app for illegal activities, spam, or to harm others. You are responsible for the content you create.',
            textSecondary,
          ),
          const SizedBox(height: 20),
          _sectionTitle('AI Feature Disclaimer', textPrimary),
          _body(
            'AI-generated insights and chat responses are provided as-is. They may contain inaccuracies and should not replace professional advice for financial, medical, or legal decisions.',
            textSecondary,
          ),
          const SizedBox(height: 20),
          _sectionTitle('Limitation of Liability', textPrimary),
          _body(
            'Timbo is provided "as is" without warranty. We are not liable for damages arising from app use, data loss, or service interruptions.',
            textSecondary,
          ),
          const SizedBox(height: 20),
          _sectionTitle('Changes', textPrimary),
          _body(
            'We may update these terms. Continued use after changes constitutes acceptance.',
            textSecondary,
          ),
          const SizedBox(height: 20),
          _sectionTitle('Contact', textPrimary),
          _body(
            'For questions, contact: support@timbo.app',
            textSecondary,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String title, Color textPrimary, Color textSecondary) {
    return Text(title,
        style: TextStyle(fontFamily: 'Satoshi', fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary));
  }

  Widget _sectionTitle(String title, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title,
          style: TextStyle(fontFamily: 'Satoshi', fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
    );
  }

  Widget _body(String text, Color textSecondary) {
    return Text(text,
        style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, height: 1.5, color: textSecondary));
  }
}
