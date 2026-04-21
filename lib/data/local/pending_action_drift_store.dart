import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../core/entities.dart';
import 'local_store.dart';
import 'pending_action_store.dart';

class DriftPendingActionStore implements PendingActionStore {
  DriftPendingActionStore._(this._db);

  final Database _db;

  static Future<DriftPendingActionStore> open({
    required LocalStore localStore,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'intern_property_app.sqlite');
    final db = sqlite3.open(dbPath);
    final store = DriftPendingActionStore._(db);
    store._initSchema();
    await store._migrateFromHiveIfNeeded(localStore);
    return store;
  }

  void _initSchema() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS pending_actions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        payload TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0
      );
    ''');
  }

  Future<void> _migrateFromHiveIfNeeded(LocalStore localStore) async {
    final existing = readAllSync();
    if (existing.isNotEmpty) {
      return;
    }
    final hiveActions = localStore.readPendingActions();
    if (hiveActions.isEmpty) {
      return;
    }
    await writeAll(hiveActions);
    await localStore.writePendingActions(const []);
  }

  List<PendingAction> readAllSync() {
    final result = _db.select(
      'SELECT type, payload, retry_count FROM pending_actions ORDER BY id ASC;',
    );
    return result.map((row) {
      final typeRaw = row['type'] as String;
      final payloadRaw = row['payload'] as String;
      return PendingAction(
        type: PendingActionType.values.firstWhere(
          (value) => value.name == typeRaw,
          orElse: () => PendingActionType.sendInquiry,
        ),
        payload: (jsonDecode(payloadRaw) as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        ),
        retryCount: (row['retry_count'] as int?) ?? 0,
      );
    }).toList();
  }

  @override
  Future<void> clear() async {
    _db.execute('DELETE FROM pending_actions;');
  }

  @override
  Future<List<PendingAction>> readAll() async {
    return readAllSync();
  }

  @override
  Future<void> writeAll(List<PendingAction> actions) async {
    _db.execute('BEGIN TRANSACTION;');
    try {
      _db.execute('DELETE FROM pending_actions;');
      final stmt = _db.prepare(
        '''
        INSERT INTO pending_actions(type, payload, retry_count)
        VALUES(?, ?, ?);
        ''',
      );
      try {
        for (final action in actions) {
          stmt.execute([
            action.type.name,
            jsonEncode(action.payload),
            action.retryCount,
          ]);
        }
      } finally {
        stmt.close();
      }
      _db.execute('COMMIT;');
    } catch (_) {
      _db.execute('ROLLBACK;');
      rethrow;
    }
  }
}
