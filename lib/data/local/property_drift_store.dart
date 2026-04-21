import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../core/entities.dart';
import 'local_store.dart';
import 'property_store.dart';

class DriftPropertyStore implements PropertyStore {
  DriftPropertyStore._(this._db);

  final Database _db;

  static Future<DriftPropertyStore> open({
    required LocalStore localStore,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'intern_property_app.sqlite');
    final db = sqlite3.open(dbPath);
    final store = DriftPropertyStore._(db);
    store._initSchema();
    await store._migrateFromHiveIfNeeded(localStore);
    return store;
  }

  void _initSchema() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS properties(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        title_am TEXT,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        location_am TEXT,
        price REAL NOT NULL,
        image_urls TEXT NOT NULL,
        status TEXT NOT NULL,
        last_updated TEXT NOT NULL,
        bedrooms INTEGER,
        bathrooms INTEGER,
        area_sq_m REAL
      );
    ''');
  }

  Future<void> _migrateFromHiveIfNeeded(LocalStore localStore) async {
    final existing = await readAll();
    if (existing.isNotEmpty) {
      return;
    }
    final hivePropertiesRaw = localStore.readProperties();
    if (hivePropertiesRaw.isEmpty) {
      return;
    }
    final hiveProperties = hivePropertiesRaw.map(PropertySeedMapper.fromJson).toList();
    await writeAll(hiveProperties);
    await localStore.writeProperties(const []);
  }

  @override
  Future<List<Property>> readAll() async {
    final result = _db.select('SELECT * FROM properties;');
    return result.map((row) {
      return Property(
        id: row['id'] as String,
        title: row['title'] as String,
        titleAm: row['title_am'] as String?,
        description: row['description'] as String,
        location: row['location'] as String,
        locationAm: row['location_am'] as String?,
        price: (row['price'] as num).toDouble(),
        imageUrls: (jsonDecode(row['image_urls'] as String) as List).cast<String>(),
        status: row['status'] == 'archived'
            ? PropertyStatus.archived
            : PropertyStatus.published,
        lastUpdated: DateTime.parse(row['last_updated'] as String),
        bedrooms: row['bedrooms'] as int?,
        bathrooms: row['bathrooms'] as int?,
        areaSqM: (row['area_sq_m'] as num?)?.toDouble(),
      );
    }).toList();
  }

  @override
  Future<void> writeAll(List<Property> properties) async {
    _db.execute('BEGIN TRANSACTION;');
    try {
      _db.execute('DELETE FROM properties;');
      final stmt = _db.prepare(
        '''
        INSERT INTO properties(
          id, title, title_am, description, location, location_am, price, image_urls, status, last_updated, bedrooms, bathrooms, area_sq_m
        ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        ''',
      );
      try {
        for (final property in properties) {
          stmt.execute([
            property.id,
            property.title,
            property.titleAm,
            property.description,
            property.location,
            property.locationAm,
            property.price,
            jsonEncode(property.imageUrls),
            property.status.name,
            property.lastUpdated.toIso8601String(),
            property.bedrooms,
            property.bathrooms,
            property.areaSqM,
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
