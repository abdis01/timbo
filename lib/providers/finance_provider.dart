import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../services/hive_service.dart';

class FinanceProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  double _monthlyIncome = 0;
  double _monthlyExpenses = 0;
  Map<String, double> _categoryBreakdown = {};
  bool _isLoading = false;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);
  List<ExpenseModel> get filteredExpenses => _expenses
      .where((e) => e.date.month == _selectedMonth && e.date.year == _selectedYear)
      .toList();
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpenses => _monthlyExpenses;
  double get balance => _monthlyIncome - _monthlyExpenses;
  double get savingsRate =>
      _monthlyIncome > 0 ? (balance / _monthlyIncome * 100) : 0;
  List<ExpenseModel> get recentExpenses =>
      _expenses.length > 5 ? _expenses.sublist(0, 5) : List.from(_expenses);
  Map<String, double> get categoryBreakdown =>
      Map.unmodifiable(_categoryBreakdown);
  bool get isLoading => _isLoading;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  Future<void> loadFinanceData() async {
    _isLoading = true;
    notifyListeners();

    _expenses = HiveService.instance.getAllExpenses();
    _monthlyIncome = HiveService.instance.getTotalIncome(_selectedMonth, _selectedYear);
    _monthlyExpenses = HiveService.instance.getTotalExpenses(_selectedMonth, _selectedYear);
    _categoryBreakdown =
        HiveService.instance.getExpensesByCategory(_selectedMonth, _selectedYear);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await HiveService.instance.saveExpense(expense);
    _expenses.insert(0, expense);
    await loadFinanceData();
  }

  Future<void> deleteExpense(String id) async {
    await HiveService.instance.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    await loadFinanceData();
  }

  Future<void> changeMonth(int month, int year) async {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
    await loadFinanceData();
  }

  String getTopSpendingCategory() {
    String topCategory = '';
    double topAmount = 0;
    for (final entry in _categoryBreakdown.entries) {
      if (entry.value > topAmount) {
        topAmount = entry.value;
        topCategory = entry.key;
      }
    }
    return topCategory;
  }

  double getBudgetProgress(double budgetLimit) {
    if (budgetLimit <= 0) return 0;
    return (_monthlyExpenses / budgetLimit).clamp(0.0, 1.0).toDouble();
  }

  double getCategoryBudgetProgress(String category, double categoryBudget) {
    if (categoryBudget <= 0) return 0;
    final spent = _categoryBreakdown[category] ?? 0;
    return (spent / categoryBudget).clamp(0.0, 1.0).toDouble();
  }
}
