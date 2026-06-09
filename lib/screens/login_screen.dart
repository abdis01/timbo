import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../config/routes.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../services/firebase_service.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isSignUp = false;

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (!FirebaseService.instance.isAvailable) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Firebase not available. Try again later.')),
        );
        return;
      }

      if (_isSignUp) {
        await FirebaseService.instance.signUpWithEmail(email, password, email);
      } else {
        await FirebaseService.instance.signInWithEmail(email, password);
      }

      if (!mounted) return;
      await context.read<UserProvider>().loadUser();
      if (!mounted) return;
      final user = context.read<UserProvider>().user;
      if (_isSignUp || user == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.nameInput);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      if (!FirebaseService.instance.isAvailable) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Firebase not available. Try again later.')),
        );
        return;
      }
      final cred = await FirebaseService.instance.signInWithGoogle();
      if (cred == null) return;

      if (!mounted) return;
      await context.read<UserProvider>().loadUser();
      if (!mounted) return;
      final user = context.read<UserProvider>().user;

      if (cred.additionalUserInfo?.isNewUser ?? user == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.nameInput);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _skip() async {
    final user = UserModel(
      id: const Uuid().v4(),
      name: 'Friend',
    );
    await HiveService.instance.saveUser(user);
    if (!mounted) return;
    await context.read<UserProvider>().loadUser();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded, size: 48, color: cs.primary),
              const SizedBox(height: 8),
              Text(
                'Timbo',
                style: TextStyle(fontFamily: 'Satoshi', 
                  fontSize: 32, fontWeight: FontWeight.w700, color: cs.primary,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: cs.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      : Text(_isSignUp ? 'Create Account' : 'Sign In',
                          style: const TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Create one",
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: cs.primary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or',
                        style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 13, color: cs.onSurfaceVariant)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 20,
                    width: 20,
                    errorBuilder: (_, __, ___) => Icon(Icons.login_rounded, color: cs.onSurface),
                  ),
                  label: const Text('Continue with Google',
                      style: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _isLoading ? null : _skip,
                child: Text('Skip for now \u2192',
                    style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 14, color: cs.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
