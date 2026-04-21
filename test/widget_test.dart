import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intern_property_app/core/localization/app_strings.dart';
import 'package:intern_property_app/core/network/dio_client.dart';
import 'package:intern_property_app/data/local/local_store.dart';
import 'package:intern_property_app/data/local/pending_action_store.dart';
import 'package:intern_property_app/data/repositories/property_repository.dart';
import 'package:intern_property_app/data/local/favorite_store.dart';
import 'package:intern_property_app/data/local/property_store.dart';
import 'package:intern_property_app/state/app_controller.dart';

void main() {
  test('controller loads Addis properties and persists settings', () async {
    final localStore = LocalStore.memory();
    final controller = AppController(
      localStore: localStore,
      propertyRepository: PropertyRepositoryImpl(
        propertyStore: HivePropertyStore(localStore),
        dioClient: DioClient(),
      ),
      pendingActionStore: InMemoryPendingActionStore(),
      favoriteStore: HiveFavoriteStore(localStore),
    );

    await controller.initialize();
    expect(controller.properties, isNotEmpty);
    expect(
      controller.properties.any(
        (property) => property.location.contains('Addis Ababa'),
      ),
      isTrue,
    );

    await controller.setLanguage(AppLanguage.amharic);
    await controller.setThemeMode(ThemeMode.dark);

    expect(localStore.readLanguage(), 'am');
    expect(localStore.readTheme(), 'dark');
  });
}
