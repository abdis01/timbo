import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isDarkMode = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isPremium => _user?.isPremium ?? false;
  bool get isDarkMode => _isDarkMode;
  bool get isLoggedIn => _user != null;
  String get greeting => _getTimeBasedGreeting();

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    _user = HiveService.instance.getUser();
    if (_user != null) {
      _isDarkMode = _user!.darkModeEnabled;
      await HiveService.instance.resetDailyLimitsIfNeeded();
      if (_user!.trialStartDate == null) {
        _user!.trialStartDate = DateTime.now();
        await HiveService.instance.saveUser(_user!);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    _user = user;
    _isDarkMode = user.darkModeEnabled;
    await HiveService.instance.saveUser(user);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    if (_user != null) {
      _user!.darkModeEnabled = _isDarkMode;
      await HiveService.instance.saveUser(_user!);
    }
    notifyListeners();
  }

  Future<void> setPremium(bool value) async {
    if (_user != null) {
      _user!.isPremium = value;
      await HiveService.instance.saveUser(_user!);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
