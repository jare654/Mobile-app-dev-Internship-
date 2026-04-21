import 'package:flutter/material.dart';

import '../core/entities.dart';
import '../core/localization/app_strings.dart';
import '../data/local/local_store.dart';
import '../data/local/pending_action_store.dart';
import '../data/repositories/property_repository.dart';

import '../data/local/favorite_store.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.localStore,
    required this.propertyRepository,
    required this.pendingActionStore,
    required this.favoriteStore,
  });

  final LocalStore localStore;
  final PropertyRepository propertyRepository;
  final PendingActionStore pendingActionStore;
  final FavoriteStore favoriteStore;

  ThemeMode _themeMode = ThemeMode.system;
  AppLanguage _language = AppLanguage.english;
  bool _isOnline = true;
  bool _isLoggedIn = false;
  bool _showAuth = false;
  bool _isRegisterMode = false;
  bool _isLoadingProperties = true;
  String? _propertyLoadError;
  String? _lastActionError;
  int _selectedTab = 0;
  int _pendingActionsCount = 0;
  List<PendingAction> _pendingActions = <PendingAction>[];
  Set<String> _favoritedIds = <String>{};
  List<Property> _properties = <Property>[];
  User? _currentUser;
  String? _selectedPropertyId;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  bool get isOnline => _isOnline;
  bool get isLoggedIn => _isLoggedIn;
  bool get showAuth => _showAuth;
  bool get isRegisterMode => _isRegisterMode;
  bool get isLoadingProperties => _isLoadingProperties;
  String? get propertyLoadError => _propertyLoadError;
  String? get lastActionError => _lastActionError;
  int get selectedTab => _selectedTab;
  int get pendingActionsCount => _pendingActionsCount;
  List<PendingAction> get pendingActions => List.unmodifiable(_pendingActions);
  Set<String> get favoritedIds => _favoritedIds;
  List<Property> get properties => _properties;
  User? get currentUser => _currentUser;
  String? get selectedPropertyId => _selectedPropertyId;

  Property? get selectedProperty {
    if (_selectedPropertyId == null) {
      return null;
    }
    for (final property in _properties) {
      if (property.id == _selectedPropertyId) {
        return property;
      }
    }
    return null;
  }

  Future<void> initialize() async {
    _themeMode = switch (localStore.readTheme()) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _language = localStore.readLanguage() == 'am'
        ? AppLanguage.amharic
        : AppLanguage.english;
    _isOnline = localStore.readOnline();
    _favoritedIds = await favoriteStore.readAll();
    _pendingActionsCount = localStore.readPendingCount();
    _pendingActions = await pendingActionStore.readAll();
    if (_pendingActions.isNotEmpty) {
      _pendingActionsCount = _pendingActions.length;
    }
    final userMap = localStore.readUser();
    if (userMap != null) {
      _currentUser = User(
        id: userMap['id'] as String,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
      );
      _isLoggedIn = true;
    }
    await loadProperties();
  }

  Future<void> loadProperties() async {
    _isLoadingProperties = true;
    _propertyLoadError = null;
    notifyListeners();
    try {
      _properties = await propertyRepository.getProperties(online: _isOnline);
    } catch (_) {
      _propertyLoadError = 'Failed to load properties. Pull to retry.';
    } finally {
      _isLoadingProperties = false;
      notifyListeners();
    }
  }

  Future<void> refreshProperties() => loadProperties();

  void openProperty(Property property) {
    _selectedPropertyId = property.id;
    notifyListeners();
  }

  void closeProperty() {
    _selectedPropertyId = null;
    notifyListeners();
  }

  void selectTab(int tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void openLogin({bool register = false}) {
    _isRegisterMode = register;
    _showAuth = true;
    notifyListeners();
  }

  void closeAuth() {
    _showAuth = false;
    notifyListeners();
  }

  void switchAuthMode(bool register) {
    _isRegisterMode = register;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
    String? name,
  }) async {
    _lastActionError = null;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _currentUser = User(
      id: 'u1',
      name: name?.trim().isNotEmpty == true ? name!.trim() : 'Abel Kebede',
      email: email.trim(),
    );
    _isLoggedIn = true;
    _showAuth = false;
    await localStore.writeUser({
      'id': _currentUser!.id,
      'name': _currentUser!.name,
      'email': _currentUser!.email,
    });
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) {
    return login(email: email, password: password, name: name);
  }

  Future<void> logout() async {
    _lastActionError = null;
    _isLoggedIn = false;
    _currentUser = null;
    _favoritedIds = <String>{};
    _pendingActionsCount = 0;
    _pendingActions = <PendingAction>[];
    _selectedTab = 0;
    _selectedPropertyId = null;
    _showAuth = false;
    await localStore.writeUser(null);
    await favoriteStore.writeAll(_favoritedIds);
    await localStore.writePendingCount(_pendingActionsCount);
    await pendingActionStore.writeAll(_pendingActions);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _lastActionError = null;
    try {
      _themeMode = mode;
      await localStore.writeTheme(mode.name);
    } catch (_) {
      _lastActionError = 'Failed to save theme preference.';
    }
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage value) async {
    _lastActionError = null;
    try {
      _language = value;
      await localStore.writeLanguage(
        value == AppLanguage.amharic ? 'am' : 'en',
      );
    } catch (_) {
      _lastActionError = 'Failed to save language preference.';
    }
    notifyListeners();
  }

  Future<void> toggleConnectivity() async {
    _lastActionError = null;
    _isOnline = !_isOnline;
    try {
      await localStore.writeOnline(_isOnline);
      if (_isOnline && _pendingActions.isNotEmpty) {
        await _syncPendingActions();
      }
    } catch (_) {
      _lastActionError = 'Failed to update connectivity state.';
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    _lastActionError = null;
    if (_favoritedIds.contains(id)) {
      _favoritedIds.remove(id);
    } else {
      _favoritedIds.add(id);
    }
    try {
      if (!_isOnline) {
        _pendingActions.add(
          PendingAction(
            type: PendingActionType.toggleFavorite,
            payload: {'propertyId': id, 'favorited': _favoritedIds.contains(id)},
          ),
        );
        _pendingActionsCount = _pendingActions.length;
        await localStore.writePendingCount(_pendingActionsCount);
        await pendingActionStore.writeAll(_pendingActions);
      }
      await favoriteStore.writeAll(_favoritedIds);
    } catch (_) {
      _lastActionError = 'Failed to update favourites.';
    }
    notifyListeners();
  }

  Future<void> queueInquiry(String message) async {
    _lastActionError = null;
    if (message.trim().isEmpty) {
      return;
    }
    if (!_isOnline) {
      try {
        _pendingActions.add(
          PendingAction(
            type: PendingActionType.sendInquiry,
            payload: {'message': message.trim()},
          ),
        );
        _pendingActionsCount = _pendingActions.length;
        await localStore.writePendingCount(_pendingActionsCount);
        await pendingActionStore.writeAll(_pendingActions);
      } catch (_) {
        _lastActionError = 'Failed to queue inquiry.';
      }
      notifyListeners();
      return;
    }

    // Simulate online send
    await Future<void>.delayed(const Duration(milliseconds: 600));
    notifyListeners();
  }

  Future<void> _syncPendingActions() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    try {
      await propertyRepository.getProperties(online: true);
      _pendingActions = <PendingAction>[];
      _pendingActionsCount = 0;
      await pendingActionStore.writeAll(_pendingActions);
      await localStore.writePendingCount(_pendingActionsCount);
    } catch (_) {
      _pendingActions = _pendingActions.map((action) {
        final nextRetry = action.retryCount + 1;
        return action.copyWith(retryCount: nextRetry);
      }).where((action) => action.retryCount < 3).toList();
      _pendingActionsCount = _pendingActions.length;
      _lastActionError =
          _pendingActions.isEmpty ? null : 'Sync failed. Will retry automatically.';
      await pendingActionStore.writeAll(_pendingActions);
      await localStore.writePendingCount(_pendingActionsCount);
    }
  }
}
