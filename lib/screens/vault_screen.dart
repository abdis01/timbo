import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../database/database.dart';
import '../database/captures_table.dart';
import '../config/theme.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  String _filter = 'all';
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final captures = ref.watch(filteredCapturesProvider(_filter));

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Vault', style: Theme.of(context).textTheme.headlineMedium),
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close_rounded : Icons.search_rounded,
                      color: cs.onSurface,
                    ),
                    onPressed: () => setState(() => _isSearching = !_isSearching),
                  ),
                ],
              ),
            ),
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search captures...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: cs.onSurface.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ['all', 'notes', 'expenses', 'reminders'].map((f) {
                  final selected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? TimboColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: selected ? TimboColors.primary : cs.onSurfaceVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: captures.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _EmptyVault(cs: cs);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final capture = items[i];
                      return _CaptureCard(
                        key: ValueKey(capture.id),
                        capture: capture,
                        cs: cs,
                        db: ref.read(databaseProvider),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _EmptyVault(cs: cs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  final Capture capture;
  final ColorScheme cs;
  final TimboDatabase db;

  const _CaptureCard({
    super.key,
    required this.capture,
    required this.cs,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = capture.type == 'expense';
    final isReminder = capture.type == 'reminder';
    final isPast = capture.scheduledAt != null && capture.scheduledAt!.isBefore(DateTime.now());

    Color accentColor;
    if (isReminder) {
      accentColor = isPast ? cs.onSurfaceVariant : const Color(0xFFFFD700);
    } else {
      accentColor = TimboColors.primary;
    }

    return Dismissible(
      key: ValueKey(capture.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await db.deleteCapture(capture.id);
          return true;
        }
        return false;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border(
              left: BorderSide(color: accentColor, width: 3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isExpense) ...[
                        Row(
                          children: [
                            Text(
                              capture.category?.toUpperCase() ?? 'OTHER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TZS ${capture.amount?.toStringAsFixed(0) ?? '0'}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 22,
                            color: TimboColors.textPrimary,
                          ),
                        ),
                      ] else ...[
                        Text(
                          capture.content,
                          maxLines: isReminder ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isReminder ? FontWeight.w600 : FontWeight.w400,
                            decoration: capture.isCompleted ? TextDecoration.lineThrough : null,
                            color: capture.isCompleted ? cs.onSurfaceVariant : null,
                          ),
                        ),
                      ],
                      if (isReminder && capture.scheduledAt != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.notifications_outlined, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(capture.scheduledAt!),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                      if (isExpense && capture.content.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          capture.content,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(capture.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (isReminder)
                  IconButton(
                    icon: Icon(
                      capture.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.check_circle_outline_rounded,
                      color: capture.isCompleted ? TimboColors.primary : cs.onSurfaceVariant,
                    ),
                    onPressed: () => db.markCompleted(capture.id),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return 'Today at $hour:$min $ampm';
  }
}

class _EmptyVault extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyVault({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(Icons.inbox_rounded, size: 48, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing here yet. Go say something to Timbo.',
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
