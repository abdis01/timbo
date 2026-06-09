import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/reminders_provider.dart';
import '../../models/reminder_model.dart';
import '../../services/notification_service.dart';
import '../../widgets/reminder_card.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/empty_state_widget.dart';
// TODO: Add iOS home screen widget

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReminders());
  }

  Future<void> _loadReminders() async {
    try {
      await context.read<RemindersProvider>().loadReminders();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't load reminders. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Set<DateTime> _reminderDays(RemindersProvider provider) {
    return provider.allReminders
        .where((r) => r.isActive)
        .map((r) => DateTime(r.scheduledAt.year, r.scheduledAt.month, r.scheduledAt.day))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      bottomNavigationBar: const AppBottomNav(activeRoute: AppRoutes.reminders),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Reminders',
            style: TextStyle(fontFamily: 'Satoshi', fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ),
      body: _isLoading
          ? _shimmerList(cs)
          : RefreshIndicator(
              onRefresh: _loadReminders,
              child: Consumer<RemindersProvider>(
              builder: (context, provider, _) {
                final days = _reminderDays(provider);
                final day = _selectedDay ?? DateTime.now();
                final dayReminders = provider.getRemindersForDay(day);
                final upcoming = provider.upcomingReminders.take(5).toList();

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildCalendar(cs, days, provider)),
                    SliverToBoxAdapter(child: _buildDaySection(day, cs)),
                    if (dayReminders.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                          child: Row(
                            children: [
                              Icon(Icons.event_busy_rounded, size: 16,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                              const SizedBox(width: 8),
                              Text('No reminders for this day',
                                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: ReminderCard(
                                reminder: dayReminders[i],
                                onToggleComplete: () => provider.markComplete(dayReminders[i].id),
                                onDelete: () {
                                  provider.deleteReminder(dayReminders[i].id);
                                  try { HapticFeedback.mediumImpact(); } catch (_) {}
                                },
                              ),
                            ),
                            childCount: dayReminders.length,
                          ),
                        ),
                      ),
                    if (upcoming.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                          child: Text('Upcoming',
                              style: TextStyle(fontFamily: 'Satoshi', fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: ReminderCard(
                                reminder: upcoming[i],
                                onToggleComplete: () => provider.markComplete(upcoming[i].id),
                                onDelete: () {
                                  provider.deleteReminder(upcoming[i].id);
                                  try { HapticFeedback.mediumImpact(); } catch (_) {}
                                },
                              ),
                            ),
                            childCount: upcoming.length,
                          ),
                        ),
                      ),
                    ],
                    if (provider.allReminders.isEmpty)
                      SliverToBoxAdapter(child: _buildEmptyState(cs))
                    else
                      const SliverToBoxAdapter(child: SizedBox(height: 96)),
                  ],
                );
              },
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _shimmerList(ColorScheme cs) {
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      highlightColor: cs.surfaceContainerHighest.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(height: 300, decoration: BoxDecoration(
              color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(AppRadius.md),
            )),
            const SizedBox(height: 16),
            Container(height: 20, width: 150, decoration: BoxDecoration(
              color: cs.surfaceContainerHighest, borderRadius: const BorderRadius.all(Radius.circular(4)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return EmptyStateWidget(
      imagePath: 'assets/images/empty_reminders.png',
      message: "You're all clear!\nNo upcoming reminders.",
      action: ElevatedButton.icon(
        onPressed: () => _showAddSheet(),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Add Reminder', style: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildCalendar(ColorScheme cs, Set<DateTime> reminderDays, RemindersProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 0),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 30)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _format,
          selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
          onDaySelected: (selected, focused) {
            setState(() { _selectedDay = selected; _focusedDay = focused; });
          },
          onFormatChanged: (format) => setState(() => _format = format),
          onPageChanged: (focused) => _focusedDay = focused,
          eventLoader: (d) => reminderDays.contains(d) ? [true] : [],
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
            markerDecoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
            defaultTextStyle: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurface),
            weekendTextStyle: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurfaceVariant),
            outsideTextStyle: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            todayTextStyle: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurface),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: TextStyle(fontFamily: 'Satoshi', fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
            formatButtonTextStyle: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: cs.primary),
            formatButtonDecoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            leftChevronIcon: Icon(Icons.chevron_left_rounded, color: cs.onSurfaceVariant),
            rightChevronIcon: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    width: 6, height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF4F8EF7), shape: BoxShape.circle),
                  ),
                );
              }
              return null;
            },
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(fontFamily: 'Satoshi', fontSize: 12, color: cs.onSurfaceVariant),
            weekendStyle: TextStyle(fontFamily: 'Satoshi', fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySection(DateTime day, ColorScheme cs) {
    final now = DateTime.now();
    final isToday = isSameDay(day, now);
    final label = isToday ? 'Today' : DateFormat('EEEE, MMMM d').format(day);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Text(label,
          style: TextStyle(fontFamily: 'Satoshi', fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
    );
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReminderSheet(
        onSaved: () {
          try {
            context.read<RemindersProvider>().loadReminders();
          } catch (_) {}
          try { HapticFeedback.lightImpact(); } catch (_) {}
        },
      ),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddReminderSheet({required this.onSaved});

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String _priority = 'medium';
  bool _isRecurring = false;
  final Set<int> _recurringDays = {};
  String _recurringType = 'weekly';
  bool _isSaving = false;

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final nowMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final scheduledAt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    if (scheduledAt.isBefore(nowMinute)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder time must be in the future')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final reminder = ReminderModel(
        title: title,
        description: _descriptionController.text.trim(),
        scheduledAt: scheduledAt,
        priority: _priority,
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
        recurringDays: _isRecurring ? _recurringDays.toList() : null,
      );

      await context.read<RemindersProvider>().addReminder(reminder);

      await NotificationService.scheduleReminder(
        id: reminder.id,
        title: reminder.title,
        body: reminder.description.isNotEmpty ? reminder.description : 'You have a reminder',
        scheduledAt: scheduledAt,
      );

      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateStr = DateFormat('MMM d, yyyy').format(_date);
    final timeStr = _time.format(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Center(
                  child: Container(width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text('New Reminder',
                    style: TextStyle(fontFamily: 'Satoshi', fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        style: TextStyle(fontFamily: 'Satoshi', fontSize: 16, color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Remind me to...',
                          hintStyle: TextStyle(fontFamily: 'Satoshi', color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          filled: false,
                        ),
                      ),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 2,
                        style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Description (optional)',
                          hintStyle: TextStyle(fontFamily: 'Satoshi', color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            borderSide: BorderSide(color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            borderSide: BorderSide(color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            borderSide: BorderSide(color: cs.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _buildDatePicker(cs, dateStr),
                          const SizedBox(width: 12),
                          _buildTimePicker(cs, timeStr),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Priority',
                          style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      _buildPriorityChips(cs),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Text('Recurring', style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurface)),
                          const Spacer(),
                          Switch(
                            value: _isRecurring,
                            activeThumbColor: cs.primary,
                            onChanged: (v) => setState(() => _isRecurring = v),
                          ),
                        ],
                      ),
                      if (_isRecurring) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: ['daily', 'weekly', 'monthly'].map((f) {
                            final active = _recurringType == f;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _recurringType = f),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: active ? cs.primary.withValues(alpha: 0.15) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                    border: Border.all(
                                      color: active ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(f[0].toUpperCase() + f.substring(1),
                                      style: TextStyle(fontFamily: 'Satoshi', 
                                        fontSize: 13,
                                        color: active ? cs.primary : cs.onSurface,
                                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                      )),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_recurringType == 'weekly') ...[
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: selected ? cs.primary.withValues(alpha: 0.15) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                    border: Border.all(
                                      color: selected ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(_weekDays[i], style: TextStyle(fontFamily: 'Satoshi', 
                                    fontSize: 13,
                                    color: selected ? cs.primary : cs.onSurface,
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                  )),
                                ),
                              );
                            }),
                          ),
                        ],
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Save Reminder', style: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(ColorScheme cs, String dateStr) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Text(dateStr, style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(ColorScheme cs, String timeStr) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: _time);
        if (picked != null) setState(() => _time = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Text(timeStr, style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChips(ColorScheme cs) {
    final priorities = [
      ('low', 'Low', cs.onSurfaceVariant),
      ('medium', 'Medium', context.warningColor),
      ('high', 'High', cs.error),
    ];

    return Row(
      children: priorities.map((p) {
        final active = _priority == p.$1;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _priority = p.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? p.$3.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: active ? p.$3 : cs.onSurface.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8,
                    decoration: BoxDecoration(color: p.$3, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(p.$2, style: TextStyle(fontFamily: 'Satoshi', 
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: active ? p.$3 : cs.onSurface,
                  )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
