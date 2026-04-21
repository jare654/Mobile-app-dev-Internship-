import 'local_store.dart';

abstract class FavoriteStore {
  Future<void> writeAll(Set<String> favorites);
  Future<Set<String>> readAll();
}

class HiveFavoriteStore implements FavoriteStore {
  HiveFavoriteStore(this.localStore);

  final LocalStore localStore;

  @override
  Future<void> writeAll(Set<String> favorites) async {
    await localStore.writeFavorites(favorites);
  }

  @override
  Future<Set<String>> readAll() async {
    return localStore.readFavorites();
  }
}
