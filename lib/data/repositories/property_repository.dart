import '../../core/entities.dart';
import '../../core/network/dio_client.dart';
import '../../providers/mock_providers.dart';
import '../local/property_store.dart';

abstract class PropertyRepository {
  Future<List<Property>> getProperties({required bool online});
}

class PropertyRepositoryImpl implements PropertyRepository {
  PropertyRepositoryImpl({required this.propertyStore, required this.dioClient});

  final PropertyStore propertyStore;
  final DioClient dioClient;

  @override
  Future<List<Property>> getProperties({required bool online}) async {
    final cached = await propertyStore.readAll();
    if (cached.isNotEmpty) {
      if (!online) {
        return cached;
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 550));
    final remote = fakeProperties;
    await propertyStore.writeAll(remote);
    return remote;
  }
}
