import 'favorite_store.dart';
import 'local_store.dart';
import 'pending_action_store.dart';
import 'property_store.dart';

import 'drift_store_factories_stub.dart'
    if (dart.library.io) 'drift_store_factories_native.dart';

abstract class DriftStoreFactory {
  Future<PropertyStore?> createPropertyStore(LocalStore localStore);
  Future<FavoriteStore?> createFavoriteStore(LocalStore localStore);
  Future<PendingActionStore?> createPendingActionStore(LocalStore localStore);
}

Future<DriftStoreFactory> getDriftFactory() async => getPlatformFactory();
