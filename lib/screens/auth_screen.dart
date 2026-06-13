import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _submit(bool isSignUp) async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (isSignUp) {
        if (_nameCtrl.text.trim().isEmpty) {
          setState(() => _isLoading = false);
          _showError('Please enter your name');
          return;
        }
        await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = auth.FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(_nameCtrl.text.trim());
        }
      } else {
        await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      final prefs = await ref.read(sharedPrefsProvider.future);
      await prefs.setBool('hasCompletedOnboarding', true);
      if (!mounted) return;
      context.go('/home');
    } on auth.FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication failed');
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn.instance;
      final account = await googleSignIn.authenticate().timeout(const Duration(seconds: 30));
      final authz = account.authentication;
      if (authz.idToken == null) {
        _showError('Google sign-in failed: missing authentication token.');
        return;
      }
      final credential = auth.GoogleAuthProvider.credential(idToken: authz.idToken);
      await auth.FirebaseAuth.instance.signInWithCredential(credential);
      final prefs = await ref.read(sharedPrefsProvider.future);
      await prefs.setBool('hasCompletedOnboarding', true);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _skipLogin() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setBool('hasCompletedOnboarding', true);
    if (!mounted) return;
    context.go('/home');
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: TimboColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TimboColors.appBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.auto_stories_rounded, size: 48, color: TimboColors.ink),
                const SizedBox(height: 8),
                Text(
                  'Timbo',
                  style: TimboTypography.heading1.copyWith(fontSize: 40),
                ),
                const SizedBox(height: 4),
                Text(
                  'your smart notebook',
                  style: TimboTypography.bodySmall.copyWith(color: TimboColors.inkFaint),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: TimboColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TimboColors.ink.withValues(alpha: 0.1)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: TimboColors.ink,
                    unselectedLabelColor: TimboColors.inkFaint,
                    indicator: BoxDecoration(
                      color: TimboColors.ink.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: TimboTypography.body.copyWith(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Sign Up'),
                      Tab(text: 'Log In'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: _tabController.index == 0 ? 360 : 300,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(child: _buildSignUpForm()),
                      SingleChildScrollView(child: _buildLoginForm()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildField(controller: _nameCtrl, hint: 'Your name', icon: Icons.person_outline),
          const SizedBox(height: 14),
          _buildField(controller: _emailCtrl, hint: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _buildField(controller: _passwordCtrl, hint: 'Password', icon: Icons.lock_outline, obscure: true),
          const SizedBox(height: 20),
          _buildPrimaryButton(label: 'Create Account', onTap: () => _submit(true)),
          const SizedBox(height: 16),
          _buildGoogleButton(),
          const SizedBox(height: 12),
          _buildSkipLink(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildField(controller: _emailCtrl, hint: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _buildField(controller: _passwordCtrl, hint: 'Password', icon: Icons.lock_outline, obscure: true),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text('Forgot password?', style: TimboTypography.bodySmall.copyWith(color: TimboColors.inkLight)),
            ),
          ),
          const SizedBox(height: 12),
          _buildPrimaryButton(label: 'Log In', onTap: () => _submit(false)),
          const SizedBox(height: 16),
          _buildGoogleButton(),
          const SizedBox(height: 12),
          _buildSkipLink(),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TimboColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TimboColors.ink.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textInputAction: obscure ? TextInputAction.done : TextInputAction.next,
        style: TimboTypography.body.copyWith(color: TimboColors.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TimboTypography.body.copyWith(color: TimboColors.inkFaint),
          prefixIcon: Icon(icon, size: 18, color: TimboColors.inkLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: TimboColors.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          disabledBackgroundColor: TimboColors.ink.withValues(alpha: 0.4),
        ),
        child: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: TimboTypography.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          foregroundColor: TimboColors.ink,
          side: BorderSide(color: TimboColors.ink.withValues(alpha: 0.15)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.g_mobiledata, size: 22),
            const SizedBox(width: 10),
            Text('Sign in with Google', style: TimboTypography.body.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipLink() {
    return TextButton(
      onPressed: _isLoading ? null : _skipLogin,
      child: Text(
        'Skip for now',
        style: TimboTypography.bodySmall.copyWith(color: TimboColors.inkFaint),
      ),
    );
  }
}
