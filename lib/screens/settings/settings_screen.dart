import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/hive_service.dart';
import '../../services/premium_service.dart';
import '../../services/firebase_service.dart';
import '../../services/notification_service.dart';
import '../../providers/user_provider.dart';
import '../../config/constants.dart';
import '../../widgets/subscription_utils.dart';
import '../../widgets/bottom_nav.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// TODO: Add biometric authentication
// TODO: Implement Stripe payment for premium

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _reminderNotifications = true;
  bool _aiInsightNotifications = false;
  bool _quickAccessNotification = false;
  bool _cloudSync = false;
  String _defaultCaptureType = 'Note';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<UserProvider>().loadUser();
      } catch (_) {}
      _loadSettings();
    });
    SyncService.instance.addListener(_onSyncChanged);
  }

  @override
  void dispose() {
    SyncService.instance.removeListener(_onSyncChanged);
    super.dispose();
  }

  void _onSyncChanged() {
    if (mounted) setState(() {});
  }

  void _loadSettings() {
    final user = HiveService.instance.getUser();
    if (user == null) return;
    setState(() {
      _cloudSync = user.cloudSyncEnabled;
      _defaultCaptureType = user.preferredCaptureType ?? 'Note';
    });
  }

  Future<void> _toggleDarkMode(UserProvider provider) async {
    try {
      await provider.toggleTheme();
    } catch (_) {}
  }

  Future<void> _toggleSetting(
      String field, bool value, UserProvider provider) async {
    final user = provider.user;
    if (user == null) return;
    switch (field) {
      case 'shakeToCapture':
        user.shakeToCapture = value;
        break;
      case 'cloudSync':
        user.cloudSyncEnabled = value;
        break;
    }
    try {
      await HiveService.instance.saveUser(user);
    } catch (_) {}
    setState(() {
      if (field == 'cloudSync') _cloudSync = value;
    });
  }

  Future<void> _setDefaultCaptureType(String type) async {
    final user = HiveService.instance.getUser();
    if (user == null) return;
    user.preferredCaptureType = type;
    try {
      await HiveService.instance.saveUser(user);
      setState(() => _defaultCaptureType = type);
    } catch (_) {}
  }

  Future<void> _syncNow() async {
    try {
      await SyncService.instance.performSync();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection. Working offline.')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked != null) {
        final user = HiveService.instance.getUser();
        if (user != null) {
          user.photoUrl = picked.path;
          await HiveService.instance.saveUser(user);
          if (mounted) {
            context.read<UserProvider>().loadUser();
            setState(() {});
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _signOut() async {
    try {
      if (FirebaseService.instance.isAvailable) {
        await FirebaseService.instance.signOut();
      }
    } catch (_) {}
    try {
      await HiveService.instance.clearUser();
    } catch (_) {}
    if (!mounted) return;
    try {
      await Provider.of<UserProvider>(context, listen: false).logout();
    } catch (_) {}
    if (!mounted) return;
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (_) => false);
    }
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete all your data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardColor = context.cardColor;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        final isPremium = user?.isPremium ?? false;
        final aiUsed = user?.aiInteractionsToday ?? 0;
        final aiLimit = isPremium
            ? AppConstants.premiumAiDailyLimit
            : AppConstants.freeAiDailyLimit;

        return Scaffold(
          backgroundColor: cs.surface,
          bottomNavigationBar: const AppBottomNav(activeRoute: AppRoutes.settings),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Settings',
                style: TextStyle(fontFamily: 'Satoshi', 
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              _animatedTile(0, _profileCard(user, isPremium, cs.onSurface, cs.onSurfaceVariant,
                  cardColor)),
              const SizedBox(height: 24),
              _animatedTile(1, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('APPEARANCE', cs.onSurfaceVariant),
                  const SizedBox(height: 8),
                  _darkModeTile(userProvider, cs.onSurface, cs.onSurfaceVariant, cardColor),
                ],
              )),
              const SizedBox(height: 24),
              _animatedTile(2, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('QUICK CAPTURE', cs.onSurfaceVariant),
                  const SizedBox(height: 8),
                  _shakeTile(userProvider, cs.onSurface, cs.onSurfaceVariant, cardColor),
                  _captureTypeTile(cs.onSurface, cs.onSurfaceVariant, cardColor),
                  _captureLimitTile(cs.onSurface, cs.onSurfaceVariant, cardColor),
                ],
              )),
              const SizedBox(height: 24),
              _animatedTile(3, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('AI & INSIGHTS', cs.onSurfaceVariant),
                  const SizedBox(height: 8),
                  _aiUsageTile(aiUsed, aiLimit, cs.onSurface, cs.onSurfaceVariant,
                      cardColor),
                  if (!isPremium) ...[
                    const SizedBox(height: 4),
                    _upgradeButton(cs.onSurface, cs.onSurfaceVariant, cardColor),
                  ],
                ],
              )),
              const SizedBox(height: 24),
              _animatedTile(4, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('NOTIFICATIONS', cs.onSurfaceVariant),
                  const SizedBox(height: 8),
                  _notificationsTile(cs.onSurface, cs.onSurfaceVariant, cardColor),
                  _reminderNotifTile(cs.onSurface, cs.onSurfaceVariant, cardColor),
                  _aiNotifTile(cs.onSurface, cs.onSurfaceVariant, cardColor),
                  _quickAccessTile(cs.onSurface, cs.onSurfaceVariant, cardColor),
                ],
              )),
              const SizedBox(height: 24),
              _animatedTile(5, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('CLOUD SYNC', cs.onSurfaceVariant),
                  const SizedBox(height: 8),
                  _cloudSyncTile(isPremium, cs.onSurface, cs.onSurfaceVariant, cardColor),
                ],
              )),
              const SizedBox(height: 24),
              _animatedTile(6, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('ACCOUNT', cs.onSurfaceVariant),
                  const SizedBox(height: 8),
                  _signOutTile(cs.onSurface, cs.onSurfaceVariant, cardColor),
                  _deleteTile(cs.onSurface, cs.onSurfaceVariant, cardColor),
                ],
              )),
              const SizedBox(height: 24),
              _animatedTile(7, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('ABOUT', cs.onSurfaceVariant),
                  const SizedBox(height: 8),
                  _aboutTile(cs.onSurface, cs.onSurfaceVariant, cardColor),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _profileCard(
    dynamic user,
    bool isPremium,
    Color textPrimary,
    Color textSecondary,
    Color cardColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = _getInitials(user?.name ?? '');
    final photoPath = user?.photoUrl as String?;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: context.primaryColor,
                  backgroundImage: photoPath != null && photoPath.isNotEmpty
                      ? (kIsWeb ? NetworkImage(photoPath) : FileImage(File(photoPath)) as ImageProvider)
                      : null,
                  child: photoPath == null || photoPath.isEmpty
                      ? Text(
                          initials,
                          style: const TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardColor, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _editName(user),
                  child: Row(
                    children: [
                      Text(
                        user?.name ?? 'Your Name',
                        style: TextStyle(fontFamily: 'Satoshi', 
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.edit_rounded,
                          size: 14, color: textSecondary),
                    ],
                  ),
                ),
                if (user?.email != null && user!.email!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      user.email!,
                      style: TextStyle(fontFamily: 'Satoshi', 
                          fontSize: 13, color: textSecondary),
                    ),
                  ),
                if (isPremium)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.warningColor
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 12,
                              color: context.warningColor),
                          const SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: TextStyle(fontFamily: 'Satoshi', 
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: context.warningColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'T';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _editName(dynamic user) async {
    final controller = TextEditingController(text: user?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final u = HiveService.instance.getUser();
      if (u != null) {
        u.name = result;
        await HiveService.instance.saveUser(u);
        if (mounted) {
          context.read<UserProvider>().loadUser();
        }
      }
    }
  }

  Widget _sectionLabel(String label, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(fontFamily: 'Satoshi', 
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: textSecondary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _settingTile({
    required String title,
    String? subtitle,
    required Widget trailing,
    required Color textPrimary,
    required Color textSecondary,
    required Color cardColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(title,
            style: TextStyle(fontFamily: 'Satoshi', 
                fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: TextStyle(fontFamily: 'Satoshi', fontSize: 12, color: textSecondary))
            : null,
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _darkModeTile(UserProvider provider, Color textPrimary,
      Color textSecondary, Color cardColor) {
    return _settingTile(
      title: 'Dark Mode',
      subtitle: 'The app will look best in dark mode',
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      cardColor: cardColor,
      trailing: Switch.adaptive(
        value: provider.isDarkMode,
        onChanged: (_) => _toggleDarkMode(provider),
        activeThumbColor: context.primaryColor,
      ),
    );
  }

  Widget _shakeTile(UserProvider provider, Color textPrimary,
      Color textSecondary, Color cardColor) {
    return _settingTile(
      title: 'Shake to Capture',
      subtitle: 'Shake device to open quick capture',
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      cardColor: cardColor,
      trailing: Switch.adaptive(
        value: provider.user?.shakeToCapture ?? false,
        onChanged: (v) => _toggleSetting('shakeToCapture', v, provider),
        activeThumbColor: context.primaryColor,
      ),
    );
  }

  Widget _captureTypeTile(Color textPrimary, Color textSecondary,
      Color cardColor) {
    return _settingTile(
      title: 'Default Capture Type',
      subtitle: _defaultCaptureType,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      cardColor: cardColor,
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: const Text('Default Capture Type'),
            children: ['Note', 'Expense', 'Reminder']
                .map((t) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, t),
                      child: Text(t),
                    ))
                .toList(),
          ),
        );
        if (result != null && result != _defaultCaptureType) {
          await _setDefaultCaptureType(result);
        }
      },
    );
  }

  Widget _captureLimitTile(
      Color textPrimary, Color textSecondary, Color cardColor) {
    final isPremium = PremiumService.instance.isPremium();
    return _settingTile(
      title: 'Daily Capture Limit',
      subtitle: isPremium
          ? 'Unlimited'
          : '${AppConstants.maxFreeQuickCapturesPerDay} captures per day',
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      cardColor: cardColor,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isPremium
              ? context.successColor.withValues(alpha: 0.15)
              : context.warningColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isPremium ? 'Unlimited' : 'Free',
          style: TextStyle(fontFamily: 'Satoshi', 
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isPremium
                ? context.successColor
                : context.warningColor,
          ),
        ),
      ),
    );
  }

  Widget _aiUsageTile(int used, int limit, Color textPrimary,
      Color textSecondary, Color cardColor) {
    final isPremium = PremiumService.instance.isPremium();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Interactions',
              style: TextStyle(fontFamily: 'Satoshi', 
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: used / limit,
              backgroundColor: textSecondary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                isPremium
                    ? context.successColor
                    : context.primaryColor,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('$used of $limit used today',
                  style: TextStyle(fontFamily: 'Satoshi', 
                      fontSize: 12, color: textSecondary)),
              const Spacer(),
              Text('Resets at midnight',
                  style: TextStyle(fontFamily: 'Satoshi', 
                      fontSize: 12, color: textSecondary.withValues(alpha: 0.6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _upgradeButton(Color textPrimary, Color textSecondary, Color cardColor) {
    return GestureDetector(
      onTap: () => _showUpgradeSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primaryColor,
              context.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(Icons.workspace_premium_rounded,
                size: 20, color: context.warningColor),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Unlock Premium — Try Free Now',
                style: TextStyle(fontFamily: 'Satoshi', 
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded,
                size: 18, color: Colors.white.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _notificationsTile(Color textPrimary, Color textSecondary,
      Color cardColor) {
    return _settingTile(
      title: 'Enable Notifications',
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      cardColor: cardColor,
      trailing: Switch.adaptive(
        value: _notificationsEnabled,
        onChanged: (v) {
          setState(() => _notificationsEnabled = v);
          if (v) {
            NotificationService.requestPermissions();
          }
        },
        activeThumbColor: context.primaryColor,
      ),
    );
  }

  Widget _reminderNotifTile(Color textPrimary, Color textSecondary,
      Color cardColor) {
    return _settingTile(
      title: 'Reminder Notifications',
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      cardColor: cardColor,
      trailing: Switch.adaptive(
        value: _reminderNotifications,
        onChanged: (v) =>
            setState(() => _reminderNotifications = v),
        activeThumbColor: context.primaryColor,
      ),
    );
  }

  Widget _aiNotifTile(Color textPrimary, Color textSecondary, Color cardColor) {
    return _settingTile(
      title: 'AI Insights Notifications',
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      cardColor: cardColor,
      trailing: Switch.adaptive(
        value: _aiInsightNotifications,
        onChanged: (v) =>
            setState(() => _aiInsightNotifications = v),
        activeThumbColor: context.primaryColor,
      ),
    );
  }

  Widget _quickAccessTile(Color textPrimary, Color textSecondary, Color cardColor) {
    return _settingTile(
      title: 'Quick Access Notification',
      subtitle: 'Persistent notification for one-tap capture',
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      cardColor: cardColor,
      trailing: Switch.adaptive(
        value: _quickAccessNotification,
        onChanged: (v) async {
          setState(() => _quickAccessNotification = v);
          if (v) {
            await NotificationService.showPersistentQuickCaptureNotification();
          } else {
            await NotificationService.cancelPersistentQuickCaptureNotification();
          }
        },
        activeThumbColor: context.primaryColor,
      ),
    );
  }

  Widget _cloudSyncTile(bool isPremium, Color textPrimary, Color textSecondary,
      Color cardColor) {
    if (!isPremium) {
      return GestureDetector(
        onTap: _showUpgradeSheet,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 20, color: textSecondary.withValues(alpha: 0.5)),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Cloud Sync',
                    style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textPrimary.withValues(alpha: 0.5))),
              ),
              Icon(Icons.lock_rounded,
                  size: 16, color: textSecondary.withValues(alpha: 0.4)),
            ],
          ),
        ),
      );
    }

    final syncService = SyncService.instance;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          _settingTile(
            title: 'Cloud Sync',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            cardColor: cardColor,
            trailing: Switch.adaptive(
              value: _cloudSync,
              onChanged: (v) async {
                setState(() => _cloudSync = v);
                final user = HiveService.instance.getUser();
                if (user == null) return;
                user.cloudSyncEnabled = v;
                await HiveService.instance.saveUser(user);
                if (v) {
                  await syncService.performSync();
                }
              },
              activeThumbColor: context.primaryColor,
            ),
          ),
          if (_cloudSync) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: syncService.status == SyncStatus.syncing
                          ? Colors.amber
                          : syncService.status == SyncStatus.idle
                              ? Colors.green
                              : context.dangerColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                        syncService.statusMessage.isEmpty
                            ? (syncService.status == SyncStatus.idle
                                ? 'Idle'
                                : '')
                            : syncService.statusMessage,
                        style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 12,
                            color: textSecondary.withValues(alpha: 0.6))),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  Icon(Icons.sync_rounded,
                      size: 14, color: textSecondary.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Text('Last synced: ${syncService.formattedLastSync}',
                      style: TextStyle(fontFamily: 'Satoshi', 
                          fontSize: 12,
                          color: textSecondary.withValues(alpha: 0.6))),
                  const Spacer(),
                  GestureDetector(
                    onTap: _syncNow,
                    child: Text('Sync Now',
                        style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.primaryColor)),
                  ),
                ],
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                  'Premium feature — enable cloud sync to keep your data safe',
                  style: TextStyle(fontFamily: 'Satoshi', 
                      fontSize: 12,
                      color: textSecondary.withValues(alpha: 0.5))),
            ),
        ],
      ),
    );
  }

  Widget _signOutTile(
      Color textPrimary, Color textSecondary, Color cardColor) {
    return _settingTile(
      title: 'Sign Out',
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      cardColor: cardColor,
      trailing: const Icon(Icons.logout_rounded, size: 18),
      onTap: _signOut,
    );
  }

  Widget _deleteTile(
      Color textPrimary, Color textSecondary, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: ListTile(
        onTap: () async {
          final confirmed = await _confirmDelete();
          if (confirmed && mounted) {
            if (FirebaseService.instance.isAvailable) {
              try {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  await FirebaseFirestore.instance.collection('users').doc(userId).delete();
                }
                await FirebaseAuth.instance.currentUser?.delete();
              } catch (_) {}
            }
            try {
              await HiveService.instance.clearAll();
            } catch (_) {}
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/splash', (_) => false);
            }
          }
        },
        title: Text('Delete Account',
            style: TextStyle(fontFamily: 'Satoshi', 
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.dangerColor)),
        trailing: Icon(Icons.delete_forever_rounded,
            size: 18, color: context.dangerColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _aboutTile(Color textPrimary, Color textSecondary, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 18, color: textSecondary),
              const SizedBox(width: 10),
              Text('Version',
                  style: TextStyle(fontFamily: 'Satoshi', 
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textPrimary)),
              const Spacer(),
              Text('Timbo v1.0.0',
                  style: TextStyle(fontFamily: 'Satoshi', 
                      fontSize: 13, color: textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
            child: Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 16, color: textSecondary),
                const SizedBox(width: 8),
                Text('Privacy & Terms',
                    style: TextStyle(fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textPrimary)),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Made with ❤️ — Powered by Gemini AI',
            style: TextStyle(fontFamily: 'Satoshi', 
                fontSize: 12, color: textSecondary.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _animatedTile(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Interval(index * 0.125, 1.0, curve: Curves.easeOutCubic),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  void _showUpgradeSheet() {
    showUpgradeSheet(context);
  }
}

