import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/providers.dart';
import '../config/theme.dart';
import '../services/sync_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);
    final userName = ref.watch(userNameProvider);
    final isDark = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: cs.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person_rounded, size: 48, color: cs.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? userName,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22),
                  ),
                  if (user?.email != null)
                    Text(
                      user!.email!,
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Preferences', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: isDark,
                    onChanged: (v) => ref.read(themeModeProvider.notifier).state = v,
                    activeColor: TimboColors.primary,
                  ),
                  SwitchListTile(
                    title: const Text('Shake to Capture'),
                    value: true,
                    onChanged: (_) {},
                    activeColor: TimboColors.primary,
                  ),
                  SwitchListTile(
                    title: const Text('Notifications'),
                    value: true,
                    onChanged: (_) {},
                    activeColor: TimboColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Account', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Sign Out'),
                    trailing: const Icon(Icons.logout_rounded),
                    onTap: () async {
                      await auth.FirebaseAuth.instance.signOut();
                      final prefs = await ref.read(sharedPrefsProvider.future);
                      await prefs.setBool('hasSeenOnboarding', true);
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, '/auth');
                    },
                  ),
                  ListTile(
                    title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                    trailing: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text('This cannot be undone. All your data will be permanently deleted.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('Privacy Policy', style: TextStyle(color: cs.primary)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
