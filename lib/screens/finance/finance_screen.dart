import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/finance_provider.dart';
import '../../models/expense_model.dart';
import '../../services/premium_service.dart';
import '../../widgets/premium_lock_widget.dart';
import '../../widgets/bottom_nav.dart';
// TODO: Implement Stripe payment for premium
// TODO: Add export notes to PDF feature

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String _filterTab = 'All';
  double _budgetLimit = 2000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await context.read<FinanceProvider>().loadFinanceData();
      await _loadBudgetLimit();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't load finance data. Please try again.")),
        );
      }
    }
  }

  Future<void> _loadBudgetLimit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _budgetLimit = prefs.getDouble('monthly_budget') ?? 2000;
      });
    } catch (_) {}
  }

  Future<void> _saveBudgetLimit(double limit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('monthly_budget', limit);
      setState(() => _budgetLimit = limit);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save budget. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(cs),
      bottomNavigationBar: AppBottomNav(activeRoute: AppRoutes.finance),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          if (finance.isLoading) {
            return _shimmerList(cs);
          }

          final filtered = _filteredTransactions(finance);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSummaryRow(finance)),
              SliverToBoxAdapter(child: _buildPieChart(finance)),
              SliverToBoxAdapter(child: _buildBudgetProgress()),
              SliverToBoxAdapter(child: _buildSpendingAnalysis(finance)),
              SliverToBoxAdapter(child: _buildTransactionHeader(cs)),
              SliverToBoxAdapter(child: _buildFilterTabs(cs)),
              if (filtered.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyTransactions(cs))
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final e = filtered[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const BehindMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) {
                                      finance.deleteExpense(e.id);
                                      HapticFeedback.mediumImpact();
                                    },
                                    backgroundColor: context.dangerColor,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete_outline_rounded,
                                    label: 'Delete',
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                ],
                              ),
                              child: _ExpenseCard(expense: e),
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          );
        },
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(3, (_) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme cs) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text('Finance',
              style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const Spacer(),
          _monthArrow(Icons.chevron_left_rounded, () {
            final f = context.read<FinanceProvider>();
            final m = f.selectedMonth == 1 ? 12 : f.selectedMonth - 1;
            final y = f.selectedMonth == 1 ? f.selectedYear - 1 : f.selectedYear;
            f.changeMonth(m, y);
          }, cs.onSurfaceVariant),
          Consumer<FinanceProvider>(
            builder: (_, f, __) {
              final monthName = DateFormat('MMMM yyyy').format(
                DateTime(f.selectedYear, f.selectedMonth),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(monthName,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface)),
              );
            },
          ),
          _monthArrow(Icons.chevron_right_rounded, () {
            final f = context.read<FinanceProvider>();
            final m = f.selectedMonth == 12 ? 1 : f.selectedMonth + 1;
            final y = f.selectedMonth == 12 ? f.selectedYear + 1 : f.selectedYear;
            f.changeMonth(m, y);
          }, cs.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _monthArrow(IconData icon, VoidCallback onTap, Color textSecondary) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: textSecondary.withValues(alpha: 0.1),
        ),
        child: Icon(icon, size: 20, color: textSecondary),
      ),
    );
  }

  Widget _buildSummaryRow(FinanceProvider finance) {
    final success = context.successColor;
    final danger = context.dangerColor;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Row(
        children: [
          _summaryCard('Income', '\$${finance.monthlyIncome.toStringAsFixed(0)}', success, expanded: true),
          const SizedBox(width: 8),
          _summaryCard('Expenses', '\$${finance.monthlyExpenses.toStringAsFixed(0)}', danger, expanded: true),
          const SizedBox(width: 8),
          _summaryCard('Balance', '\$${finance.balance.toStringAsFixed(0)}', primary, expanded: true),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String amount, Color color, {bool expanded = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: color.withValues(alpha: 0.8))),
            const SizedBox(height: 4),
            Text(amount,
                style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(FinanceProvider finance) {
    final breakdown = finance.categoryBreakdown;
    if (breakdown.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pie_chart_outline_rounded, size: 36,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                const SizedBox(height: 8),
                Text('No expenses this month',
                    style: GoogleFonts.inter(fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      );
    }

    final total = breakdown.values.fold(0.0, (a, b) => a + b);
    final colors = [
      CategoryColors.note, CategoryColors.expense, CategoryColors.income,
      CategoryColors.reminder, CategoryColors.capture, CategoryColors.video,
      const Color(0xFFF97316), const Color(0xFF06B6D4),
    ];

    final sections = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: sections.asMap().entries.map((e) {
                    final pct = (e.value.value / total * 100);
                    return PieChartSectionData(
                      value: e.value.value,
                      color: colors[e.key % colors.length],
                      radius: 50,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16, runSpacing: 6,
              children: sections.asMap().entries.map((e) {
                final pct = (e.value.value / total * 100);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('${e.value.key} (${pct.toStringAsFixed(0)}%)',
                        style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetProgress() {
    final finance = context.watch<FinanceProvider>();
    final cs = Theme.of(context).colorScheme;
    final progress = finance.getBudgetProgress(_budgetLimit);
    final usedPct = (progress * 100).toStringAsFixed(0);

    Color barColor;
    if (progress < 0.5) {
      barColor = context.successColor;
    } else if (progress < 0.8) {
      barColor = context.warningColor;
    } else {
      barColor = context.dangerColor;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Budget',
                    style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                GestureDetector(
                  onTap: () => _editBudget(cs),
                  child: Icon(Icons.edit_rounded, size: 16, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: cs.onSurfaceVariant.withValues(alpha: 0.15),
                color: barColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "You've used $usedPct% of your \$${_budgetLimit.toStringAsFixed(0)} budget",
              style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editBudget(ColorScheme cs) async {
    final controller = TextEditingController(text: _budgetLimit.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Monthly Budget', style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.inter(fontSize: 16, color: cs.onSurface),
          decoration: InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: Text('Save', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
    if (result != null) {
      await _saveBudgetLimit(result);
    }
    controller.dispose();
  }

  Widget _buildSpendingAnalysis(FinanceProvider finance) {
    final isPremium = PremiumService.instance.isPremium();
    final cs = Theme.of(context).colorScheme;

    String highestCategory = '';
    double highestPct = 0;
    if (finance.categoryBreakdown.isNotEmpty) {
      final top = finance.categoryBreakdown.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      highestCategory = top.key;
      final total = finance.categoryBreakdown.values.fold(0.0, (a, b) => a + b);
      highestPct = total > 0 ? (top.value / total * 100) : 0;
    }

    final monthlyExpenseList = finance.expenses
        .where((e) =>
            e.date.month == finance.selectedMonth &&
            e.date.year == finance.selectedYear &&
            e.type == 'expense')
        .toList();
    final avgPerTx = monthlyExpenseList.isNotEmpty
        ? finance.monthlyExpenses / monthlyExpenseList.length
        : 0.0;

    final lastMonth = finance.selectedMonth == 1 ? 12 : finance.selectedMonth - 1;
    final lastYear = finance.selectedMonth == 1 ? finance.selectedYear - 1 : finance.selectedYear;
    final lastMonthTotal = finance.expenses
        .where((e) => e.date.month == lastMonth && e.date.year == lastYear && e.type == 'expense')
        .fold(0.0, (sum, e) => sum + e.amount);

    String trendText;
    Color trendColor;
    if (lastMonthTotal > 0) {
      final change = ((finance.monthlyExpenses - lastMonthTotal) / lastMonthTotal * 100);
      final isUp = change > 0;
      trendText = '${isUp ? '↑' : '↓'}${change.abs().toStringAsFixed(0)}% vs last month';
      trendColor = isUp ? context.dangerColor : context.successColor;
    } else {
      trendText = 'No prior month data';
      trendColor = cs.onSurfaceVariant;
    }

    Widget cardContent = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text('Spending Analysis',
                  style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            ],
          ),
          const SizedBox(height: 12),
          if (monthlyExpenseList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Start adding expenses to see analysis',
                  style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
            )
          else ...[
            _analysisRow('Highest category',
                highestCategory.isNotEmpty ? '$highestCategory (${highestPct.toStringAsFixed(0)}%)' : '-',
                cs.onSurfaceVariant, cs.onSurface),
            const SizedBox(height: 8),
            _analysisRow('Average per transaction', '\$${avgPerTx.toStringAsFixed(2)}',
                cs.onSurfaceVariant, cs.onSurface),
            const SizedBox(height: 8),
            _analysisRow('Monthly trend', trendText, cs.onSurfaceVariant, trendColor),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: isPremium
          ? cardContent
          : PremiumLockWidget(feature: 'spending analysis', child: cardContent),
    );
  }

  Widget _analysisRow(String label, String value, Color textSecondary, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: textSecondary)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }

  Widget _buildTransactionHeader(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Text('Transactions',
          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
    );
  }

  Widget _buildFilterTabs(ColorScheme cs) {
    final filters = ['All', 'Income', 'Expenses'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: filters.map((f) {
          final active = _filterTab == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filterTab = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? cs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: active ? Colors.transparent : cs.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(f,
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: active ? Colors.white : cs.onSurfaceVariant,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyTransactions(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.account_balance_wallet_rounded, size: 32,
                  color: cs.primary.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 16),
            Text('No transactions yet',
                style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 6),
            Text('Start logging your money.',
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddSheet(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Add Transaction', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  List<ExpenseModel> _filteredTransactions(FinanceProvider finance) {
    switch (_filterTab) {
      case 'Income':
        return finance.expenses.where((e) => e.type == 'income').toList();
      case 'Expenses':
        return finance.expenses.where((e) => e.type == 'expense').toList();
      default:
        return finance.expenses;
    }
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExpenseSheet(
        onSaved: () {
          try {
            context.read<FinanceProvider>().loadFinanceData();
          } catch (_) {}
          HapticFeedback.lightImpact();
        },
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  const _ExpenseCard({required this.expense});

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'food': return Icons.restaurant_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'entertainment': return Icons.movie_creation_rounded;
      case 'health': return Icons.favorite_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      default: return Icons.receipt_rounded;
    }
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = date.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardColor = context.cardColor;
    final isIncome = expense.type == 'income';
    final amountColor = isIncome ? context.successColor : context.dangerColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(_categoryIcon(expense.category), size: 20, color: amountColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description.isEmpty ? expense.category : expense.description,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('${expense.category} \u00B7 ${_dateLabel(expense.date)}',
                    style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text('${isIncome ? '+' : '-'}\$${expense.amount.toStringAsFixed(2)}',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: amountColor)),
        ],
      ),
    );
  }
}

class _AddExpenseSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddExpenseSheet({required this.onSaved});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isIncome = false;
  String _category = 'Food';
  String? _receiptPath;
  bool _isSaving = false;

  static const _categories = ['Food', 'Transport', 'Entertainment', 'Health', 'Shopping', 'Other'];

  final _picker = ImagePicker();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    setState(() => _isSaving = true);
    try {
      final expense = ExpenseModel(
        amount: amount,
        type: _isIncome ? 'income' : 'expense',
        category: _category,
        description: _descriptionController.text.trim(),
        receiptImagePath: _receiptPath,
        date: DateTime.now(),
      );

      await context.read<FinanceProvider>().addExpense(expense);
      widget.onSaved();
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

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.85,
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
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text('Add Transaction',
                    style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('\$', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, color: cs.onSurface)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, color: cs.onSurface),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                hintStyle: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700,
                                    color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
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
                          _toggleChip('Expense', !_isIncome, cs),
                          const SizedBox(width: 8),
                          _toggleChip('Income', _isIncome, cs),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Category', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: _categories.map((cat) {
                          final selected = _category == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _category = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? cs.primary.withValues(alpha: 0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: selected ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(cat, style: GoogleFonts.inter(
                                fontSize: 13,
                                color: selected ? cs.primary : cs.onSurface,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              )),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 2,
                        style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Description (optional)',
                          hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
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
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: () async {
                          try {
                            final file = await _picker.pickImage(source: ImageSource.camera);
                            if (file != null) setState(() => _receiptPath = file.path);
                          } catch (_) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please allow camera access in Settings.')),
                              );
                            }
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.receipt_rounded, size: 18, color: cs.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(_receiptPath != null ? 'Receipt added' : 'Add receipt photo',
                                style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

  Widget _toggleChip(String label, bool selected, ColorScheme cs) {
    return GestureDetector(
      onTap: () => setState(() => _isIncome = label == 'Income'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.15) : context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? cs.primary : cs.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: selected ? cs.primary : cs.onSurface,
        )),
      ),
    );
  }
}
