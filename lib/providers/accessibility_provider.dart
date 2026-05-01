import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityProvider extends ChangeNotifier {
  static const String _storageKey = 'text_scale_factor';
  
  double _textScaleFactor = 1.0;
  bool _isInitialized = false;

  double get textScaleFactor => _textScaleFactor;
  bool get isInitialized => _isInitialized;

  AccessibilityProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _textScaleFactor = prefs.getDouble(_storageKey) ?? 1.0;
    } catch (e) {
      debugPrint('Error loading accessibility prefs: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setTextScale(double scale) async {
    _textScaleFactor = scale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_storageKey, scale);
    } catch (e) {
      debugPrint('Error saving text scale: $e');
    }
  }
}
