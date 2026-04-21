import 'package:hive_flutter/hive_flutter.dart';

import '../../core/entities.dart';

class LocalStore {
  LocalStore(this.box) : _memory = null;

  LocalStore.memory() : box = null, _memory = <String, dynamic>{};

  final Box<dynamic>? box;
  final Map<String, dynamic>? _memory;

  static Future<LocalStore> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>('intern_property_app');
    return LocalStore(box);
  }

  dynamic _read(String key, {dynamic defaultValue}) {
    final memory = _memory;
    if (memory != null) {
      return memory.containsKey(key) ? memory[key] : defaultValue;
    }
    return box!.get(key, defaultValue: defaultValue);
  }

  Future<void> _write(String key, dynamic value) async {
    final memory = _memory;
    if (memory != null) {
      memory[key] = value;
      return;
    }
    await box!.put(key, value);
  }

  Set<String> readFavorites() {
    final raw = _read('favorites', defaultValue: <dynamic>[]) as List<dynamic>;
    return raw.map((item) => item.toString()).toSet();
  }

  Future<void> writeFavorites(Set<String> favorites) {
    return _write('favorites', favorites.toList());
  }

  Future<void> writePendingCount(int count) {
    return _write('pendingCount', count);
  }

  int readPendingCount() {
    return (_read('pendingCount', defaultValue: 0) as num).toInt();
  }

  Future<void> writePendingActions(List<PendingAction> actions) {
    final raw = actions
        .map(
          (action) => {
            'type': action.type.name,
            'payload': action.payload,
            'retryCount': action.retryCount,
          },
        )
        .toList();
    return _write('pendingActions', raw);
  }

  List<PendingAction> readPendingActions() {
    final raw = _read('pendingActions', defaultValue: <dynamic>[]) as List;
    return raw.whereType<Map>().map((item) {
      final typeRaw = item['type']?.toString() ?? 'sendInquiry';
      final payloadRaw = item['payload'];
      return PendingAction(
        type: PendingActionType.values.firstWhere(
          (value) => value.name == typeRaw,
          orElse: () => PendingActionType.sendInquiry,
        ),
        payload: payloadRaw is Map
            ? payloadRaw.map(
                (key, value) => MapEntry(key.toString(), value),
              )
            : <String, dynamic>{},
        retryCount: (item['retryCount'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<void> writeTheme(String value) => _write('themeMode', value);

  String readTheme() => _read('themeMode', defaultValue: 'system') as String;

  Future<void> writeLanguage(String value) => _write('language', value);

  String readLanguage() => _read('language', defaultValue: 'en') as String;

  Future<void> writeOnline(bool value) => _write('isOnline', value);

  bool readOnline() => _read('isOnline', defaultValue: true) as bool;

  Future<void> writeUser(Map<String, dynamic>? value) => _write('user', value);

  Map<String, dynamic>? readUser() {
    final raw = _read('user');
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Future<void> writeProperties(List<Map<String, dynamic>> value) {
    return _write('properties', value);
  }

  List<Map<String, dynamic>> readProperties() {
    final raw = _read('properties', defaultValue: <dynamic>[]) as List<dynamic>;
    return raw
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }
}
