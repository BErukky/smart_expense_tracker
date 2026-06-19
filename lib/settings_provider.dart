import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _currencySymbol = '\$';
  bool _isCurrencySet = false;

  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;
  bool get isCurrencySet => _isCurrencySet;

  SettingsProvider() {
    _loadSettings();
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }

  void setCurrency(String symbol) async {
    _currencySymbol = symbol;
    _isCurrencySet = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencySymbol', symbol);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    final isDark = prefs.getBool('isDarkMode') ?? true; // Default to dark mode
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    // Load Currency
    final savedCurrency = prefs.getString('currencySymbol');
    if (savedCurrency != null) {
      _currencySymbol = savedCurrency;
      _isCurrencySet = true;
    }
    
    notifyListeners();
  }
}
