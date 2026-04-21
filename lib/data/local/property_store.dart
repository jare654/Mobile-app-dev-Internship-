import '../../core/entities.dart';
import 'local_store.dart';

abstract class PropertyStore {
  Future<void> writeAll(List<Property> properties);
  Future<List<Property>> readAll();
}

class HivePropertyStore implements PropertyStore {
  HivePropertyStore(this.localStore);

  final LocalStore localStore;

  @override
  Future<void> writeAll(List<Property> properties) async {
    final raw = properties.map(PropertySeedMapper.toJson).toList();
    await localStore.writeProperties(raw);
  }

  @override
  Future<List<Property>> readAll() async {
    final raw = localStore.readProperties();
    return raw.map(PropertySeedMapper.fromJson).toList();
  }
}

class PropertySeedMapper {
  static Property fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      titleAm: json['titleAm'] as String?,
      description: json['description'] as String,
      location: json['location'] as String,
      locationAm: json['locationAm'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrls: (json['imageUrls'] as List<dynamic>).cast<String>(),
      status: json['status'] == 'archived'
          ? PropertyStatus.archived
          : PropertyStatus.published,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      bedrooms: (json['bedrooms'] as num?)?.toInt(),
      bathrooms: (json['bathrooms'] as num?)?.toInt(),
      areaSqM: (json['areaSqM'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic> toJson(Property property) {
    return {
      'id': property.id,
      'title': property.title,
      'titleAm': property.titleAm,
      'description': property.description,
      'location': property.location,
      'locationAm': property.locationAm,
      'price': property.price,
      'imageUrls': property.imageUrls,
      'status': property.status.name,
      'lastUpdated': property.lastUpdated.toIso8601String(),
      'bedrooms': property.bedrooms,
      'bathrooms': property.bathrooms,
      'areaSqM': property.areaSqM,
    };
  }
}
