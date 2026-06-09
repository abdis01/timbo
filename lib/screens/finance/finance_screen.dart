import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fl_chart/fl_chart.dart';
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
import '../../widgets/bottom_nav.dart';
// TODO: Implement Stripe payment for premium
// TODO: Add export notes to PDF feature

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  String _filterTab = 'All';
  Map<String, double> _categoryBudgets = {};
  late AnimationController _entryController;
  int _tappedPieIndex = -1;

  static const _categoryData = [
    _CategoryData('Food', Icons.restaurant_rounded),
    _CategoryData('Transport', Icons.directions_car_rounded),
    _CategoryData('Entertainment', Icons.movie_creation_rounded),
    _CategoryData('Health', Icons.favorite_rounded),
    _CategoryData('Shopping', Icons.shopping_bag_rounded),
    _CategoryData('Other', Icons.category_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryController.forward();
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await context.read<FinanceProvider>().loadFinanceData();
      await _loadCategoryBudgets();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't load finance data. Please try again.")),
        );
      }
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('category_budgets');
      if (data != null) {
        final decoded = Map<String, dynamic>.from(
          const JsonDecoder().convert(data) as Map,
        );
        setState(() {
          _categoryBudgets = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
        });
      }
    } catch (_) {}
  }

  Future<void> _saveCategoryBudgets(Map<String, double> budgets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('category_budgets', const JsonEncoder().convert(budgets));
      setState(() => _categoryBudgets = Map.from(budgets));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save category budgets. Please try again.")),
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
      bottomNavigationBar: const AppBottomNav(activeRoute: AppRoutes.finance),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          if (finance.isLoading) {
            return _shimmerList(cs);
          }

          final filtered = _filteredTransactions(finance);

          return RefreshIndicator(
            onRefresh: _loadData,
            child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSummaryRow(finance)),
              SliverToBoxAdapter(child: _buildPieChart(finance)),
              SliverToBoxAdapter(child: _buildBudgetProgress()),
              SliverToBoxAdapter(child: _buildSpendingAnalysis(finance)),
              SliverToBoxAdapter(child: _buildTransactionHeader(cs)),
              SliverToBoxAdapter(child: _buildFilterTabs(cs)),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: filtered.isEmpty
                      ? _buildEmptyTransactions(cs)
                      : Padding(
                          key: ValueKey('${finance.selectedYear}-${finance.selectedMonth}-$_filterTab'),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Column(
                            children: List.generate(filtered.length, (i) {
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
                                            try { HapticFeedback.mediumImpact(); } catch (_) {}
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
                            }),
                          ),
                        ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
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
                    color: cs.surfaceContainerHighest,
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
                color: cs.surfaceContainerHighest,
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
              style: TextStyle(fontFamily: 'Satoshi', fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface)),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(monthName,
                      key: ValueKey(monthName),
                      style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface)),
                ),
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
          _AnimatedSummaryCard(
            entryController: _entryController,
            index: 0,
            label: 'Income',
            amount: finance.monthlyIncome,
            color: success,
          ),
          const SizedBox(width: 8),
          _AnimatedSummaryCard(
            entryController: _entryController,
            index: 1,
            label: 'Expenses',
            amount: finance.monthlyExpenses,
            color: danger,
          ),
          const SizedBox(width: 8),
          _AnimatedSummaryCard(
            entryController: _entryController,
            index: 2,
            label: 'Balance',
            amount: finance.balance,
            color: primary,
          ),
        ],
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
                    style: TextStyle(fontFamily: 'Satoshi', fontSize: 14,
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
      child: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          final progress = _entryController.value;
          return Opacity(
            opacity: progress.clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - progress.clamp(0, 1))),
              child: child,
            ),
          );
        },
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
                      final isTapped = _tappedPieIndex == e.key;
                      return PieChartSectionData(
                        value: e.value.value,
                        color: colors[e.key % colors.length],
                        radius: isTapped ? 55 : 50,
                        title: '${pct.toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(fontFamily: 'Satoshi', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                        badgeWidget: isTapped
                            ? Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent || event is FlLongPressEnd) {
                          setState(() => _tappedPieIndex = -1);
                        } else if (response != null && response.touchedSection != null) {
                          setState(() => _tappedPieIndex = response.touchedSection!.touchedSectionIndex);
                        }
                      },
                    ),
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
                          style: TextStyle(fontFamily: 'Satoshi', fontSize: 12, color: cs.onSurfaceVariant)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetProgress() {
    final finance = context.watch<FinanceProvider>();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Category Budgets',
                    style: TextStyle(fontFamily: 'Satoshi', fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                GestureDetector(
                  onTap: () => _editCategoryBudgets(cs),
                  child: Icon(Icons.edit_rounded, size: 16, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_categoryBudgets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Set a budget for each category by tapping the edit icon.',
                    style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: cs.onSurfaceVariant)),
              )
            else
              ..._categoryData.map((cat) {
                final budget = _categoryBudgets[cat.name] ?? 0;
                if (budget <= 0) return const SizedBox.shrink();
                final spent = finance.categoryBreakdown[cat.name] ?? 0;
                final progress = budget > 0 ? ((spent / budget).clamp(0.0, 1.0).toDouble()) : 0.0;
                final pct = (progress * 100).toStringAsFixed(0);

                Color barColor;
                if (progress < 0.5) {
                  barColor = context.successColor;
                } else if (progress < 0.8) {
                  barColor = context.warningColor;
                } else {
                  barColor = context.dangerColor;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(cat.icon, size: 16, color: cs.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(cat.name,
                                style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface)),
                          ),
                          Text('\$${spent.toStringAsFixed(0)} / \$${budget.toStringAsFixed(0)}',
                              style: TextStyle(fontFamily: 'Satoshi', fontSize: 11, color: cs.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: cs.onSurfaceVariant.withValues(alpha: 0.15),
                          color: barColor,
                          minHeight: 6,
                        ),
                      ),
                      if (progress >= 0.8)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            progress >= 1.0 ? '$pct% exceeded!' : '$pct% used',
                            style: TextStyle(fontFamily: 'Satoshi', fontSize: 10, color: barColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _editCategoryBudgets(ColorScheme cs) async {
    final controllers = <String, TextEditingController>{};
    final tempBudgets = Map<String, double>.from(_categoryBudgets);

    for (final cat in _categoryData) {
      final current = tempBudgets[cat.name] ?? 0;
      controllers[cat.name] = TextEditingController(
        text: current > 0 ? current.toStringAsFixed(0) : '',
      );
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Category Budgets', style: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _categoryData.map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 20, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: Text(cat.name,
                            style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurface)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controllers[cat.name],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurface),
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Satoshi')),
          ),
          TextButton(
            onPressed: () {
              for (final cat in _categoryData) {
                final v = double.tryParse(controllers[cat.name]!.text);
                if (v != null && v > 0) {
                  tempBudgets[cat.name] = v;
                } else {
                  tempBudgets.remove(cat.name);
                }
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Save', style: TextStyle(fontFamily: 'Satoshi')),
          ),
        ],
      ),
    );

    for (final c in controllers.values) {
      c.dispose();
    }

    if (result == true) {
      await _saveCategoryBudgets(tempBudgets);
    }
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
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            ],
          ),
          const SizedBox(height: 12),
          if (monthlyExpenseList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Start adding expenses to see analysis',
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: cs.onSurfaceVariant)),
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

    if (!isPremium) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: cardContent,
    );
  }

  Widget _analysisRow(String label, String value, Color textSecondary, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: textSecondary)),
        Text(value, style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }

  Widget _buildTransactionHeader(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Text('Transactions',
          style: TextStyle(fontFamily: 'Satoshi', fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
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
                    style: TextStyle(fontFamily: 'Satoshi', 
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
                style: TextStyle(fontFamily: 'Satoshi', fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 6),
            Text('Start logging your money.',
                style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddSheet(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Transaction', style: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  List<ExpenseModel> _filteredTransactions(FinanceProvider finance) {
    switch (_filterTab) {
      case 'Income':
        return finance.filteredExpenses.where((e) => e.type == 'income').toList();
      case 'Expenses':
        return finance.filteredExpenses.where((e) => e.type == 'expense').toList();
      default:
        return finance.filteredExpenses;
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
          try { HapticFeedback.lightImpact(); } catch (_) {}
        },
        categoryBudgets: _categoryBudgets,
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
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('${expense.category} \u00B7 ${_dateLabel(expense.date)}',
                    style: TextStyle(fontFamily: 'Satoshi', fontSize: 12, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text('${isIncome ? '+' : '-'}\$${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(fontFamily: 'Satoshi', fontSize: 15, fontWeight: FontWeight.w600, color: amountColor)),
        ],
      ),
    );
  }
}

class _AddExpenseSheet extends StatefulWidget {
  final VoidCallback onSaved;
  final Map<String, double> categoryBudgets;
  const _AddExpenseSheet({required this.onSaved, required this.categoryBudgets});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isIncome = false;
  String _category = 'Other';
  String? _receiptPath;
  bool _isSaving = false;

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

      if (!_isIncome && mounted) {
        _checkBudgetAlert();
      }

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

  void _checkBudgetAlert() {
    final budget = widget.categoryBudgets[_category] ?? 0;
    if (budget <= 0) return;
    final finance = context.read<FinanceProvider>();
    final spent = finance.categoryBreakdown[_category] ?? 0;
    final progress = spent / budget;
    if (progress >= 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_category budget exceeded! You\'ve spent \$${spent.toStringAsFixed(0)} of \$${budget.toStringAsFixed(0)}.'),
          backgroundColor: context.dangerColor,
        ),
      );
    } else if (progress >= 0.8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Warning: You\'ve used ${(progress * 100).toStringAsFixed(0)}% of your $_category budget.'),
          backgroundColor: context.warningColor,
        ),
      );
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
                      Row(
                        children: [
                          Text('\$', style: TextStyle(fontFamily: 'Satoshi', fontSize: 28, fontWeight: FontWeight.w700, color: cs.onSurface)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(fontFamily: 'Satoshi', fontSize: 28, fontWeight: FontWeight.w700, color: cs.onSurface),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                hintStyle: TextStyle(fontFamily: 'Satoshi', fontSize: 28, fontWeight: FontWeight.w700,
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
                      Text('Category', style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: _FinanceScreenState._categoryData.map((cat) {
                          final selected = _category == cat.name;
                          return GestureDetector(
                            onTap: () => setState(() => _category = cat.name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? cs.primary.withValues(alpha: 0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: selected ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cat.icon, size: 14, color: selected ? cs.primary : cs.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(cat.name, style: TextStyle(fontFamily: 'Satoshi', 
                                    fontSize: 13,
                                    color: selected ? cs.primary : cs.onSurface,
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                  )),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
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
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: () async {
                          try {
                            final file = await _picker.pickImage(source: ImageSource.camera);
                            if (file != null) setState(() => _receiptPath = file.path);
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please allow camera access in Settings.')),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.receipt_rounded, size: 18, color: cs.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(_receiptPath != null ? 'Receipt added' : 'Add receipt photo',
                                style: TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: cs.onSurfaceVariant)),
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
                              : const Text('Save', style: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w600)),
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
        child: Text(label, style: TextStyle(fontFamily: 'Satoshi', 
          fontSize: 13, fontWeight: FontWeight.w500,
          color: selected ? cs.primary : cs.onSurface,
        )),
      ),
    );
  }
}

class _AnimatedSummaryCard extends StatelessWidget {
  final AnimationController entryController;
  final int index;
  final String label;
  final double amount;
  final Color color;

  const _AnimatedSummaryCard({
    required this.entryController,
    required this.index,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: entryController,
        builder: (context, child) {
          final delay = 0.1 * index;
          final t = ((entryController.value - delay) / 0.4).clamp(0.0, 1.0);
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - Curves.easeOut.transform(t))),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontFamily: 'Satoshi', fontSize: 11, color: color.withValues(alpha: 0.8))),
              const SizedBox(height: 4),
              _CountUpText(
                target: amount,
                style: TextStyle(fontFamily: 'Satoshi', fontSize: 16, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountUpText extends StatefulWidget {
  final double target;
  final TextStyle style;

  const _CountUpText({required this.target, required this.style});

  @override
  State<_CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<_CountUpText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = widget.target * _animation.value;
        return Text('\$${value.toStringAsFixed(2)}', style: widget.style);
      },
    );
  }
}

class _CategoryData {
  final String name;
  final IconData icon;
  const _CategoryData(this.name, this.icon);
}
