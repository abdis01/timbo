import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/chat_message.dart';
import '../../services/gemini_service.dart';
import '../../services/premium_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/premium_upgrade_sheet.dart';

class _AnimatedMessage {
  final ChatMessage message;
  final AnimationController controller;
  _AnimatedMessage(this.message, this.controller);
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
  bool _isLoading = false;
  bool _initialized = false;
  Timer? _limitTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initChat());
  }

  Future<void> _initChat() async {
    await GeminiService.instance.initialize();
    if (!mounted) return;
    final user = context.read<UserProvider>().user;
    final name = user?.name ?? 'Friend';
    setState(() {
      _messages.add(_AnimatedMessage(
        ChatMessage(
          content: GeminiService.instance.getWelcomeMessage(name),
          isUser: false,
        ),
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
      ));
      _messages.last.controller.forward();
      _initialized = true;
    });
  }

  @override
  void dispose() {
    for (final m in _messages) {
      m.controller.dispose();
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
    final msg = text.trim();
    if (msg.isEmpty) return;

    if (PremiumService.instance.isAIExhausted()) {
      _showUpgradeSheet();
      return;
    }

    final bool isPremium = context.read<UserProvider>().isPremium;

    if (!isPremium) {
      final remaining = PremiumService.instance.getRemainingInteractions();
      String limitMsg;
      if (remaining <= 0) {
        limitMsg = 'You\'ve used all your free AI conversations today. Upgrade to Premium for unlimited access!';
      } else {
        limitMsg = '$remaining of ${AppConstants.freeAiDailyLimit} conversations remaining today';
      }
      setState(() {
        _messages.add(_AnimatedMessage(
          ChatMessage(content: limitMsg, isUser: false),
          AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
        ));
        _messages.last.controller.forward();
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    setState(() {
      _messages.add(_AnimatedMessage(
        ChatMessage(content: msg, isUser: true),
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
      ));
      _messages.last.controller.forward();
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      await PremiumService.instance.useInteraction();
    } catch (_) {}

    String reply;
    try {
      reply = await GeminiService.instance
          .sendMessage(msg, _messages.map((m) => m.message).toList());
    } catch (_) {
      reply = 'Timbo is thinking... try again in a moment.';
    }

    if (!mounted) return;
    setState(() {
      _messages.add(_AnimatedMessage(
        ChatMessage(content: reply, isUser: false),
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
      ));
      _messages.last.controller.forward();
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
              child: Center(
                child: Text('T',
                    style: GoogleFonts.sora(
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
                    style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
                Text('Your AI Secretary',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildLimitIndicator(cs.onSurfaceVariant),
          Expanded(child: _buildMessageList(cs.onSurface, cs.onSurfaceVariant, cs.primary)),
          _buildInputBar(cs.onSurface, cs.onSurfaceVariant, cs.primary),
        ],
      ),
    );
  }

  Widget _buildLimitIndicator(Color textSecondary) {
    final remaining = PremiumService.instance.getRemainingInteractions();
    final user = context.watch<UserProvider>();
    final isPremium = user.isPremium;

    if (isPremium) return const SizedBox.shrink();

    if (remaining > 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: context.cardColor,
        child: Text(
          '$remaining of ${AppConstants.freeAiDailyLimit} conversations remaining today',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: textSecondary),
        ),
      );
    }

    _limitTimer ??= Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: context.warningColor.withValues(alpha: 0.15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Daily limit reached. Resets in ${PremiumService.instance.getFormattedTimeUntilMidnight()}.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: context.warningColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showUpgradeSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.warningColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Upgrade',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
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
        return AnimatedBuilder(
          animation: animated.controller,
          builder: (context, child) {
            final t = animated.controller.value;
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
              child: Center(
                child: Text('T',
                    style: GoogleFonts.sora(
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
                style: GoogleFonts.inter(
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
            child: Center(
              child: Text('T',
                  style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          _AnimatedTypingDots(),
        ],
      ),
    );
  }

  Widget _buildInputBar(
    Color textPrimary,
    Color textSecondary,
    Color primary,
  ) {
    if (PremiumService.instance.isAIExhausted()) {
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
                'You\'ve used all 5 conversations.',
                style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
              ),
            ),
            GestureDetector(
              onTap: _showUpgradeSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Upgrade',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
              style: GoogleFonts.inter(
                  fontSize: 15, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Ask Timbo anything...',
                hintStyle: GoogleFonts.inter(
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
              child: Icon(Icons.arrow_upward_rounded,
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
    final speech = stt.SpeechToText();
    final available = await speech.initialize();
    if (!available) return;

    await speech.listen(
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
