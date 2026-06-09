import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/note_model.dart';
import '../models/expense_model.dart';
import '../models/reminder_model.dart';
import '../models/quick_capture_model.dart';
import '../services/hive_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  List<String> _recentSearches = [];
  static const _maxRecentSearches = 5;

  String _query = '';
  List<NoteModel> _noteResults = [];
  List<ExpenseModel> _expenseResults = [];
  List<ReminderModel> _reminderResults = [];
  List<QuickCaptureModel> _captureResults = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _recentSearches =
            prefs.getStringList('search_history')?.take(_maxRecentSearches).toList() ?? [];
      });
    } catch (_) {}
  }

  Future<void> _saveSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = (prefs.getStringList('search_history') ?? [])
          .where((s) => s != query)
          .toList();
      list.insert(0, query);
      if (list.length > _maxRecentSearches) list.removeLast();
      await prefs.setStringList('search_history', list);
      setState(() => _recentSearches = list);
    } catch (_) {}
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _query = value;
        _hasSearched = value.isNotEmpty;
      });
      if (value.isNotEmpty) {
        _performSearch(value);
        _saveSearch(value);
      }
    });
  }

  void _performSearch(String query) {
    final q = query.toLowerCase();
    _noteResults = HiveService.instance.getAllNotes().where((n) {
      return n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q) ||
          n.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();

    _expenseResults = HiveService.instance.getAllExpenses().where((e) {
      return e.description.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q);
    }).toList();

    _reminderResults = HiveService.instance.getAllReminders().where((r) {
      return r.title.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q);
    }).toList();

    _captureResults = HiveService.instance.getAllCaptures().where((c) {
      return c.content.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildHighlightedText(String text, String query, Color baseColor,
      {int maxLines = 2}) {
    if (query.isEmpty) {
      return Text(text,
          style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: baseColor),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis);
    }

    final q = query.toLowerCase();
    final lower = text.toLowerCase();
    final spans = <InlineSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(q, start);
      if (idx == -1) break;
      if (idx > start) {
        spans.add(TextSpan(
          text: text.substring(start, idx),
          style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: baseColor),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + q.length),
        style: TextStyle(fontFamily: 'Satoshi', 
          fontSize: 14, color: baseColor, fontWeight: FontWeight.w700,
        ),
      ));
      start = idx + q.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: baseColor),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Future<void> _runSearch(String query) async {
    _searchController.text = query;
    _onSearchChanged(query);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(cs),
            Expanded(
              child: _query.isEmpty
                  ? _buildRecentSearches(cs)
                  : _hasSearched && _noResults()
                      ? _buildEmptyResults(cs)
                      : _buildResults(cs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_rounded, color: cs.onSurface, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: TextStyle(fontFamily: 'Satoshi', fontSize: 16, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search notes, expenses, reminders...',
                  hintStyle: TextStyle(fontFamily: 'Satoshi', color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 22),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: cs.onSurfaceVariant, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                              _hasSearched = false;
                              _noteResults = [];
                              _expenseResults = [];
                              _reminderResults = [];
                              _captureResults = [];
                            });
                            _focusNode.requestFocus();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Recent Searches',
            style: TextStyle(fontFamily: 'Satoshi', fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
        if (_recentSearches.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _recentSearches.map((s) {
              return GestureDetector(
                onTap: () => _runSearch(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(s, style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: cs.onSurface)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 24),
        Text('Search Tips',
            style: TextStyle(fontFamily: 'Satoshi', fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
        const SizedBox(height: 12),
        _searchTip(Icons.article_outlined, 'Search note titles and content', cs),
        const SizedBox(height: 6),
        _searchTip(Icons.account_balance_wallet_rounded, 'Find expenses by description or category', cs),
        const SizedBox(height: 6),
        _searchTip(Icons.notifications_outlined, 'Look up reminders by title', cs),
      ],
    );
  }

  Widget _searchTip(IconData icon, String text, ColorScheme cs) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: cs.onSurfaceVariant.withValues(alpha: 0.7))),
      ],
    );
  }

  bool _noResults() {
    return _noteResults.isEmpty &&
        _expenseResults.isEmpty &&
        _reminderResults.isEmpty &&
        _captureResults.isEmpty;
  }

  Widget _buildEmptyResults(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text("Nothing found for '$_query'",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Satoshi', fontSize: 16, fontWeight: FontWeight.w500, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text('Try different keywords',
                style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ColorScheme cs) {
    final items = <Widget>[];

    if (_noteResults.isNotEmpty) {
      items.add(_sectionHeader('NOTES (${_noteResults.length})', cs));
      for (final note in _noteResults) {
        items.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _noteResultItem(note, cs),
        ));
      }
    }

    if (_expenseResults.isNotEmpty) {
      items.add(_sectionHeader('EXPENSES (${_expenseResults.length})', cs));
      for (final expense in _expenseResults) {
        items.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _expenseResultItem(expense, cs),
        ));
      }
    }

    if (_reminderResults.isNotEmpty) {
      items.add(_sectionHeader('REMINDERS (${_reminderResults.length})', cs));
      for (final reminder in _reminderResults) {
        items.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _reminderResultItem(reminder, cs),
        ));
      }
    }

    if (_captureResults.isNotEmpty) {
      items.add(_sectionHeader('CAPTURES (${_captureResults.length})', cs));
      for (final capture in _captureResults) {
        items.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _captureResultItem(capture, cs),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: items,
    );
  }

  Widget _sectionHeader(String label, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
      child: Text(label,
          style: TextStyle(fontFamily: 'Satoshi', 
            fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1,
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          )),
    );
  }

  Widget _noteResultItem(NoteModel note, ColorScheme cs) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.noteDetail, arguments: note.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 4, height: 48,
              decoration: BoxDecoration(
                color: _categoryColor(note.category, cs),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(
                      note.title.isEmpty ? 'Untitled' : note.title, _query, cs.onSurface, maxLines: 1),
                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildHighlightedText(note.content, _query, cs.onSurfaceVariant),
                  ],
                  const SizedBox(height: 6),
                  Text(DateFormat('MMM d, yyyy').format(note.updatedAt),
                      style: TextStyle(fontFamily: 'Satoshi', fontSize: 11, color: cs.onSurfaceVariant.withValues(alpha: 0.6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expenseResultItem(ExpenseModel expense, ColorScheme cs) {
    final isIncome = expense.type == 'income';
    final amountColor = isIncome ? context.successColor : cs.error;
    final icon = isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.finance),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: amountColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(
                      expense.description.isNotEmpty ? expense.description : expense.category,
                      _query, cs.onSurface, maxLines: 1),
                  const SizedBox(height: 2),
                  Text(expense.category, style: TextStyle(fontFamily: 'Satoshi', fontSize: 12, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Text('\$${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(fontFamily: 'Satoshi', fontSize: 16, fontWeight: FontWeight.w600, color: amountColor)),
          ],
        ),
      ),
    );
  }

  Widget _reminderResultItem(ReminderModel reminder, ColorScheme cs) {
    final priorityColor = reminder.priority == 'high'
        ? cs.error
        : reminder.priority == 'low'
            ? context.successColor
            : context.warningColor;
    final timeStr = DateFormat('h:mm a').format(reminder.scheduledAt);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.reminders),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: reminder.isCompleted
                      ? context.successColor
                      : cs.onSurfaceVariant.withValues(alpha: 0.4),
                  width: 2,
                ),
                color: reminder.isCompleted
                    ? context.successColor.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: reminder.isCompleted
                  ? Icon(Icons.check_rounded, size: 12, color: context.successColor)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(reminder.title, _query, cs.onSurface, maxLines: 1),
                  if (reminder.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    _buildHighlightedText(reminder.description, _query, cs.onSurfaceVariant),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: cs.onSurface)),
                const SizedBox(height: 4),
                Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _captureResultItem(QuickCaptureModel capture, ColorScheme cs) {
    final icon = _captureIcon(capture.type);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(capture.content, _query, cs.onSurface, maxLines: 2),
                const SizedBox(height: 4),
                Text(DateFormat('MMM d, yyyy').format(capture.capturedAt),
                    style: TextStyle(fontFamily: 'Satoshi', fontSize: 11, color: cs.onSurfaceVariant.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category, ColorScheme cs) {
    switch (category.toLowerCase()) {
      case 'personal': return CategoryColors.note;
      case 'work': return CategoryColors.expense;
      case 'idea': return CategoryColors.capture;
      case 'reminder': return CategoryColors.reminder;
      default: return cs.primary;
    }
  }

  IconData _captureIcon(String type) {
    switch (type) {
      case 'text': return Icons.edit_note_rounded;
      case 'expense': return Icons.account_balance_wallet_rounded;
      case 'reminder': return Icons.notifications_rounded;
      case 'photo': return Icons.camera_alt_rounded;
      case 'voice': return Icons.mic_rounded;
      default: return Icons.circle_rounded;
    }
  }
}
