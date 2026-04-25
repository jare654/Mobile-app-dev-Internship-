import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class BookmarksProvider extends ChangeNotifier {
  static const String _storageKey = 'saved_articles';
  List<Article> _bookmarks = [];
  bool _initialized = false;

  List<Article> get bookmarks => List.unmodifiable(_bookmarks);
  bool get isInitialized => _initialized;

  BookmarksProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encodedData = prefs.getString(_storageKey);
      if (encodedData != null) {
        final List<dynamic> decodedData = jsonDecode(encodedData);
        _bookmarks = decodedData
            .map((item) => Article.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(Article article) async {
    final isSaved = _bookmarks.any((a) => a.url == article.url);
    if (isSaved) {
      _bookmarks.removeWhere((a) => a.url == article.url);
    } else {
      _bookmarks.insert(0, article);
    }
    notifyListeners();
    await _saveToStorage();
  }

  bool isBookmarked(Article article) {
    return _bookmarks.any((a) => a.url == article.url);
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(
        _bookmarks.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encodedData);
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }
}
