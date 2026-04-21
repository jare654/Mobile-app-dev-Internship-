// lib/core/entities.dart
// Shared domain entities — referenced across all screens

enum PropertyStatus { published, archived }

enum SyncState { idle, syncing, failed }

enum ConnectivityStatus { online, offline }
enum PendingActionType { toggleFavorite, sendInquiry }

class Property {
  const Property({
    required this.id,
    required this.title,
    this.titleAm,
    required this.description,
    required this.location,
    this.locationAm,
    required this.price,
    required this.imageUrls,
    required this.status,
    required this.lastUpdated,
    this.bedrooms,
    this.bathrooms,
    this.areaSqM,
  });

  final String id;
  final String title;
  final String? titleAm;
  final String description;
  final String location;
  final String? locationAm;
  final double price;
  final List<String> imageUrls;
  final PropertyStatus status;
  final DateTime lastUpdated;
  final int? bedrooms;
  final int? bathrooms;
  final double? areaSqM;
}

class User {
  const User({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;
}

class PropertyFilter {
  const PropertyFilter({
    this.location,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
  });

  static const empty = PropertyFilter();

  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;

  bool get isActive =>
      location != null ||
      minPrice != null ||
      maxPrice != null ||
      minBedrooms != null;

  PropertyFilter copyWith({
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    bool clearLocation = false,
    bool clearPrice = false,
    bool clearBedrooms = false,
  }) => PropertyFilter(
    location: clearLocation ? null : (location ?? this.location),
    minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
    maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
    minBedrooms: clearBedrooms ? null : (minBedrooms ?? this.minBedrooms),
  );
}

class PendingAction {
  const PendingAction({
    required this.type,
    required this.payload,
    this.retryCount = 0,
  });

  final PendingActionType type;
  final Map<String, dynamic> payload;
  final int retryCount;

  PendingAction copyWith({
    PendingActionType? type,
    Map<String, dynamic>? payload,
    int? retryCount,
  }) {
    return PendingAction(
      type: type ?? this.type,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
