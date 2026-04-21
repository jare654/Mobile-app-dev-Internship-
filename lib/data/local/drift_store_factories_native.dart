import 'favorite_drift_store.dart';
import 'favorite_store.dart';
import 'local_store.dart';
import 'pending_action_drift_store.dart';
import 'pending_action_store.dart';
import 'property_drift_store.dart';
import 'property_store.dart';
import 'drift_store_factories.dart';

class NativeDriftFactory implements DriftStoreFactory {
  @override
  Future<PropertyStore?> createPropertyStore(LocalStore localStore) async {
    return DriftPropertyStore.open(localStore: localStore);
  }

  @override
  Future<FavoriteStore?> createFavoriteStore(LocalStore localStore) async {
    return DriftFavoriteStore.open(localStore: localStore);
  }

  @override
  Future<PendingActionStore?> createPendingActionStore(LocalStore localStore) async {
    return DriftPendingActionStore.open(localStore: localStore);
  }
}

DriftStoreFactory getPlatformFactory() => NativeDriftFactory();
