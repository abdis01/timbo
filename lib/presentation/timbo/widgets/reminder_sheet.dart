import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/reminder_service.dart';
import '../../../providers/timbos_provider.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

class ReminderSheet extends ConsumerStatefulWidget {
  final int timboId;
  final bool reminderSet;
  final int? reminderTimestamp;
  final String? reminderLabel;

  const ReminderSheet({
    super.key,
    required this.timboId,
    required this.reminderSet,
    this.reminderTimestamp,
    this.reminderLabel,
  });

  @override
  ConsumerState<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<ReminderSheet> {
  late DateTime _date;
  late TimeOfDay _time;
  String _repeat = 'None';

  @override
  void initState() {
    super.initState();
    if (widget.reminderSet && widget.reminderTimestamp != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(widget.reminderTimestamp!);
      _date = dt;
      _time = TimeOfDay.fromDateTime(dt);
    } else {
      _date = DateTime.now().add(const Duration(hours: 1));
      _time = const TimeOfDay(hour: 18, minute: 0);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: TimboColors.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: TimboColors.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _setReminder() async {
    final scheduledAt = DateTime(
      _date.year, _date.month, _date.day, _time.hour, _time.minute,
    );
    if (scheduledAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a future time.')),
      );
      return;
    }

    final label = '${_date.month}/${_date.day} ${_time.format(context)}';
    final repo = ref.read(timboRepositoryProvider);
    await repo.setReminder(widget.timboId, scheduledAt.millisecondsSinceEpoch, label);

    await ReminderService.instance.scheduleReminder(
      id: widget.timboId,
      title: 'Timbo Reminder',
      body: widget.reminderLabel ?? 'You have a Timbo reminder!',
      scheduledAt: scheduledAt,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder set!')),
      );
    }
  }

  Future<void> _removeReminder() async {
    final repo = ref.read(timboRepositoryProvider);
    await repo.clearReminder(widget.timboId);

    await ReminderService.instance.cancelReminder(widget.timboId);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder removed.')),
      );
    }
  }

  String _formatDate(DateTime d) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: TimboColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Set a Reminder', style: TimboTypography.heading2),
              const SizedBox(height: 20),
              _Row(label: 'Date', value: _formatDate(_date), onTap: _pickDate),
              _divider(),
              _Row(label: 'Time', value: _time.format(context), onTap: _pickTime),
              _divider(),
              _Row(
                label: 'Repeat',
                value: _repeat,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: ['None', 'Daily', 'Weekly'].map((r) {
                          return ListTile(
                            title: Text(r),
                            trailing: _repeat == r
                                ? const Icon(Icons.check, size: 18)
                                : null,
                            onTap: () {
                              setState(() => _repeat = r);
                              Navigator.pop(ctx);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _setReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TimboColors.ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text('Set Reminder', style: TimboTypography.button),
              ),
              if (widget.reminderSet) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _removeReminder,
                  child: Text(
                    'Remove Reminder',
                    style: TimboTypography.body.copyWith(color: TimboColors.inkLight),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Divider(color: TimboColors.borderLight, height: 1, thickness: 1),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _Row({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(label, style: TimboTypography.body.copyWith(fontSize: 14, color: TimboColors.inkLight)),
            const Spacer(),
            Row(
              children: [
                Text(value, style: TimboTypography.heading3.copyWith(fontSize: 16)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 18, color: TimboColors.ink),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
