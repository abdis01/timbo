import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/providers.dart';
import '../core/widgets/sketch_container.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditingName = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final name = ref.read(userNameProvider);
    _nameController = TextEditingController(text: name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    try {
      await auth.FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    } catch (_) {}
    setState(() => _isEditingName = false);
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
      if (image != null) {
        ref.read(preferencesServiceProvider).avatarPath = image.path;
        setState(() {});
      }
    } catch (_) {}
  }

  void _removeAvatar() {
    ref.read(preferencesServiceProvider).avatarPath = null;
    setState(() {});
  }

  static const _fonts = [
    'Inter', 'Caveat', 'Merriweather', 'Fira Code', 'Playfair Display', 'Source Sans 3',
  ];

  void _showFontPicker(String currentFont) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TimboColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Default Font', style: TimboTypography.heading3),
            const SizedBox(height: 16),
            ..._fonts.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                selected: currentFont == f,
                selectedTileColor: TimboColors.ink.withValues(alpha: 0.06),
                title: Text(f, style: const TextStyle(fontSize: 16, color: TimboColors.ink)),
                trailing: currentFont == f
                    ? const Icon(Icons.check, size: 18, color: TimboColors.ink)
                    : null,
                onTap: () {
                  ref.read(preferencesServiceProvider).defaultFont = f;
                  Navigator.pop(ctx);
                  setState(() {});
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userName = ref.watch(userNameProvider);
    final prefs = ref.watch(preferencesServiceProvider);
    final shakeVal = prefs.shakeEnabled;
    final notifVal = prefs.notificationsEnabled;
    final linesVal = prefs.linesEnabled;
    final defaultFont = prefs.defaultFont;
    final avatarPath = prefs.avatarPath;

    return Scaffold(
      backgroundColor: TimboColors.appBackground,
      appBar: AppBar(
        backgroundColor: TimboColors.appBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Profile', style: TimboTypography.heading3),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          _ProfileCard(
            user: user,
            userName: userName,
            isEditingName: _isEditingName,
            nameController: _nameController,
            avatarPath: avatarPath,
            onToggleEdit: () {
              if (_isEditingName) _saveName();
              else setState(() => _isEditingName = true);
            },
            onPickAvatar: _pickAvatar,
            onRemoveAvatar: _removeAvatar,
          ),
          const SizedBox(height: 12),
          _PreferencesCard(
            shakeEnabled: shakeVal,
            notificationsEnabled: notifVal,
            linesEnabled: linesVal,
            defaultFont: defaultFont,
            onToggleShake: (v) {
              ref.read(preferencesServiceProvider).shakeEnabled = v;
              setState(() {});
            },
            onToggleNotifications: (v) {
              ref.read(preferencesServiceProvider).notificationsEnabled = v;
              setState(() {});
            },
            onToggleLines: (v) {
              ref.read(preferencesServiceProvider).linesEnabled = v;
              setState(() {});
            },
            onFontTap: () => _showFontPicker(defaultFont),
          ),
          const SizedBox(height: 12),
          _AccountCard(),
          const SizedBox(height: 24),
          Center(child: Text('Timbo v1.0.0', style: TextStyle(fontSize: 12, color: TimboColors.inkFaint))),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final dynamic user;
  final String userName;
  final bool isEditingName;
  final TextEditingController nameController;
  final String? avatarPath;
  final VoidCallback onToggleEdit;
  final VoidCallback onPickAvatar;
  final VoidCallback onRemoveAvatar;

  const _ProfileCard({
    required this.user,
    required this.userName,
    required this.isEditingName,
    required this.nameController,
    this.avatarPath,
    required this.onToggleEdit,
    required this.onPickAvatar,
    required this.onRemoveAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return SketchContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: onPickAvatar,
            onLongPress: avatarPath != null ? onRemoveAvatar : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: TimboColors.ink.withValues(alpha: 0.1),
                  backgroundImage: avatarPath != null ? FileImage(File(avatarPath!)) : null,
                  child: avatarPath == null ? const Icon(Icons.person_rounded, size: 40, color: TimboColors.ink) : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: onPickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: TimboColors.ink, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (isEditingName)
            TextField(
              controller: nameController,
              autofocus: true,
              textAlign: TextAlign.center,
              style: TimboTypography.heading2,
              decoration: InputDecoration(border: InputBorder.none, isCollapsed: true),
              onSubmitted: (_) => onToggleEdit(),
              onTapOutside: (_) => onToggleEdit(),
            )
          else
            Text(userName, style: TimboTypography.heading2),
          if (user?.email != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(user!.email!, style: TimboTypography.caption),
            ),
        ],
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  final bool shakeEnabled;
  final bool notificationsEnabled;
  final bool linesEnabled;
  final String defaultFont;
  final ValueChanged<bool> onToggleShake;
  final ValueChanged<bool> onToggleNotifications;
  final ValueChanged<bool> onToggleLines;
  final VoidCallback onFontTap;

  const _PreferencesCard({
    required this.shakeEnabled,
    required this.notificationsEnabled,
    required this.linesEnabled,
    required this.defaultFont,
    required this.onToggleShake,
    required this.onToggleNotifications,
    required this.onToggleLines,
    required this.onFontTap,
  });

  @override
  Widget build(BuildContext context) {
    return SketchContainer(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Text('Preferences', style: TimboTypography.heading3.copyWith(fontSize: 16)),
          ),
          SwitchListTile(
            title: Text('Shake to Capture', style: TimboTypography.body),
            value: shakeEnabled,
            onChanged: onToggleShake,
            activeThumbColor: TimboColors.ink,
          ),
          SwitchListTile(
            title: Text('Notifications', style: TimboTypography.body),
            value: notificationsEnabled,
            onChanged: onToggleNotifications,
            activeThumbColor: TimboColors.ink,
          ),
          SwitchListTile(
            title: Text('Notebook Lines', style: TimboTypography.body),
            value: linesEnabled,
            onChanged: onToggleLines,
            activeThumbColor: TimboColors.ink,
          ),
          ListTile(
            title: Text('Default Font', style: TimboTypography.body),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(defaultFont, style: TextStyle(fontSize: 14, color: TimboColors.inkFaint)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 18, color: TimboColors.inkFaint),
              ],
            ),
            onTap: onFontTap,
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SketchContainer(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Text('Account', style: TimboTypography.heading3.copyWith(fontSize: 16)),
          ),
          ListTile(
            title: Text('Sign Out', style: TimboTypography.body),
            trailing: const Icon(Icons.logout_rounded, size: 18, color: TimboColors.ink),
            onTap: () async {
              await auth.FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/auth');
            },
          ),
          ListTile(
            title: Text('Delete Account', style: TimboTypography.body.copyWith(color: TimboColors.inkLight)),
            trailing: const Icon(Icons.delete_forever_rounded, size: 18, color: TimboColors.inkLight),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text('This cannot be undone. All your data will be permanently deleted.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirmed == true) {
                try {
                  final user = auth.FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.delete();
                    if (context.mounted) context.go('/auth');
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Failed to delete account. Try re-authenticating.'), behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
