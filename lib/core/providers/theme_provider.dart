import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_preference';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  ThemeMode get themeMode => _themeMode;
  ThemeData get lightTheme => AppTheme.lightTheme();
  ThemeData get darkTheme => AppTheme.darkTheme();
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Charge la préférence de thème depuis les préférences partagées
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themePreferenceKey);
      
      if (themeModeIndex != null) {
        _themeMode = ThemeMode.values[themeModeIndex];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des préférences de thème: $e');
    }
  }
  
  /// Sauvegarde la préférence de thème dans les préférences partagées
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themePreferenceKey, _themeMode.index);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des préférences de thème: $e');
    }
  }
  
  /// Change le thème de l'application
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference();
    notifyListeners();
  }
  
  /// Bascule entre le mode clair et le mode sombre
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }
} 