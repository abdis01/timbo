import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static const _shake = 'setting_shake';
  static const _notifications = 'setting_notifications';
  static const _lines = 'setting_lines';
  static const _darkMode = 'setting_dark_mode';
  static const _defaultFont = 'setting_default_font';
  static const _avatarPath = 'setting_avatar_path';

  bool get shakeEnabled => _prefs.getBool(_shake) ?? true;
  set shakeEnabled(bool v) => _prefs.setBool(_shake, v);

  bool get notificationsEnabled => _prefs.getBool(_notifications) ?? true;
  set notificationsEnabled(bool v) => _prefs.setBool(_notifications, v);

  bool get linesEnabled => _prefs.getBool(_lines) ?? true;
  set linesEnabled(bool v) => _prefs.setBool(_lines, v);

  bool get darkMode => _prefs.getBool(_darkMode) ?? false;
  set darkMode(bool v) => _prefs.setBool(_darkMode, v);

  String get defaultFont => _prefs.getString(_defaultFont) ?? 'Inter';
  set defaultFont(String v) => _prefs.setString(_defaultFont, v);

  String? get avatarPath => _prefs.getString(_avatarPath);
  set avatarPath(String? v) {
    if (v != null) _prefs.setString(_avatarPath, v);
    else _prefs.remove(_avatarPath);
  }
}
