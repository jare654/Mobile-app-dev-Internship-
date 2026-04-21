import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/local_store.dart';
import '../data/local/pending_action_store.dart';
import '../data/repositories/property_repository.dart';
import '../state/app_controller.dart';

import '../data/local/favorite_store.dart';
import '../data/local/property_store.dart';

final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('localStoreProvider must be overridden at bootstrap.');
});

final propertyStoreProvider = Provider<PropertyStore>((ref) {
  return HivePropertyStore(ref.watch(localStoreProvider));
});

final favoriteStoreProvider = Provider<FavoriteStore>((ref) {
  return HiveFavoriteStore(ref.watch(localStoreProvider));
});

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  throw UnimplementedError(
    'propertyRepositoryProvider must be overridden at bootstrap.',
  );
});

final pendingActionStoreProvider = Provider<PendingActionStore>((ref) {
  return HivePendingActionStore(ref.watch(localStoreProvider));
});

final appControllerProvider = ChangeNotifierProvider<AppController>((ref) {
  return AppController(
    localStore: ref.watch(localStoreProvider),
    propertyRepository: ref.watch(propertyRepositoryProvider),
    pendingActionStore: ref.watch(pendingActionStoreProvider),
    favoriteStore: ref.watch(favoriteStoreProvider),
  );
});
