import 'favorite_store.dart';
import 'local_store.dart';
import 'pending_action_store.dart';
import 'property_store.dart';
import 'drift_store_factories.dart';

class StubDriftFactory implements DriftStoreFactory {
  @override
  Future<PropertyStore?> createPropertyStore(LocalStore localStore) async => null;

  @override
  Future<FavoriteStore?> createFavoriteStore(LocalStore localStore) async => null;

  @override
  Future<PendingActionStore?> createPendingActionStore(LocalStore localStore) async => null;
}

DriftStoreFactory getPlatformFactory() => StubDriftFactory();
