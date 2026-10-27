import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _currencySymbol = '\$';
  bool _isCurrencySet = false;
  double _hourlyWage = 0.0;
  String? _aiApiKey;
  String _aiProvider = 'groq'; // 'groq' or 'gemini'

  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;
  bool get isCurrencySet => _isCurrencySet;
  double get hourlyWage => _hourlyWage;
  bool get hasHourlyWage => _hourlyWage > 0;
  String? get aiApiKey => _aiApiKey;
  bool get hasAiKey => _aiApiKey != null && _aiApiKey!.trim().isNotEmpty;
  String get aiProvider => _aiProvider;

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

  void setHourlyWage(double wage) async {
    _hourlyWage = wage;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hourlyWage', wage);
  }

  void setAiApiKey(String? key) async {
    _aiApiKey = key?.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (_aiApiKey != null && _aiApiKey!.isNotEmpty) {
      await prefs.setString('aiApiKey', _aiApiKey!);
    } else {
      await prefs.remove('aiApiKey');
    }
  }

  void setAiProvider(String provider) async {
    _aiProvider = provider;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aiProvider', provider);
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

    // Load Hourly Wage
    _hourlyWage = prefs.getDouble('hourlyWage') ?? 0.0;

    // Load AI Config
    _aiApiKey = prefs.getString('aiApiKey');
    _aiProvider = prefs.getString('aiProvider') ?? 'groq';
    
    notifyListeners();
  }
}
