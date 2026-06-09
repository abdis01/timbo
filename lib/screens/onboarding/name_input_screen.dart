import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/routes.dart';
import '../../models/user_model.dart';
import '../../services/hive_service.dart';
import '../../providers/user_provider.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveName() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final shakeEnabled = prefs.getBool('shake_to_capture_enabled') ?? false;

    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      shakeToCapture: shakeEnabled,
    );

    await HiveService.instance.saveUser(user);
    if (!mounted) return;
    await context.read<UserProvider>().loadUser();

    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
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
              const SizedBox(height: 16),
              Text(
                'Timbo',
                style: TextStyle(fontFamily: 'Satoshi', 
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                "Hi! I'm Timbo.\nWhat should I call you?",
                style: TextStyle(fontFamily: 'Satoshi', 
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(fontFamily: 'Satoshi', 
                  fontSize: 18,
                  color: cs.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle: TextStyle(fontFamily: 'Satoshi', 
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => _saveName(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Let's Go",
                          style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
