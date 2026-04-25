import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class HistoryProvider extends ChangeNotifier {
  static const String _storageKey = 'reading_history';
  static const int _maxHistory = 20;
  
  List<Article> _history = [];
  bool _initialized = false;

  List<Article> get history => List.unmodifiable(_history);
  bool get isInitialized => _initialized;

  HistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encodedData = prefs.getString(_storageKey);
      if (encodedData != null) {
        final List<dynamic> decodedData = jsonDecode(encodedData);
        _history = decodedData
            .map((item) => Article.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> addToHistory(Article article) async {
    // Remove if already exists to move to top
    _history.removeWhere((a) => a.url == article.url);
    
    // Insert at top
    _history.insert(0, article);
    
    // Trim to max history
    if (_history.length > _maxHistory) {
      _history = _history.sublist(0, _maxHistory);
    }
    
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(
        _history.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encodedData);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }
}
