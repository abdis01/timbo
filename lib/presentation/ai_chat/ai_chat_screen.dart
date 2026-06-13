import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../core/widgets/sketch_container.dart';
import '../../core/painters/sketch_border_painter.dart';
import 'ai_chat_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _speech.stop();
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _toggleListening() {
    if (!_speechAvailable) return;
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      _speech.listen(
        onResult: (result) {
          _inputController.text = result.recognizedWords;
          if (result.finalResult) {
            _sendMessage(result.recognizedWords);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
      setState(() => _isListening = true);
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref.read(aiChatProvider.notifier).sendMessage(text);
    _inputController.clear();
    _inputFocus.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiChatProvider);
    final messages = state.messages;
    final isLoading = state.isLoading;
    final isOffline = state.isOffline;
    final hasMessages = messages.isNotEmpty || isLoading;

    return Scaffold(
      backgroundColor: TimboColors.appBackground,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: TimboColors.appBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: TimboColors.appBackground,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TimboColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text('Timbo AI', style: TimboTypography.heading3),
        actions: [
          if (hasMessages)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: TimboColors.ink),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear chat?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                    ],
                  ),
                );
                if (confirmed == true) ref.read(aiChatProvider.notifier).clearChat();
              },
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (isOffline)
              Container(
                width: double.infinity,
                color: Colors.orange.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'AI needs internet to think. You are offline.',
                      style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: hasMessages ? _buildChatList(messages, isLoading) : _buildEmptyState(),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(80, 80),
              painter: _NotebookPainter(),
            ),
            const SizedBox(height: 20),
            Text('Hey! Ask me anything or just chat.', style: TimboTypography.heading2),
            const SizedBox(height: 8),
            Text(
              "I have read your notes. Let's talk.",
              style: TimboTypography.body.copyWith(color: TimboColors.inkLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _SuggestionChip(
              label: 'What did I write yesterday?',
              onTap: () => _sendMessage('What did I write yesterday?'),
            ),
            const SizedBox(height: 8),
            _SuggestionChip(
              label: 'Set a reminder for tomorrow at 9am',
              onTap: () => _sendMessage('Set a reminder for tomorrow at 9am'),
            ),
            const SizedBox(height: 8),
            _SuggestionChip(
              label: 'Summarize this week for me',
              onTap: () => _sendMessage('Summarize this week for me'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(List<dynamic> messages, bool isLoading) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (ctx, index) {
        if (isLoading && index == messages.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _TypingIndicator(),
          );
        }
        final msg = messages[index];
        final isUser = msg.role == 'user';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(Icons.edit_note, size: 14, color: TimboColors.inkFaint),
                ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  child: CustomPaint(
                    painter: SketchBorderPainter(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? TimboColors.ink : TimboColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        msg.content,
                        style: isUser
                            ? TimboTypography.button.copyWith(color: Colors.white, fontSize: 15)
                            : TimboTypography.body,
                        softWrap: true,
                      ),
                    ),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 4),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return CustomPaint(
      painter: _TopBorderPainter(),
      child: Container(
        color: TimboColors.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleListening,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 20,
                    color: _isListening ? Colors.red : TimboColors.inkFaint,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _inputFocus,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: 'Ask Timbo AI...',
                      hintStyle: TimboTypography.body.copyWith(color: TimboColors.inkFaint),
                    ),
                    style: TimboTypography.body,
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_inputController.text),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: TimboColors.ink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SketchContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        onTap: onTap,
        child: Text(label, style: TimboTypography.body.copyWith(fontSize: 13)),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Icon(Icons.edit_note, size: 14, color: TimboColors.inkFaint),
        ),
        CustomPaint(
          painter: SketchBorderPainter(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: TimboColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _BouncingDot(index: i)),
            ),
          ),
        ),
      ],
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int index;
  const _BouncingDot({required this.index});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final delay = widget.index * 200;
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          delay / 600.0,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );
    Future.delayed(Duration(milliseconds: delay), () => _controller.forward());
    _controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) _controller.reverse();
      if (s == AnimationStatus.dismissed) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: TimboColors.inkLight,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _NotebookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TimboColors.ink.withValues(alpha: 0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final mid = w / 2;

    final path = Path();
    path.moveTo(mid, h * 0.15);
    path.lineTo(mid, h * 0.85);

    canvas.drawLine(Offset(mid, h * 0.15), Offset(mid, h * 0.85), paint);

    paint.strokeWidth = 1.5;

    final left = Path();
    left.moveTo(mid, h * 0.15);
    left.quadraticBezierTo(mid * 0.3, h * 0.1, w * 0.1, h * 0.3);
    left.quadraticBezierTo(0, h * 0.5, w * 0.1, h * 0.7);
    left.quadraticBezierTo(mid * 0.3, h * 0.9, mid, h * 0.85);
    canvas.drawPath(left, paint);

    final right = Path();
    right.moveTo(mid, h * 0.15);
    right.quadraticBezierTo(mid * 1.7, h * 0.1, w * 0.9, h * 0.3);
    right.quadraticBezierTo(w, h * 0.5, w * 0.9, h * 0.7);
    right.quadraticBezierTo(mid * 1.7, h * 0.9, mid, h * 0.85);
    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _TopBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TimboColors.border
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
