import 'package:flutter/material.dart';

abstract class AuthService extends ChangeNotifier {
  bool get isAuthenticated;
  String? get userEmail;
  String? get userId;

  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

class MockAuthService extends AuthService {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userId;

  @override
  bool get isAuthenticated => _isAuthenticated;
  @override
  String? get userEmail => _userEmail;
  @override
  String? get userId => _userId;

  @override
  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _userEmail = email;
    _userId = 'mock_user_123';
    notifyListeners();
  }

  @override
  Future<void> signUp(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _userEmail = email;
    _userId = 'mock_user_123';
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _userEmail = null;
    _userId = null;
    notifyListeners();
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
