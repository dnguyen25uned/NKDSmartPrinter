import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cài đặt ứng dụng: ngôn ngữ + bật/tắt log kỹ thuật.
/// Lựa chọn ngôn ngữ được lưu để dùng cho lần khởi động sau.
class SettingsController extends ChangeNotifier {
  SettingsController();

  static const _languageKey = 'language';
  static const _loggingKey = 'logging_enabled';

  Locale _locale = const Locale('vi');
  bool _loggingEnabled = true;
  bool _loaded = false;

  Locale get locale => _locale;
  bool get loggingEnabled => _loggingEnabled;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languageKey);
    if (code == 'en' || code == 'vi') {
      _locale = Locale(code!);
    }
    _loggingEnabled = prefs.getBool(_loggingKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'vi' && locale.languageCode != 'en') {
      return;
    }
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> setLoggingEnabled(bool value) async {
    _loggingEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggingKey, value);
    notifyListeners();
  }
}
