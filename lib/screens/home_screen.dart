import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import '../providers/providers.dart';
import '../database/database.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _inputCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _audioRecorder = AudioRecorder();
  Timer? _placeholderTimer;
  int _placeholderIndex = 0;
  late AnimationController _glowController;

  final _placeholders = [
    "What's on your mind?",
    'Any expenses today?',
    'Need a reminder?',
  ];

  final _typePills = ['note', 'expense', 'reminder'];
  String? _selectedPill;
  DateTime? _reminderDate;
  double? _expenseAmount;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _startPlaceholderCycle();
  }

  void _startPlaceholderCycle() {
    _placeholderTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() => _placeholderIndex = (_placeholderIndex + 1) % _placeholders.length);
      }
    });
  }

  void _onSend() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();

    final isOnline = ref.read(isOnlineProvider);
    final service = ref.read(captureServiceProvider);

    Capture capture;
    if (_selectedPill != null || !isOnline) {
      capture = await service.processAndSave(
        rawInput: text,
        type: _selectedPill ?? 'note',
        amount: _expenseAmount,
        scheduledAt: _reminderDate,
        isOnline: false,
      );
    } else {
      capture = await service.processAndSave(
        rawInput: text,
        isOnline: true,
      );
    }

    setState(() => _selectedPill = null);
    _showCheckAnimation();
  }

  void _showCheckAnimation() {
    _glowController.forward().then((_) => _glowController.reverse());
  }

  void _onMicTap() async {
    final isRecording = ref.read(isRecordingProvider);
    if (isRecording) {
      final path = await _audioRecorder.stop();
      ref.read(isRecordingProvider.notifier).state = false;
      if (path != null) {
        _inputCtrl.text = 'Voice note recorded';
      }
    } else {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) return;
      await _audioRecorder.start(const RecordConfig(), path: '');
      ref.read(isRecordingProvider.notifier).state = true;
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _focusNode.dispose();
    _placeholderTimer?.cancel();
    _glowController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isOnline = ref.watch(isOnlineProvider);
    final greeting = ref.watch(userGreetingProvider);
    const date = 'Tuesday, June 9';
    final summary = ref.watch(dailySummaryProvider);
    final recentCaptures = ref.watch(recentCapturesProvider).valueOrNull ?? [];
    final isRecording = ref.watch(isRecordingProvider);
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            if (!isOnline)
              _OfflineBanner(),
            _TopBar(cs: cs),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 16),
                  Text('$greeting, $userName', style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 4),
                  Text(date, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 20),
                  _DailySummaryCard(cs: cs, summary: summary),
                  const SizedBox(height: 20),
                  if (recentCaptures.isNotEmpty) ...[
                    Text('Recent', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentCaptures.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => _RecentPill(capture: recentCaptures[i], cs: cs),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildInputBar(cs, isOnline, isRecording),
    );
  }

  Widget _buildInputBar(ColorScheme cs, bool isOnline, bool isRecording) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOnline) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _typePills.map((type) {
                final selected = _selectedPill == type;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedPill = selected ? null : type;
                    if (type == 'reminder') _reminderDate = DateTime.now().add(const Duration(hours: 1));
                    if (type == 'expense') _expenseAmount = 0;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: selected ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      type == 'note' ? '📝 Note' : type == 'expense' ? '💰 Expense' : '🔔 Reminder',
                      style: TextStyle(
                        fontSize: 13,
                        color: selected ? cs.primary : cs.onSurfaceVariant,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: _glowController.value > 0
                      ? [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: _glowController.value * 0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: isRecording ? Colors.red : cs.primary,
                        ),
                        onPressed: _onMicTap,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _inputCtrl,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: _placeholders[_placeholderIndex],
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _onSend(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_upward_rounded),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: cs.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: _onSend,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              );
            },
          ),
          if (!isOnline && _selectedPill == 'reminder') ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: DatePickerDialog(
                initialDate: _reminderDate ?? DateTime.now().add(const Duration(hours: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              ),
            ),
          ],
          if (!isOnline && _selectedPill == 'expense') ...[
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Amount',
                prefixText: 'TZS ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _expenseAmount = double.tryParse(v),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Food', 'Transport', 'Entertainment', 'Health', 'Shopping', 'Other'].map((cat) {
                return ChoiceChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  selected: false,
                  onSelected: (_) {},
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 6),
      color: Colors.orange.shade800,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Text(
            "You're offline — manual mode",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final ColorScheme cs;
  const _TopBar({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.bolt_rounded, color: cs.primary, size: 28),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: cs.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person_rounded, color: cs.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  final ColorScheme cs;
  final AsyncValue<String> summary;
  const _DailySummaryCard({required this.cs, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD700), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: summary.when(
                data: (text) => Text(text, style: Theme.of(context).textTheme.bodyLarge),
                loading: () => Text(
                  'Loading...',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                error: (_, __) => Text(
                  'Ready when you are. Start capturing below.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPill extends StatelessWidget {
  final Capture capture;
  final ColorScheme cs;
  const _RecentPill({required this.capture, required this.cs});

  @override
  Widget build(BuildContext context) {
    final icon = capture.type == 'expense' ? '💰' : capture.type == 'reminder' ? '🔔' : '📝';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/vault'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              capture.content.length > 20
                  ? '${capture.content.substring(0, 20)}...'
                  : capture.content,
              style: TextStyle(fontSize: 13, color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
