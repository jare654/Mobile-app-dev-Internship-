import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'local_store.dart';
import 'favorite_store.dart';

class DriftFavoriteStore implements FavoriteStore {
  DriftFavoriteStore._(this._db);

  final Database _db;

  static Future<DriftFavoriteStore> open({
    required LocalStore localStore,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'intern_property_app.sqlite');
    final db = sqlite3.open(dbPath);
    final store = DriftFavoriteStore._(db);
    store._initSchema();
    await store._migrateFromHiveIfNeeded(localStore);
    return store;
  }

  void _initSchema() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS favorites(
        id TEXT PRIMARY KEY
      );
    ''');
  }

  Future<void> _migrateFromHiveIfNeeded(LocalStore localStore) async {
    final existing = await readAll();
    if (existing.isNotEmpty) {
      return;
    }
    final hiveFavorites = localStore.readFavorites();
    if (hiveFavorites.isEmpty) {
      return;
    }
    await writeAll(hiveFavorites);
    await localStore.writeFavorites(const {});
  }

  @override
  Future<Set<String>> readAll() async {
    final result = _db.select('SELECT id FROM favorites;');
    return result.map((row) => row['id'] as String).toSet();
  }

  @override
  Future<void> writeAll(Set<String> favorites) async {
    _db.execute('BEGIN TRANSACTION;');
    try {
      _db.execute('DELETE FROM favorites;');
      final stmt = _db.prepare('INSERT INTO favorites(id) VALUES(?);');
      try {
        for (final id in favorites) {
          stmt.execute([id]);
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
