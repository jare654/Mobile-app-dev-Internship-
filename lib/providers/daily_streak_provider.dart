import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyStreakProvider extends ChangeNotifier {
  static const String _streakKey = 'daily_streak';
  static const String _lastVisitKey = 'last_visit_date';
  static const String _hasVisitedTodayKey = 'has_visited_today';

  int _currentStreak = 0;
  bool _hasVisitedToday = false;
  DateTime? _lastVisitDate;

  int get currentStreak => _currentStreak;
  bool get hasVisitedToday => _hasVisitedToday;
  String get streakDisplay => _currentStreak == 0 ? 'Start Your Daily Streak' : '$_currentStreak Day Streak!';

  DailyStreakProvider() {
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentStreak = prefs.getInt(_streakKey) ?? 0;
      _lastVisitDate = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt(_lastVisitKey) ?? DateTime.now().millisecondsSinceEpoch,
      );
      _hasVisitedToday = prefs.getBool(_hasVisitedTodayKey) ?? false;
      
      // Check if it's a new day
      await _checkNewDay();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading streak data: $e');
    }
  }

  Future<void> _checkNewDay() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastVisit = _lastVisitDate != null 
        ? DateTime(_lastVisitDate!.year, _lastVisitDate!.month, _lastVisitDate!.day)
        : null;

    if (lastVisit == null || today.isAfter(lastVisit)) {
      // Check if the user missed a day
      if (lastVisit != null && today.difference(lastVisit).inDays > 1) {
        // User missed at least one day, reset streak
        _currentStreak = 1;
      } else if (lastVisit != null && today.isAfter(lastVisit)) {
        // Consecutive day, increment streak
        _currentStreak++;
      } else {
        // First visit or streak was reset
        _currentStreak = 1;
      }

      _hasVisitedToday = false;
      await _saveStreakData();
    }
  }

  Future<void> recordDailyVisit() async {
    if (_hasVisitedToday) return; // Already recorded today

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // If it's a new day, the streak was already updated in _checkNewDay
      if (!_hasVisitedToday) {
        _hasVisitedToday = true;
        _lastVisitDate = DateTime.now();
        
        await prefs.setInt(_streakKey, _currentStreak);
        await prefs.setInt(_lastVisitKey, _lastVisitDate!.millisecondsSinceEpoch);
        await prefs.setBool(_hasVisitedTodayKey, true);
        
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error recording daily visit: $e');
    }
  }

  Future<void> resetStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentStreak = 0;
      _hasVisitedToday = false;
      _lastVisitDate = null;
      
      await prefs.remove(_streakKey);
      await prefs.remove(_lastVisitKey);
      await prefs.remove(_hasVisitedTodayKey);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error resetting streak: $e');
    }
  }

  Future<void> _saveStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_streakKey, _currentStreak);
      if (_lastVisitDate != null) {
        await prefs.setInt(_lastVisitKey, _lastVisitDate!.millisecondsSinceEpoch);
      }
      await prefs.setBool(_hasVisitedTodayKey, _hasVisitedToday);
    } catch (e) {
      if (kDebugMode) print('Error saving streak data: $e');
    }
  }
}
