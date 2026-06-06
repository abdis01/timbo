import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';
import '../config/theme.dart';
import '../models/quick_capture_model.dart';
import '../models/expense_model.dart';
import '../models/reminder_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../services/premium_service.dart';
import '../providers/finance_provider.dart';
import '../providers/reminders_provider.dart';
import '../providers/notes_provider.dart';

enum CaptureCategory { note, expense, reminder, photo, voice }

class QuickCapturePopup extends StatefulWidget {
  const QuickCapturePopup({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickCapturePopup(),
    );
  }

  @override
  State<QuickCapturePopup> createState() => _QuickCapturePopupState();
}

class _QuickCapturePopupState extends State<QuickCapturePopup>
    with SingleTickerProviderStateMixin {
  CaptureCategory _selectedCategory = CaptureCategory.note;

  // NOTE fields
  final _noteController = TextEditingController();

  // EXPENSE fields
  final _amountController = TextEditingController();
  bool _isIncome = false;
  String _expenseCategory = 'Food';
  final _descriptionController = TextEditingController();
  String? _receiptPath;

  // REMINDER fields
  final _reminderTitleController = TextEditingController();
  DateTime _reminderDate = DateTime.now();
  TimeOfDay _reminderTime = TimeOfDay.now();
  bool _isRecurring = false;
  final Set<int> _recurringDays = {};

  // PHOTO fields
  String? _photoPath;
  final _photoCaptionController = TextEditingController();
  bool _saveToGallery = true;

  // VOICE fields
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _voiceTranscript = '';
  final _voiceNoteController = TextEditingController();
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  // AI suggestion
  String? _suggestedCategory;
  bool _aiSuggestionLoading = false;
  bool _aiSuggestionAccepted = false;

  // Save state
  bool _isSaving = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final _picker = ImagePicker();

  static const _expenseCategories = [
    'Food',
    'Transport',
    'Entertainment',
    'Health',
    'Shopping',
    'Other',
  ];

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _reminderTitleController.dispose();
    _photoCaptionController.dispose();
    _voiceNoteController.dispose();
    _recordingTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  void _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file != null) {
      setState(() => _photoPath = file.path);
    }
  }

  void _startVoiceRecording() async {
    _speech ??= stt.SpeechToText();
    final available = await _speech!.initialize();
    if (!available) return;

    setState(() {
      _isListening = true;
      _recordingSeconds = 0;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordingSeconds++);
    });

    await _speech!.listen(
      onResult: (result) {
        setState(() => _voiceTranscript = result.recognizedWords);
      },
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopVoiceRecording() {
    _speech?.stop();
    _recordingTimer?.cancel();
    setState(() {
      _isListening = false;
      _voiceNoteController.text = _voiceTranscript;
    });
  }

  Future<void> _suggestCategory() async {
    if (_aiSuggestionLoading) return;
    if (!PremiumService.instance.canUseAI()) return;

    setState(() => _aiSuggestionLoading = true);

    try {
      await PremiumService.instance.useInteraction();
      setState(() {
        _suggestedCategory = 'Personal';
      });
    } catch (_) {}

    setState(() => _aiSuggestionLoading = false);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();

      switch (_selectedCategory) {
        case CaptureCategory.note:
          final content = _noteController.text.trim();
          if (content.isEmpty) {
            _showError('Write something first');
            return;
          }
          final note = QuickCaptureModel(
            type: 'text',
            content: content,
            capturedAt: now,
          );
          await HiveService.instance.saveCapture(note);
          await context.read<NotesProvider>().loadNotes();

        case CaptureCategory.expense:
          final amountText = _amountController.text.trim();
          if (amountText.isEmpty) {
            _showError('Enter an amount');
            return;
          }
          final amount = double.tryParse(amountText);
          if (amount == null || amount <= 0) {
            _showError('Enter a valid amount');
            return;
          }
          final expense = ExpenseModel(
            amount: amount,
            type: _isIncome ? 'income' : 'expense',
            category: _expenseCategory,
            description: _descriptionController.text.trim(),
            date: now,
            receiptImagePath: _receiptPath,
          );
          await HiveService.instance.saveExpense(expense);
          await context.read<FinanceProvider>().loadFinanceData();

          final capture = QuickCaptureModel(
            type: 'expense',
            content: '${_isIncome ? 'Income' : 'Expense'}: \$${amount.toStringAsFixed(2)} - $_expenseCategory',
            amount: amount,
            category: _expenseCategory,
            capturedAt: now,
          );
          await HiveService.instance.saveCapture(capture);

        case CaptureCategory.reminder:
          final title = _reminderTitleController.text.trim();
          if (title.isEmpty) {
            _showError('Enter a reminder title');
            return;
          }
          final scheduledAt = DateTime(
            _reminderDate.year,
            _reminderDate.month,
            _reminderDate.day,
            _reminderTime.hour,
            _reminderTime.minute,
          );
          if (scheduledAt.isBefore(now)) {
            _showError('Reminder time must be in the future');
            return;
          }
          final reminder = ReminderModel(
            title: title,
            scheduledAt: scheduledAt,
            isRecurring: _isRecurring,
            recurringDays: _isRecurring ? _recurringDays.toList() : null,
          );
          await HiveService.instance.saveReminder(reminder);
          await context.read<RemindersProvider>().loadReminders();
          await NotificationService.showInstantNotification(
            title: 'Reminder: $title',
            body: 'You have a reminder scheduled',
          );

          final capture = QuickCaptureModel(
            type: 'reminder',
            content: 'Reminder: $title',
            capturedAt: now,
          );
          await HiveService.instance.saveCapture(capture);

        case CaptureCategory.photo:
          final path = _photoPath;
          if (path == null) {
            _showError('Take a photo first');
            return;
          }
          final capture = QuickCaptureModel(
            type: 'photo',
            content: _photoCaptionController.text.trim(),
            mediaPath: path,
            capturedAt: now,
          );
          await HiveService.instance.saveCapture(capture);

        case CaptureCategory.voice:
          final content = _voiceNoteController.text.trim();
          if (content.isEmpty) {
            _showError('Record something first');
            return;
          }
          final capture = QuickCaptureModel(
            type: 'voice',
            content: content,
            capturedAt: now,
          );
          await HiveService.instance.saveCapture(capture);
      }

      try {
        await Vibration.vibrate(duration: 50);
      } catch (_) {}

      if (!mounted) return;
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved \u2713',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: context.primaryColor,
          duration: const Duration(seconds: 1),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      _showError('Failed to save');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: context.dangerColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;
    final primary = cs.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: Column(
            children: [
              _buildDragHandle(isDark),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategorySelector(primary, textPrimary, isDark),
                        const SizedBox(height: AppSpacing.lg),
                        _buildDynamicContent(
                          primary, textPrimary, textSecondary, isDark),
                        const SizedBox(height: AppSpacing.md),
                        _buildAiSuggestion(
                          primary, textPrimary, textSecondary, isDark),
                        const SizedBox(height: AppSpacing.md),
                        _buildBottomActionBar(primary, textSecondary, isDark),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: context.textSecondaryColor.withValues(alpha: isDark ? 0.4 : 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(
    Color primary,
    Color textPrimary,
    bool isDark,
  ) {
    final categories = [
      (CaptureCategory.note, Icons.edit_note_rounded, 'Note'),
      (CaptureCategory.expense, Icons.account_balance_rounded, 'Expense'),
      (CaptureCategory.reminder, Icons.notifications_rounded, 'Reminder'),
      (CaptureCategory.photo, Icons.camera_alt_rounded, 'Photo'),
      (CaptureCategory.voice, Icons.mic_rounded, 'Voice'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (i) {
          final cat = categories[i];
          final isSelected = _selectedCategory == cat.$1;
          return Padding(
            padding: EdgeInsets.only(right: i < categories.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = cat.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.15)
                      : context.cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isSelected
                        ? primary
                        : context.textSecondaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.$2,
                        size: 18,
                        color: isSelected ? primary : textPrimary),
                    const SizedBox(width: 6),
                    Text(
                      cat.$3,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? primary : textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDynamicContent(
    Color primary,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    switch (_selectedCategory) {
      case CaptureCategory.note:
        return _buildNoteForm(primary, textPrimary, textSecondary, isDark);
      case CaptureCategory.expense:
        return _buildExpenseForm(primary, textPrimary, textSecondary, isDark);
      case CaptureCategory.reminder:
        return _buildReminderForm(primary, textPrimary, textSecondary, isDark);
      case CaptureCategory.photo:
        return _buildPhotoForm(primary, textPrimary, textSecondary, isDark);
      case CaptureCategory.voice:
        return _buildVoiceForm(primary, textPrimary, textSecondary, isDark);
    }
  }

  Widget _buildNoteForm(
    Color primary,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _noteController,
          maxLines: 6,
          minLines: 3,
          style: GoogleFonts.inter(fontSize: 16, color: textPrimary),
          decoration: InputDecoration(
            hintText: "What's on your mind?",
            hintStyle: GoogleFonts.inter(color: textSecondary.withValues(alpha: 0.5)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            filled: false,
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (_noteController.text.isNotEmpty && _suggestedCategory == null)
          GestureDetector(
            onTap: _suggestCategory,
            child: Row(
              children: [
                if (_aiSuggestionLoading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(Icons.auto_awesome_rounded,
                      size: 14, color: primary.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Text(
                  'Suggest category',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildExpenseForm(
    Color primary,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '\$',
              style: GoogleFonts.sora(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.sora(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: GoogleFonts.sora(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textSecondary.withValues(alpha: 0.3),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _buildToggleChip('Expense', !_isIncome, primary, textPrimary, isDark),
            const SizedBox(width: 8),
            _buildToggleChip('Income', _isIncome, primary, textPrimary, isDark),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Category',
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textSecondary)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _expenseCategories.map((cat) {
            final selected = _expenseCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _expenseCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: selected
                        ? primary
                        : textSecondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: selected ? primary : textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _descriptionController,
          maxLines: 2,
          style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Description (optional)',
            hintStyle: GoogleFonts.inter(
                color: textSecondary.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(
                  color: textSecondary.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(
                  color: textSecondary.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => _pickImage(ImageSource.camera),
          child: Row(
            children: [
              Icon(Icons.receipt_rounded,
                  size: 18, color: textSecondary),
              const SizedBox(width: 6),
              Text(
                _receiptPath != null ? 'Receipt added' : 'Add receipt photo',
                style: GoogleFonts.inter(
                    fontSize: 13, color: textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip(
    String label,
    bool selected,
    Color primary,
    Color textPrimary,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() => _isIncome = label == 'Income');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.15)
              : context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected
                ? primary
                : textPrimary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? primary : textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildReminderForm(
    Color primary,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final dateStr = DateFormat('MMM d, yyyy').format(_reminderDate);
    final timeStr = _reminderTime.format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _reminderTitleController,
          style: GoogleFonts.inter(fontSize: 16, color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Remind me to...',
            hintStyle: GoogleFonts.inter(
                color: textSecondary.withValues(alpha: 0.5)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            filled: false,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _buildDatePicker(primary, textPrimary, dateStr, isDark, textSecondary),
            const SizedBox(width: 12),
            _buildTimePicker(primary, textPrimary, timeStr, isDark, textSecondary),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text('Recurring',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textPrimary)),
            const Spacer(),
            Switch(
              value: _isRecurring,
              activeColor: primary,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
          ],
        ),
        if (_isRecurring) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 6,
            children: List.generate(7, (i) {
              final selected = _recurringDays.contains(i);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _recurringDays.remove(i);
                    } else {
                      _recurringDays.add(i);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: selected
                          ? primary
                          : textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _weekDays[i],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: selected ? primary : textPrimary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildDatePicker(
    Color primary,
    Color textPrimary,
    String dateStr,
    bool isDark,
    Color textSecondary,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _reminderDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _reminderDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 16, color: primary),
            const SizedBox(width: 8),
            Text(dateStr,
                style: GoogleFonts.inter(
                    fontSize: 14, color: textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    Color primary,
    Color textPrimary,
    String timeStr,
    bool isDark,
    Color textSecondary,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _reminderTime,
        );
        if (picked != null) setState(() => _reminderTime = picked);
      },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time_rounded,
                size: 16, color: primary),
            const SizedBox(width: 8),
            Text(timeStr,
                style: GoogleFonts.inter(
                    fontSize: 14, color: textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoForm(
    Color primary,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    if (_photoPath == null) {
      return Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: textSecondary.withValues(alpha: 0.2),
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded,
                      size: 48, color: textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text('Tap to open camera',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: textSecondary)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Text('Or pick from gallery',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: primary,
                            decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Image.file(
            File(_photoPath!),
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _photoPath = null),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: textSecondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        size: 14, color: textSecondary),
                    const SizedBox(width: 4),
                    Text('Retake',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: textSecondary)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Text('Save to gallery',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: textSecondary)),
                const SizedBox(width: 4),
                Switch(
                  value: _saveToGallery,
                  activeColor: primary,
                  onChanged: (v) => setState(() => _saveToGallery = v),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _photoCaptionController,
          style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Add a caption...',
            hintStyle: GoogleFonts.inter(
                color: textSecondary.withValues(alpha: 0.5)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            filled: false,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceForm(
    Color primary,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    if (_isListening) {
      return Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.dangerColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.mic_rounded,
                    size: 48, color: context.dangerColor),
                onPressed: _stopVoiceRecording,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
              child: Text(
                'Tap to stop',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: context.dangerColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              _formatDuration(_recordingSeconds),
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: textPrimary,
              ),
            ),
          ),
          if (_voiceTranscript.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                _voiceTranscript,
                style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: GestureDetector(
            onTap: _startVoiceRecording,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mic_rounded,
                  size: 48, color: primary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            'Tap to start recording',
            style: GoogleFonts.inter(
                fontSize: 14, color: textSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _voiceNoteController,
          maxLines: 3,
          style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Or type the note manually...',
            hintStyle: GoogleFonts.inter(
                color: textSecondary.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(
                  color: textSecondary.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(
                  color: textSecondary.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildAiSuggestion(
    Color primary,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    if (_suggestedCategory == null || _aiSuggestionAccepted) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: 16, color: primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Timbo thinks: ',
                style: GoogleFonts.inter(
                    fontSize: 13, color: textSecondary),
                children: [
                  TextSpan(
                    text: _suggestedCategory,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const TextSpan(text: ' \u2014 correct?'),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _aiSuggestionAccepted = true),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text('Yes',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _suggestedCategory = null),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: textSecondary.withValues(alpha: 0.4)),
              ),
              child: Text('No',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: textSecondary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    Color primary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? context.cardColor.withValues(alpha: 0.5)
            : context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _actionIcon(Icons.mic_rounded, 'Voice', () {
                setState(() => _selectedCategory = CaptureCategory.voice);
              }, textSecondary),
              const SizedBox(width: 16),
              _actionIcon(Icons.camera_alt_rounded, 'Camera', () {
                if (_selectedCategory == CaptureCategory.photo) {
                  _pickImage(ImageSource.camera);
                } else {
                  setState(() => _selectedCategory = CaptureCategory.photo);
                }
              }, textSecondary),
              const SizedBox(width: 16),
              _actionIcon(Icons.photo_library_rounded, 'Gallery', () {
                _pickImage(ImageSource.gallery);
              }, textSecondary),
            ],
          ),
          GestureDetector(
            onTap: _isSaving ? null : _save,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _isSaving ? primary.withValues(alpha: 0.5) : primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(
    IconData icon,
    String label,
    VoidCallback onTap,
    Color textSecondary,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: textSecondary),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }
}
