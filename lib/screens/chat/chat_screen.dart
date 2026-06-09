import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/chat_message.dart';
import '../../services/gemini_service.dart';
import '../../services/premium_service.dart';
import '../../services/firebase_service.dart';
import '../../services/hive_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/premium_upgrade_sheet.dart';
import '../../widgets/retry_widget.dart';

class _AnimatedMessage {
  final ChatMessage message;
  final AnimationController? controller;
  final bool isWelcome;
  _AnimatedMessage(this.message, this.controller, {this.isWelcome = false});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final _messages = <_AnimatedMessage>[];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _speech = stt.SpeechToText();
  bool _isLoading = false;
  bool _initialized = false;
  bool _hasError = false;
  Timer? _limitTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initChat());
  }

  Future<void> _initChat() async {
    try {
      await GeminiService.instance.initialize();
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
      return;
    }
    if (!mounted) return;
    final user = context.read<UserProvider>().user;
    final name = user?.name ?? 'Friend';

    final history = HiveService.instance.getChatHistory();
    setState(() {
      for (final msg in history) {
        _messages.add(_AnimatedMessage(msg, null));
      }
      final welcomeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
      _messages.add(_AnimatedMessage(
        ChatMessage(
          content: GeminiService.instance.getWelcomeMessage(name),
          isUser: false,
        ),
        welcomeCtrl,
        isWelcome: true,
      ));
      _messages.last.controller?.forward();
      _initialized = true;
    });
  }

  @override
  void dispose() {
    for (final m in _messages) {
      m.controller?.dispose();
    }
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _limitTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    HapticFeedback.lightImpact();
    final msg = text.trim();
    if (msg.isEmpty) return;

    if (PremiumService.instance.isAIExhausted()) {
      final exhaustedMsg = PremiumService.instance.isPremium()
          ? 'Daily limit reached. Come back tomorrow!'
          : 'Daily limit reached. Upgrade to Premium for \$${AppConstants.premiumPrice.toStringAsFixed(2)}/month!';
      setState(() {
        _messages.add(_AnimatedMessage(
          ChatMessage(content: exhaustedMsg, isUser: false),
          AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
        ));
        _messages.last.controller?.forward();
      });
      _scrollToBottom();
      return;
    }

    final userMsg = ChatMessage(content: msg, isUser: true);
    await HiveService.instance.saveChatMessage(userMsg);

    setState(() {
      _messages.add(_AnimatedMessage(
        userMsg,
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
      ));
      _messages.last.controller?.forward();
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    String reply;
    try {
      reply = await GeminiService.instance
          .sendMessage(msg, _messages.where((m) => !m.isWelcome).map((m) => m.message).toList());
      await PremiumService.instance.useInteraction();
    } catch (_) {
      reply = 'Timbo is thinking... try again in a moment.';
    }

    if (!mounted) return;
    final aiMsg = ChatMessage(content: reply, isUser: false);
    await HiveService.instance.saveChatMessage(aiMsg);

    setState(() {
      _messages.add(_AnimatedMessage(
        aiMsg,
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
      ));
      _messages.last.controller?.forward();
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('T',
                    style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Timbo',
                    style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
                Text('Your AI Secretary',
                    style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(cs.onSurface, cs.onSurfaceVariant, cs.primary)),
          _buildInputBar(cs.onSurface, cs.onSurfaceVariant, cs.primary),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    Color textPrimary,
    Color textSecondary,
    Color primary,
  ) {
    if (!_initialized) {
      if (_hasError && _messages.isEmpty) {
        return RetryWidget(
          message: 'Timbo is thinking... try again in a moment.',
          onRetry: () {
            setState(() {
              _hasError = false;
              _initialized = false;
            });
            _initChat();
          },
        );
      }
      return Center(
        child: CircularProgressIndicator(color: primary),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _messages.length && _isLoading) {
          return _buildTypingIndicator();
        }

        final animated = _messages[i];
        final ctrl = animated.controller;
        final bubble = ctrl == null
            ? _buildBubble(animated.message, textPrimary, textSecondary, primary)
            : AnimatedBuilder(
                animation: ctrl,
                builder: (context, child) {
                  final t = ctrl.value;
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 20.0 * (1.0 - Curves.easeOutCubic.transform(t))),
                      child: child,
                    ),
                  );
                },
                child: _buildBubble(animated.message, textPrimary, textSecondary, primary),
              );
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Container(
            key: ValueKey('msg_${i}_${animated.message.hashCode}'),
            child: bubble,
          ),
        );
      },
    );
  }

  Widget _buildBubble(
    ChatMessage msg,
    Color textPrimary,
    Color textSecondary,
    Color primary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('T',
                    style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? primary
                    : context.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: msg.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: msg.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                msg.content,
                style: TextStyle(fontFamily: 'Satoshi', 
                  fontSize: 14,
                  height: 1.4,
                  color: msg.isUser ? Colors.white : textPrimary,
                ),
              ),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: context.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
                child: Text('T',
                    style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            const _AnimatedTypingDots(),
        ],
      ),
    );
  }

  Widget _buildInputBar(
    Color textPrimary,
    Color textSecondary,
    Color primary,
  ) {
    if (!FirebaseService.instance.isLoggedIn) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
        ),
        child: Row(
          children: [
            Icon(Icons.lock_rounded, size: 18, color: textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sign in to chat with Timbo AI',
                style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.login);
              },
              child: Text('Sign In',
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: primary)),
            ),
          ],
        ),
      );
    }

    if (PremiumService.instance.isAIExhausted()) {
      final exhaustedMsg = PremiumService.instance.isPremium()
          ? 'Daily limit reached. Come back tomorrow!'
          : 'Daily limit reached. Get Timbo Premium for \$${AppConstants.premiumPrice.toStringAsFixed(2)}/month!';
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
        ),
        child: Row(
          children: [
            Icon(Icons.block_rounded, size: 18, color: textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                exhaustedMsg,
                style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: textSecondary),
              ),
            ),
            if (!PremiumService.instance.isPremium())
              TextButton(
                onPressed: _showUpgradeSheet,
                child: Text('Upgrade',
                    style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: primary)),
              ),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _startVoiceInput,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.mic_rounded,
                  size: 20, color: textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              style: TextStyle(fontFamily: 'Satoshi', 
                  fontSize: 15, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Ask Timbo anything...',
                hintStyle: TextStyle(fontFamily: 'Satoshi', 
                    color: textSecondary.withValues(alpha: 0.5)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 10),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (v) => _sendMessage(v),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _sendMessage(_textController.text),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_upward_rounded,
                  size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PremiumUpgradeSheet(
        onJoinWaitlist: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You\'re on the waitlist! We\'ll notify you.')),
          );
        },
      ),
    );
  }

  void _startVoiceInput() async {
    if (kIsWeb) {
      return;
    }
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    final available = await _speech.initialize();
    if (!available) {
      return;
    }

    await _speech.listen(
      onResult: (result) {
        _textController.text = result.recognizedWords;
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
    );
  }
}

class _AnimatedTypingDots extends StatefulWidget {
  const _AnimatedTypingDots();

  @override
  State<_AnimatedTypingDots> createState() => _AnimatedTypingDotsState();
}

class _AnimatedTypingDotsState extends State<_AnimatedTypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.textSecondaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = ((_controller.value * 3 - i) % 1.0).clamp(0.0, 1.0);
              final scale = 0.5 + 0.5 * Curves.easeInOut.transform(t);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
