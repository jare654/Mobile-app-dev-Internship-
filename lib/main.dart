import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'data/local/drift_store_factories.dart';
import 'data/local/local_store.dart';
import 'data/local/favorite_store.dart';
import 'data/local/pending_action_store.dart';
import 'data/local/property_store.dart';
import 'data/repositories/property_repository.dart';
import 'providers/app_riverpod_providers.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStore = await LocalStore.open();
  final driftFactory = await getDriftFactory();

  PropertyStore propertyStore;
  try {
    propertyStore = (await driftFactory.createPropertyStore(localStore)) ??
        HivePropertyStore(localStore);
  } catch (_) {
    propertyStore = HivePropertyStore(localStore);
  }

  FavoriteStore favoriteStore;
  try {
    favoriteStore = (await driftFactory.createFavoriteStore(localStore)) ??
        HiveFavoriteStore(localStore);
  } catch (_) {
    favoriteStore = HiveFavoriteStore(localStore);
  }

  final propertyRepository = PropertyRepositoryImpl(
    propertyStore: propertyStore,
    dioClient: DioClient(),
  );

  PendingActionStore pendingActionStore;
  try {
    pendingActionStore =
        (await driftFactory.createPendingActionStore(localStore)) ??
            HivePendingActionStore(localStore);
  } catch (_) {
    // Keep app usable even if sqlite initialization fails.
    pendingActionStore = HivePendingActionStore(localStore);
  }

  final controller = AppController(
    localStore: localStore,
    propertyRepository: propertyRepository,
    pendingActionStore: pendingActionStore,
    favoriteStore: favoriteStore,
  );
  await controller.initialize();

  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(localStore),
        propertyStoreProvider.overrideWithValue(propertyStore),
        favoriteStoreProvider.overrideWithValue(favoriteStore),
        propertyRepositoryProvider.overrideWithValue(propertyRepository),
        pendingActionStoreProvider.overrideWithValue(pendingActionStore),
        appControllerProvider.overrideWith((ref) => controller),
      ],
      child: const PropertyApp(),
    ),
  );
}
