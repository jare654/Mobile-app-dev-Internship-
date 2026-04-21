# Flutter Offline-First Property Listing App
## Production Architecture, Structure & Implementation Guide

> **Tech Choices Summary:** Riverpod (state management) · Clean Architecture · Drift (local DB) · Dio (networking) · Connectivity Plus (network awareness)

---

## Table of Contents

1. [Architecture Decision Records (ADRs)](#1-architecture-decision-records)
2. [Project Structure](#2-project-structure)
3. [Data Layer](#3-data-layer)
4. [Domain Layer](#4-domain-layer)
5. [Application Layer (State)](#5-application-layer)
6. [Presentation Layer](#6-presentation-layer)
7. [Offline-First Strategy](#7-offline-first-strategy)
8. [Dependency Injection](#8-dependency-injection)
9. [Networking & Interceptors](#9-networking--interceptors)
10. [Action Queue & Sync Engine](#10-action-queue--sync-engine)
11. [Screen Implementations](#11-screen-implementations)
12. [Testing Strategy](#12-testing-strategy)
13. [pubspec.yaml](#13-pubspecyaml)
14. [Commit & Git Strategy](#14-commit--git-strategy)

---

## 1. Architecture Decision Records

### ADR-001 — State Management: Riverpod

**Chosen:** `flutter_riverpod` + `riverpod_annotation`

**Rationale:**
- Compile-safe providers eliminate runtime `ProviderNotFoundException` errors that plague Provider.
- `AsyncNotifier` and `StreamNotifier` natively model loading/error/data states, satisfying the challenge's state-handling requirement without boilerplate.
- `ref.invalidate()` and `ref.watch()` make cache invalidation after sync trivial.
- Better testability than Bloc for this scope — no need to wire `BlocProvider` trees; just override providers in tests.
- Riverpod's `keepAlive` / `autoDispose` gives fine-grained control over memory, important for a list app with image-heavy cards.

**Rejected alternatives:**
- **Bloc/Cubit** — great for large teams with strict event contracts; overkill for an intern challenge and adds boilerplate without extra correctness guarantees at this scale.
- **Provider** — deprecated patterns, no compile-time safety, harder to compose async state.

---

### ADR-002 — Local Storage: Drift (over Hive / SQLite)

**Chosen:** `drift` (formerly Moor)

**Rationale:**
- Typed SQL via Dart code generation — schema changes are caught at compile time.
- Built-in support for reactive streams (`watchSingleOrNull`, `watch`) which feed directly into Riverpod `StreamProvider`s.
- Transactions and foreign keys work correctly, critical for the action queue.
- SQLite under the hood — portable, zero native dependencies beyond `sqlite3_flutter_libs`.

**Rejected alternatives:**
- **Hive** — faster key-value reads, but no relational queries, no reactive streams without adapters, and schema migrations are manual.
- **Raw SQLite** — Drift is a thin, typed wrapper; raw SQLite gives no benefit here.

---

### ADR-003 — Networking: Dio

**Chosen:** `dio`

**Rationale:**
- Interceptor chain supports logging, auth token injection, retry-on-failure, and offline-guard in a clean pipeline.
- `CancelToken` support for cancelling in-flight requests on screen disposal.
- `Response<T>` generic typing integrates cleanly with the repository pattern.

---

### ADR-004 — Clean Architecture (not MVVM)

**Rationale:**
- The explicit Domain layer (use cases + entities) enforces that business rules never reference Flutter or Dio — fully testable with plain Dart tests.
- Dependency inversion via abstract repository interfaces means the data source (remote vs. local) can be swapped without touching business logic.
- More scalable than MVVM for a multi-feature app where offline sync, favorites, and auth are orthogonal concerns.

---

## 2. Project Structure

```
lib/
├── main.dart
├── bootstrap.dart                  # App initialization (DI, DB, Hive)
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── hive_box_names.dart
│   ├── error/
│   │   ├── exceptions.dart         # ServerException, CacheException, NetworkException
│   │   └── failures.dart           # Failure sealed class hierarchy
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── logging_interceptor.dart
│   │   │   ├── retry_interceptor.dart
│   │   │   └── offline_guard_interceptor.dart
│   │   └── connectivity_service.dart
│   ├── sync/
│   │   ├── action_queue.dart       # Pending offline actions
│   │   ├── sync_engine.dart        # Processes queue when online
│   │   └── sync_status.dart        # Enum: idle | syncing | failed
│   ├── storage/
│   │   └── drift_database.dart     # AppDatabase + all DAOs
│   └── utils/
│       ├── either.dart             # Functional Either<L,R>
│       └── extensions.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart   # abstract
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           └── login_screen.dart
│   │
│   ├── properties/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── property_remote_datasource.dart
│   │   │   │   └── property_local_datasource.dart  # Drift DAO wrapper
│   │   │   ├── models/
│   │   │   │   └── property_model.dart              # JSON + Drift table
│   │   │   └── repositories/
│   │   │       └── property_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── property.dart
│   │   │   ├── repositories/
│   │   │   │   └── property_repository.dart         # abstract
│   │   │   └── usecases/
│   │   │       ├── get_properties_usecase.dart
│   │   │       ├── get_property_detail_usecase.dart
│   │   │       └── filter_properties_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── property_list_provider.dart
│   │       │   └── property_filter_provider.dart
│   │       ├── screens/
│   │       │   ├── property_list_screen.dart
│   │       │   └── property_detail_screen.dart
│   │       └── widgets/
│   │           ├── property_card.dart
│   │           ├── property_image_carousel.dart
│   │           ├── filter_sheet.dart
│   │           └── offline_banner.dart
│   │
│   ├── favorites/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── favorites_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── favorites_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── favorites_repository.dart
│   │   │   └── usecases/
│   │   │       ├── toggle_favorite_usecase.dart
│   │   │       └── get_favorites_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── favorites_provider.dart
│   │       └── screens/
│   │           └── favorites_screen.dart
│   │
│   └── profile/
│       └── presentation/
│           ├── providers/
│           │   └── profile_provider.dart
│           └── screens/
│               └── profile_screen.dart
│
└── routing/
    ├── app_router.dart             # GoRouter configuration
    └── route_guards.dart           # Auth guard
```

---

## 3. Data Layer

### 3.1 Drift Database Schema

```dart
// lib/core/storage/drift_database.dart

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'drift_database.g.dart';

// ─── Tables ────────────────────────────────────────────────────

class Properties extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get location => text()();
  RealColumn get price => real()();
  TextColumn get imageUrls => text()(); // JSON-encoded List<String>
  TextColumn get status => text()(); // 'published' | 'archived'
  DateTimeColumn get lastUpdated => dateTime()();
  BoolColumn get isCached => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get propertyId => text().references(Properties, #id)();
  TextColumn get userId => text()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'UNIQUE (property_id, user_id)',
  ];
}

class PendingActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // 'toggle_favorite' | 'send_inquiry'
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  // 'pending' | 'processing' | 'failed'
}

// ─── Database ──────────────────────────────────────────────────

@DriftDatabase(tables: [Properties, Favorites, PendingActions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Future migrations go here
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'property_app.db');
  }
}
```

### 3.2 Property DAO

```dart
// Attach to AppDatabase via @DriftAccessor

@DriftAccessor(tables: [Properties, Favorites])
class PropertyDao extends DatabaseAccessor<AppDatabase>
    with _$PropertyDaoMixin {
  PropertyDao(super.db);

  // ── Reactive stream for list screen ──
  Stream<List<Property>> watchPublishedProperties() {
    return (select(properties)
          ..where((p) => p.status.equals('published'))
          ..orderBy([(p) => OrderingTerm.desc(p.lastUpdated)]))
        .watch();
  }

  // ── Single property for detail screen ──
  Stream<Property?> watchProperty(String id) {
    return (select(properties)..where((p) => p.id.equals(id)))
        .watchSingleOrNull();
  }

  // ── Upsert from remote ──
  Future<void> upsertProperties(List<PropertiesCompanion> rows) {
    return batch((b) {
      b.insertAllOnConflictUpdate(properties, rows);
    });
  }

  // ── Favorites join ──
  Stream<List<PropertyWithFavorite>> watchPropertiesWithFavorites(
      String userId) {
    final query = select(properties).join([
      leftOuterJoin(
        favorites,
        favorites.propertyId.equalsExp(properties.id) &
            favorites.userId.equals(userId),
      )
    ])
      ..where(properties.status.equals('published'));

    return query.watch().map((rows) => rows.map((row) {
          return PropertyWithFavorite(
            property: row.readTable(properties),
            isFavorite: row.readTableOrNull(favorites) != null,
          );
        }).toList());
  }
}
```

### 3.3 Property Model (JSON ↔ Entity ↔ Drift)

```dart
// lib/features/properties/data/models/property_model.dart

import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/property.dart';
import '../../../../core/storage/drift_database.dart';

part 'property_model.freezed.dart';
part 'property_model.g.dart';

@freezed
class PropertyModel with _$PropertyModel {
  const factory PropertyModel({
    required String id,
    required String title,
    required String description,
    required String location,
    required double price,
    required List<String> imageUrls,
    required String status,
    required DateTime lastUpdated,
  }) = _PropertyModel;

  factory PropertyModel.fromJson(Map<String, dynamic> json) =>
      _$PropertyModelFromJson(json);
}

extension PropertyModelX on PropertyModel {
  /// To clean domain entity
  Property toEntity() => Property(
        id: id,
        title: title,
        description: description,
        location: location,
        price: price,
        imageUrls: imageUrls,
        status: PropertyStatus.values.byName(status),
        lastUpdated: lastUpdated,
      );

  /// To Drift companion for upsert
  PropertiesCompanion toDriftCompanion() => PropertiesCompanion.insert(
        id: id,
        title: title,
        description: description,
        location: location,
        price: price,
        imageUrls: jsonEncode(imageUrls),
        status: status,
        lastUpdated: lastUpdated,
      );
}

extension PropertyDriftX on Property {
  /// From Drift row back to entity (Drift Property → domain Property)
  static Property fromDrift(Property row) => Property(
        id: row.id,
        title: row.title,
        description: row.description,
        location: row.location,
        price: row.price,
        imageUrls: (jsonDecode(row.imageUrls) as List).cast<String>(),
        status: PropertyStatus.values.byName(row.status),
        lastUpdated: row.lastUpdated,
      );
}
```

### 3.4 Remote Data Source

```dart
// lib/features/properties/data/datasources/property_remote_datasource.dart

abstract interface class PropertyRemoteDataSource {
  Future<List<PropertyModel>> fetchProperties({int page, int limit});
  Future<PropertyModel> fetchPropertyById(String id);
}

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  const PropertyRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<PropertyModel>> fetchProperties({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.properties,
      queryParameters: {'page': page, 'limit': limit},
    );
    return (response.data['data'] as List)
        .map((j) => PropertyModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PropertyModel> fetchPropertyById(String id) async {
    final response = await _dio.get('${ApiConstants.properties}/$id');
    return PropertyModel.fromJson(response.data as Map<String, dynamic>);
  }
}
```

### 3.5 Repository Implementation (Offline-First Core)

```dart
// lib/features/properties/data/repositories/property_repository_impl.dart

class PropertyRepositoryImpl implements PropertyRepository {
  const PropertyRepositoryImpl({
    required this.remote,
    required this.local,
    required this.connectivity,
  });

  final PropertyRemoteDataSource remote;
  final PropertyLocalDataSource local;
  final ConnectivityService connectivity;

  /// Returns a stream from local DB (always).
  /// Triggers a background remote fetch when online to refresh the cache.
  @override
  Stream<Either<Failure, List<Property>>> watchProperties() async* {
    // 1. Immediately emit cached data from Drift
    yield* local.watchProperties().map(
      (rows) => Right<Failure, List<Property>>(
        rows.map(PropertyDriftX.fromDrift).toList(),
      ),
    );
    // 2. Background refresh
    _refreshIfOnline();
  }

  Future<void> _refreshIfOnline() async {
    if (!await connectivity.isConnected) return;
    try {
      final models = await remote.fetchProperties();
      await local.upsertProperties(
        models.map((m) => m.toDriftCompanion()).toList(),
      );
    } on DioException catch (e) {
      // Silently fail — stale cache is acceptable, user sees offline banner
      debugPrint('Background refresh failed: $e');
    }
  }

  @override
  Future<Either<Failure, Property>> getPropertyById(String id) async {
    // Try cache first
    final cached = await local.getPropertyById(id);
    if (cached != null) {
      _refreshSingleIfOnline(id); // fire and forget
      return Right(PropertyDriftX.fromDrift(cached));
    }
    // Fallback to remote if not cached
    if (!await connectivity.isConnected) {
      return Left(NetworkFailure('No internet and no cached data for $id'));
    }
    try {
      final model = await remote.fetchPropertyById(id);
      await local.upsertProperties([model.toDriftCompanion()]);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  Future<void> _refreshSingleIfOnline(String id) async {
    if (!await connectivity.isConnected) return;
    try {
      final model = await remote.fetchPropertyById(id);
      await local.upsertProperties([model.toDriftCompanion()]);
    } catch (_) {}
  }
}
```

---

## 4. Domain Layer

### 4.1 Property Entity

```dart
// lib/features/properties/domain/entities/property.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'property.freezed.dart';

enum PropertyStatus { published, archived }

@freezed
class Property with _$Property {
  const factory Property({
    required String id,
    required String title,
    required String description,
    required String location,
    required double price,
    required List<String> imageUrls,
    required PropertyStatus status,
    required DateTime lastUpdated,
  }) = _Property;
}
```

### 4.2 Repository Interface

```dart
// lib/features/properties/domain/repositories/property_repository.dart

abstract interface class PropertyRepository {
  Stream<Either<Failure, List<Property>>> watchProperties();
  Future<Either<Failure, Property>> getPropertyById(String id);
}
```

### 4.3 Use Cases

```dart
// lib/features/properties/domain/usecases/get_properties_usecase.dart

class GetPropertiesUseCase {
  const GetPropertiesUseCase(this._repository);
  final PropertyRepository _repository;

  Stream<Either<Failure, List<Property>>> call(PropertyFilter filter) {
    return _repository.watchProperties().map((result) =>
      result.map((properties) => _applyFilter(properties, filter)),
    );
  }

  List<Property> _applyFilter(List<Property> all, PropertyFilter filter) {
    return all.where((p) {
      final matchesLocation = filter.location == null ||
          p.location.toLowerCase().contains(filter.location!.toLowerCase());
      final matchesMinPrice =
          filter.minPrice == null || p.price >= filter.minPrice!;
      final matchesMaxPrice =
          filter.maxPrice == null || p.price <= filter.maxPrice!;
      return matchesLocation && matchesMinPrice && matchesMaxPrice;
    }).toList();
  }
}

// ─── Filter value object ────────────────────────────────────────
class PropertyFilter {
  const PropertyFilter({this.location, this.minPrice, this.maxPrice});
  final String? location;
  final double? minPrice;
  final double? maxPrice;

  static const empty = PropertyFilter();
}
```

```dart
// lib/features/favorites/domain/usecases/toggle_favorite_usecase.dart

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase({
    required this.favoritesRepository,
    required this.actionQueue,
  });

  final FavoritesRepository favoritesRepository;
  final ActionQueue actionQueue;

  Future<Either<Failure, void>> call({
    required String propertyId,
    required String userId,
    required bool currentValue,
  }) async {
    // 1. Optimistic update in local DB immediately
    await favoritesRepository.toggleLocal(
      propertyId: propertyId,
      userId: userId,
      value: !currentValue,
    );

    // 2. Queue remote sync action
    await actionQueue.enqueue(
      PendingActionType.toggleFavorite,
      payload: {
        'propertyId': propertyId,
        'userId': userId,
        'value': !currentValue,
      },
    );

    return const Right(null);
  }
}
```

---

## 5. Application Layer

### 5.1 Property List Provider

```dart
// lib/features/properties/presentation/providers/property_list_provider.dart

@riverpod
class PropertyList extends _$PropertyList {
  @override
  Stream<List<Property>> build() {
    final filter = ref.watch(propertyFilterProvider);
    final useCase = ref.watch(getPropertiesUseCaseProvider);

    return useCase(filter).map((result) => result.fold(
          (failure) => throw failure,
          (properties) => properties,
        ));
  }
}

// Filter state
@riverpod
class PropertyFilter extends _$PropertyFilter {
  @override
  PropertyFilterModel build() => const PropertyFilterModel.empty();

  void updateLocation(String? location) =>
      state = state.copyWith(location: location);

  void updatePriceRange(double? min, double? max) =>
      state = state.copyWith(minPrice: min, maxPrice: max);

  void reset() => state = const PropertyFilterModel.empty();
}
```

### 5.2 Favorites Provider

```dart
@riverpod
class Favorites extends _$Favorites {
  @override
  Stream<List<Property>> build() {
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return const Stream.empty();

    final useCase = ref.watch(getFavoritesUseCaseProvider);
    return useCase(user.id).map((r) => r.getOrElse((_) => []));
  }

  Future<void> toggle(String propertyId) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;

    final isFav = state.valueOrNull?.any((p) => p.id == propertyId) ?? false;
    final useCase = ref.read(toggleFavoriteUseCaseProvider);

    // Optimistic: Riverpod update happens inside ToggleFavoriteUseCase
    // via local DB → stream re-emits automatically
    await useCase(
      propertyId: propertyId,
      userId: user.id,
      currentValue: isFav,
    );
  }
}
```

### 5.3 Connectivity Provider

```dart
@riverpod
Stream<ConnectivityStatus> connectivityStatus(Ref ref) {
  return ref.watch(connectivityServiceProvider).statusStream;
}

// Derived: simple bool
@riverpod
bool isOnline(Ref ref) {
  return ref.watch(connectivityStatusProvider).valueOrNull ==
      ConnectivityStatus.online;
}

// Sync status
@riverpod
class SyncStatus extends _$SyncStatus {
  @override
  SyncState build() => SyncState.idle;

  void setSyncing() => state = SyncState.syncing;
  void setIdle() => state = SyncState.idle;
  void setFailed(String message) => state = SyncState.failed(message);
}
```

---

## 6. Presentation Layer

### 6.1 Property List Screen

```dart
// lib/features/properties/presentation/screens/property_list_screen.dart

class PropertyListScreen extends ConsumerWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertyListProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline indicator banner
          AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: isOnline ? const Offset(0, -1) : Offset.zero,
            child: const OfflineBanner(),
          ),

          Expanded(
            child: propertiesAsync.when(
              data: (properties) => properties.isEmpty
                  ? const _EmptyState()
                  : _PropertyGrid(properties: properties),
              loading: () => const _LoadingGrid(),
              error: (err, _) => _ErrorState(
                message: err is Failure ? err.message : err.toString(),
                onRetry: () => ref.invalidate(propertyListProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyGrid extends StatelessWidget {
  const _PropertyGrid({required this.properties});
  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Pull-to-refresh — repo will re-fetch from remote
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: properties.length,
        itemBuilder: (ctx, i) => PropertyCard(property: properties[i]),
      ),
    );
  }
}
```

### 6.2 Offline Banner Widget

```dart
// lib/features/properties/presentation/widgets/offline_banner.dart

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);

    final (color, icon, label) = switch (syncState) {
      SyncState.idle => (Colors.orange.shade700, Icons.wifi_off, 'Offline — showing cached data'),
      SyncState.syncing => (Colors.blue.shade700, Icons.sync, 'Syncing…'),
      SyncState.failed(:final message) => (Colors.red.shade700, Icons.error_outline, 'Sync failed: $message'),
    };

    return Material(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6.3 Property Card with Optimistic Favorite

```dart
class PropertyCard extends ConsumerWidget {
  const PropertyCard({super.key, required this.property});
  final Property property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final isFav = favoritesAsync.valueOrNull?.any((p) => p.id == property.id) ?? false;

    return GestureDetector(
      onTap: () => context.push('/properties/${property.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with cached_network_image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: property.imageUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ColoredBox(color: Colors.black12),
                    errorWidget: (_, __, ___) => const Icon(Icons.home),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteButton(
                      propertyId: property.id,
                      isFavorite: isFav,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge),
                  Text(property.location,
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    '\$${property.price.toStringAsFixed(0)}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.propertyId, required this.isFavorite});
  final String propertyId;
  final bool isFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Auth guard
        final user = ref.read(authProvider).valueOrNull;
        if (user == null) {
          context.push('/login');
          return;
        }
        // Optimistic toggle — UI updates immediately via Drift stream
        ref.read(favoritesProvider.notifier).toggle(propertyId);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          key: ValueKey(isFavorite),
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.white,
          shadows: const [Shadow(blurRadius: 4)],
        ),
      ),
    );
  }
}
```

---

## 7. Offline-First Strategy

### Strategy Overview

```
┌─────────────────────────────────────────────────────┐
│                   UI Layer                          │
│   Always reads from LOCAL (Drift) streams           │
└────────────────────┬────────────────────────────────┘
                     │ Drift reactive stream
┌────────────────────▼────────────────────────────────┐
│              Repository                             │
│  1. Emit local cache immediately                    │
│  2. Trigger background remote fetch (if online)     │
│  3. Write response back to local DB                 │
│  4. Stream re-emits updated data automatically      │
└────────────────────┬────────────────────────────────┘
                     │
         ┌───────────▼────────────┐
         │  Online?               │
         │  YES → Remote fetch    │
         │  NO  → Skip, show      │
         │        offline banner  │
         └────────────────────────┘
```

### Write Path (Offline Actions)

```
User taps Favorite (offline)
         │
         ▼
  1. Optimistic local DB update (instant UI feedback)
         │
         ▼
  2. PendingAction persisted to Drift (PendingActions table)
         │
         ▼
  3. ConnectivityService detects online
         │
         ▼
  4. SyncEngine dequeues and processes PendingActions
         │
         ├── Success → delete from PendingActions
         └── Failure → increment retryCount, mark 'failed' if > 3
```

---

## 8. Dependency Injection

```dart
// lib/bootstrap.dart — run before runApp

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Drift DB singleton
  final db = AppDatabase();

  // 2. Initialize Dio
  final dio = DioClient.create();

  runApp(
    ProviderScope(
      overrides: [
        // Provide singletons that need async init
        appDatabaseProvider.overrideWithValue(db),
        dioProvider.overrideWithValue(dio),
      ],
      child: const PropertyApp(),
    ),
  );
}
```

```dart
// Provider declarations — split by feature

// ─── Core ───────────────────────────────────────────────────────
@riverpod
AppDatabase appDatabase(Ref ref) => throw UnimplementedError();

@riverpod
Dio dio(Ref ref) => throw UnimplementedError();

@riverpod
ConnectivityService connectivityService(Ref ref) =>
    ConnectivityService();

// ─── Properties ─────────────────────────────────────────────────
@riverpod
PropertyRemoteDataSource propertyRemoteDataSource(Ref ref) =>
    PropertyRemoteDataSourceImpl(ref.watch(dioProvider));

@riverpod
PropertyLocalDataSource propertyLocalDataSource(Ref ref) =>
    PropertyLocalDataSourceImpl(ref.watch(appDatabaseProvider).propertyDao);

@riverpod
PropertyRepository propertyRepository(Ref ref) =>
    PropertyRepositoryImpl(
      remote: ref.watch(propertyRemoteDataSourceProvider),
      local: ref.watch(propertyLocalDataSourceProvider),
      connectivity: ref.watch(connectivityServiceProvider),
    );

@riverpod
GetPropertiesUseCase getPropertiesUseCase(Ref ref) =>
    GetPropertiesUseCase(ref.watch(propertyRepositoryProvider));

// ─── Favorites ───────────────────────────────────────────────────
@riverpod
ActionQueue actionQueue(Ref ref) =>
    ActionQueue(ref.watch(appDatabaseProvider).pendingActionDao);

@riverpod
ToggleFavoriteUseCase toggleFavoriteUseCase(Ref ref) =>
    ToggleFavoriteUseCase(
      favoritesRepository: ref.watch(favoritesRepositoryProvider),
      actionQueue: ref.watch(actionQueueProvider),
    );
```

---

## 9. Networking & Interceptors

### Dio Client Setup

```dart
// lib/core/network/dio_client.dart

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),       // 1st: inject Bearer token
      OfflineGuardInterceptor(), // 2nd: reject if offline (avoids pointless calls)
      RetryInterceptor(dio),   // 3rd: retry 3x on 5xx / timeout
      LoggingInterceptor(),    // 4th: log requests in debug mode
    ]);

    return dio;
  }
}
```

### Auth Interceptor

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = SecureStorage.getToken(); // from flutter_secure_storage
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired — clear and redirect to login
      SecureStorage.clearToken();
      GetIt.I<AppRouter>().go('/login');
    }
    handler.next(err);
  }
}
```

### Offline Guard Interceptor

```dart
class OfflineGuardInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
        true,
      );
      return;
    }
    handler.next(options);
  }
}
```

### Retry Interceptor

```dart
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);
  final Dio _dio;

  static const _maxRetries = 3;
  static const _retryStatuses = {500, 502, 503, 504};

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount =
        (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    final shouldRetry = retryCount < _maxRetries &&
        (_retryStatuses.contains(err.response?.statusCode) ||
            err.type == DioExceptionType.connectionTimeout);

    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    await Future.delayed(Duration(seconds: 1 << retryCount)); // exponential backoff

    final options = err.requestOptions
      ..extra['retryCount'] = retryCount + 1;

    try {
      final response = await _dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
```

---

## 10. Action Queue & Sync Engine

### Action Queue

```dart
// lib/core/sync/action_queue.dart

enum PendingActionType { toggleFavorite, sendInquiry }

class ActionQueue {
  const ActionQueue(this._dao);
  final PendingActionDao _dao;

  Future<void> enqueue(
    PendingActionType type,
    Map<String, dynamic> payload,
  ) async {
    await _dao.insert(
      PendingActionsCompanion.insert(
        type: type.name,
        payload: jsonEncode(payload),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<PendingAction>> getPending() => _dao.getPendingActions();

  Future<void> markDone(int id) => _dao.deleteById(id);

  Future<void> markFailed(int id, int retryCount) =>
      _dao.updateStatus(id, 'failed', retryCount);
}
```

### Sync Engine

```dart
// lib/core/sync/sync_engine.dart

class SyncEngine {
  SyncEngine({
    required this.actionQueue,
    required this.favoritesRepository,
    required this.connectivity,
  });

  final ActionQueue actionQueue;
  final FavoritesRepository favoritesRepository;
  final ConnectivityService connectivity;

  StreamSubscription<ConnectivityStatus>? _sub;

  void start() {
    _sub = connectivity.statusStream.listen((status) {
      if (status == ConnectivityStatus.online) _processQueue();
    });
  }

  void dispose() => _sub?.cancel();

  Future<void> _processQueue() async {
    final pending = await actionQueue.getPending();
    if (pending.isEmpty) return;

    for (final action in pending) {
      try {
        await _dispatch(action);
        await actionQueue.markDone(action.id);
      } catch (e) {
        final newCount = action.retryCount + 1;
        if (newCount >= 3) {
          await actionQueue.markFailed(action.id, newCount);
        } else {
          await actionQueue.markFailed(action.id, newCount);
        }
      }
    }
  }

  Future<void> _dispatch(PendingAction action) async {
    final payload = jsonDecode(action.payload) as Map<String, dynamic>;

    switch (PendingActionType.values.byName(action.type)) {
      case PendingActionType.toggleFavorite:
        await favoritesRepository.syncToggle(
          propertyId: payload['propertyId'] as String,
          userId: payload['userId'] as String,
          value: payload['value'] as bool,
        );
      case PendingActionType.sendInquiry:
        // handle inquiry sync
        break;
    }
  }
}
```

---

## 11. Screen Implementations

### 11.1 Property Detail Screen

```dart
class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({super.key, required this.propertyId});
  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyDetailProvider(propertyId));

    return Scaffold(
      body: propertyAsync.when(
        data: (property) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              flexibleSpace: FlexibleSpaceBar(
                background: PropertyImageCarousel(urls: property.imageUrls),
              ),
              actions: [
                _FavoriteButton(propertyId: property.id, isFavorite: false),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 14),
                      Text(property.location),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      '\$${property.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    const Divider(height: 24),
                    Text(property.description),
                    const SizedBox(height: 24),
                    _InquiryButton(propertyId: property.id),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const PropertyDetailSkeleton(),
        error: (e, _) => _ErrorState(message: e.toString()),
      ),
    );
  }
}
```

### 11.2 Routing (GoRouter)

```dart
// lib/routing/app_router.dart

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/properties',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login');

      if (!isLoggedIn && state.matchedLocation == '/favorites') {
        return '/login?redirect=${state.matchedLocation}';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/properties',
            builder: (_, __) => const PropertyListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    PropertyDetailScreen(propertyId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/favorites',
            builder: (_, __) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
    ],
  );
}
```

---

## 12. Testing Strategy

### 12.1 Unit Tests — Use Cases

```dart
// test/features/properties/domain/get_properties_usecase_test.dart

void main() {
  late GetPropertiesUseCase useCase;
  late MockPropertyRepository mockRepo;

  setUp(() {
    mockRepo = MockPropertyRepository();
    useCase = GetPropertiesUseCase(mockRepo);
  });

  test('emits filtered properties by location', () async {
    final properties = [
      fakeProperty(id: '1', location: 'Amsterdam'),
      fakeProperty(id: '2', location: 'Rotterdam'),
    ];

    when(() => mockRepo.watchProperties())
        .thenAnswer((_) => Stream.value(Right(properties)));

    final result = await useCase(
      const PropertyFilter(location: 'Amsterdam'),
    ).first;

    expect(result.getOrElse((_) => []).length, equals(1));
    expect(result.getOrElse((_) => []).first.id, equals('1'));
  });

  test('passes through Failure from repository', () async {
    when(() => mockRepo.watchProperties())
        .thenAnswer((_) => Stream.value(Left(NetworkFailure('Offline'))));

    final result = await useCase(PropertyFilter.empty).first;

    expect(result.isLeft(), isTrue);
  });
}
```

### 12.2 Unit Tests — Action Queue

```dart
void main() {
  late ActionQueue queue;
  late MockPendingActionDao mockDao;

  setUp(() {
    mockDao = MockPendingActionDao();
    queue = ActionQueue(mockDao);
  });

  test('enqueue serializes payload as JSON', () async {
    when(() => mockDao.insert(any())).thenAnswer((_) async => 1);

    await queue.enqueue(
      PendingActionType.toggleFavorite,
      {'propertyId': 'abc', 'value': true},
    );

    final captured = verify(() => mockDao.insert(captureAny())).captured.single
        as PendingActionsCompanion;
    final payload = jsonDecode(captured.payload.value) as Map;
    expect(payload['propertyId'], equals('abc'));
  });
}
```

### 12.3 Widget Tests

```dart
void main() {
  testWidgets('OfflineBanner is visible when offline', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineProvider.overrideWithValue(false),
          syncStatusProvider.overrideWith((ref) => SyncState.idle),
        ],
        child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
      ),
    );

    expect(find.text('Offline — showing cached data'), findsOneWidget);
  });
}
```

---

## 13. pubspec.yaml

```yaml
name: property_app
description: Offline-first property listing app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # ── State Management ─────────────────────────────────────
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # ── Navigation ───────────────────────────────────────────
  go_router: ^14.2.7

  # ── Local Storage ────────────────────────────────────────
  drift: ^2.19.1
  drift_flutter: ^0.2.1
  sqlite3_flutter_libs: ^0.5.23
  path_provider: ^2.1.3
  path: ^1.9.0

  # ── Networking ───────────────────────────────────────────
  dio: ^5.5.0+1
  connectivity_plus: ^6.0.3

  # ── Secure Storage ───────────────────────────────────────
  flutter_secure_storage: ^9.2.2

  # ── Models ───────────────────────────────────────────────
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  # ── Images ───────────────────────────────────────────────
  cached_network_image: ^3.3.1

  # ── Utils ────────────────────────────────────────────────
  dartz: ^0.10.1             # Either<L,R>
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code generation
  build_runner: ^2.4.11
  drift_dev: ^2.19.1
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.3
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.13

  # Testing
  mocktail: ^1.0.4
  fake_async: ^1.3.1

flutter:
  uses-material-design: true
```

---

## 14. Commit & Git Strategy

### Branch Structure

```
main                    ← production-ready, protected
└── develop             ← integration branch
    ├── feat/data-layer
    ├── feat/property-list
    ├── feat/favorites-offline
    ├── feat/sync-engine
    └── feat/connectivity-ui
```

### Recommended Commit Sequence (5 days)

```
Day 1 — Foundation
  chore: initialise Flutter project with clean architecture structure
  chore: add pubspec dependencies and run pub get
  feat(core): implement Drift schema (Properties, Favorites, PendingActions)
  feat(core): configure Dio client with interceptor chain
  feat(core): implement ConnectivityService with stream

Day 2 — Data & Domain
  feat(properties): add PropertyModel with JSON and Drift converters
  feat(properties): implement PropertyRemoteDataSource
  feat(properties): implement PropertyLocalDataSource (Drift DAO)
  feat(properties): implement PropertyRepositoryImpl (offline-first)
  feat(properties): add GetPropertiesUseCase with filtering

Day 3 — State & Screens
  feat(properties): add Riverpod providers (list, filter, detail)
  feat(properties): implement PropertyListScreen with 3 states
  feat(properties): implement PropertyDetailScreen with carousel
  feat(connectivity): implement OfflineBanner widget

Day 4 — Favorites & Sync
  feat(favorites): implement FavoritesRepository with local-first
  feat(favorites): add ToggleFavoriteUseCase with optimistic update
  feat(sync): implement ActionQueue and SyncEngine
  feat(auth): add login screen and auth provider

Day 5 — Polish & Tests
  feat(routing): configure GoRouter with auth guard
  feat(profile): add ProfileScreen with logout
  test(core): unit tests for use cases and action queue
  test(widgets): widget tests for OfflineBanner and PropertyCard
  docs: add README with setup instructions and architecture overview
  chore: generate APK / web build
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION                               │
│  Screens  ─→  Riverpod Providers  ─→  Use Cases                │
└──────────────────────────┬──────────────────────────────────────┘
                           │ calls
┌──────────────────────────▼──────────────────────────────────────┐
│                       DOMAIN                                    │
│  Entities  ·  Repository Interfaces  ·  Use Cases               │
│  (pure Dart — no Flutter, no Dio, no Drift)                     │
└──────────────────────────┬──────────────────────────────────────┘
                           │ implemented by
┌──────────────────────────▼──────────────────────────────────────┐
│                        DATA                                     │
│                                                                 │
│  ┌──────────────────┐       ┌──────────────────────────────┐   │
│  │ Remote Sources   │       │  Local Sources (Drift)        │   │
│  │  Dio + models    │       │  DAOs + reactive streams      │   │
│  └────────┬─────────┘       └──────────────┬───────────────┘   │
│           │                                │                   │
│  ┌────────▼────────────────────────────────▼───────────────┐   │
│  │              Repository Impl                             │   │
│  │  - emit local stream immediately                         │   │
│  │  - background remote fetch if online                     │   │
│  │  - write back to Drift → stream re-emits                 │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      SYNC ENGINE (cross-cutting)                │
│  ActionQueue (Drift) → SyncEngine → Dispatches on reconnect     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 15. Dark Mode Support (Bonus)

### 15.1 Theme Provider

```dart
// lib/core/theme/theme_provider.dart

@riverpod
class ThemeMode extends _$ThemeMode {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    // Read persisted preference synchronously on startup
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    return switch (stored) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system, // default: follow system
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, mode.name);
  }

  void toggle() {
    setTheme(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

// SharedPreferences provider — initialised in bootstrap.dart
@riverpod
SharedPreferences sharedPreferences(Ref ref) => throw UnimplementedError();
```

Bootstrap initialisation:

```dart
// lib/bootstrap.dart

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final dio = DioClient.create();
  final prefs = await SharedPreferences.getInstance(); // ← add this

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        dioProvider.overrideWithValue(dio),
        sharedPreferencesProvider.overrideWithValue(prefs), // ← add this
      ],
      child: const PropertyApp(),
    ),
  );
}
```

---

### 15.2 Theme Definitions

```dart
// lib/core/theme/app_theme.dart

class AppTheme {
  AppTheme._();

  // ── Shared ────────────────────────────────────────────────────
  static const _primaryColor = Color(0xFF1E6FFF);
  static const _fontFamily = 'Inter';

  // ── Light ─────────────────────────────────────────────────────
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ),
    cardTheme: const CardTheme(
      elevation: 2,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
  );

  // ── Dark ──────────────────────────────────────────────────────
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ),
    cardTheme: const CardTheme(
      elevation: 2,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
  );
}
```

---

### 15.3 Wiring into MaterialApp

```dart
// lib/app.dart

class PropertyApp extends ConsumerWidget {
  const PropertyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Property App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,       // ← switches between light / dark / system
      routerConfig: router,
    );
  }
}
```

---

### 15.4 Theme Toggle in Profile / Settings Screen

```dart
// lib/features/profile/presentation/screens/profile_screen.dart (relevant section)

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);

    return ListTile(
      leading: Icon(
        switch (current) {
          ThemeMode.dark => Icons.dark_mode,
          ThemeMode.light => Icons.light_mode,
          ThemeMode.system => Icons.brightness_auto,
        },
      ),
      title: const Text('Appearance'),
      subtitle: Text(current.name[0].toUpperCase() + current.name.substring(1)),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16)),
          ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto, size: 16)),
          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16)),
        ],
        selected: {current},
        onSelectionChanged: (s) =>
            ref.read(themeModeProvider.notifier).setTheme(s.first),
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
```

---

### 15.5 Dark-Mode-Aware Offline Banner

The `OfflineBanner` already uses `Material` with explicit colors, so it renders correctly in both modes. For any custom widgets that use hardcoded colors, replace them with `ColorScheme` tokens:

```dart
// ❌ Avoid — hardcoded, breaks in dark mode
color: Colors.grey.shade100

// ✅ Correct — adapts automatically
color: Theme.of(context).colorScheme.surfaceContainerLow

// ✅ For text on primary
color: Theme.of(context).colorScheme.onPrimary

// ✅ For card backgrounds
color: Theme.of(context).colorScheme.surfaceContainerHigh
```

---

### 15.6 Add to pubspec.yaml

```yaml
dependencies:
  shared_preferences: ^2.3.2   # ← add for theme persistence
```

---

*Document version 1.1 — all four bonus features covered: unit tests · custom interceptors · background sync · dark mode.*
