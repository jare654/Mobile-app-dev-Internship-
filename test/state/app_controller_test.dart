import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intern_property_app/core/entities.dart';
import 'package:intern_property_app/core/localization/app_strings.dart';
import 'package:intern_property_app/data/local/local_store.dart';
import 'package:intern_property_app/data/local/pending_action_store.dart';
import 'package:intern_property_app/data/repositories/property_repository.dart';
import 'package:intern_property_app/data/local/favorite_store.dart';
import 'package:intern_property_app/data/local/property_store.dart';
import 'package:intern_property_app/state/app_controller.dart';

class _FakePropertyRepository implements PropertyRepository {
  _FakePropertyRepository({this.shouldThrow = false});

  final bool shouldThrow;

  @override
  Future<List<Property>> getProperties({required bool online}) async {
    if (shouldThrow) {
      throw Exception('failed');
    }
    return [
      Property(
        id: 'p1',
        title: 'Title',
        description: 'Desc',
        location: 'Bole',
        price: 1000,
        imageUrls: const ['img'],
        status: PropertyStatus.published,
        lastUpdated: DateTime(2026, 1, 1),
      ),
    ];
  }
}

void main() {
  group('AppController', () {
    test('optimistically toggles favorite and queues while offline', () async {
      final store = LocalStore.memory();
      final controller = AppController(
        localStore: store,
        propertyRepository: _FakePropertyRepository(),
        pendingActionStore: InMemoryPendingActionStore(),
        favoriteStore: HiveFavoriteStore(store),
      );
      await controller.initialize();
      await controller.toggleConnectivity(); // now offline

      await controller.toggleFavorite('p1');

      expect(controller.favoritedIds.contains('p1'), isTrue);
      expect(controller.pendingActionsCount, 1);
    });

    test('queues inquiry offline and does not queue online', () async {
      final store = LocalStore.memory();
      final controller = AppController(
        localStore: store,
        propertyRepository: _FakePropertyRepository(),
        pendingActionStore: InMemoryPendingActionStore(),
        favoriteStore: HiveFavoriteStore(store),
      );
      await controller.initialize();
      await controller.toggleConnectivity(); // offline

      await controller.queueInquiry('hello');
      expect(controller.pendingActionsCount, 1);

      await controller.toggleConnectivity(); // online, sync clears
      await controller.queueInquiry('hello again');
      expect(controller.pendingActionsCount, 0);
    });

    test('persists language and theme preferences', () async {
      final store = LocalStore.memory();
      final controller = AppController(
        localStore: store,
        propertyRepository: _FakePropertyRepository(),
        pendingActionStore: InMemoryPendingActionStore(),
        favoriteStore: HiveFavoriteStore(store),
      );
      await controller.initialize();

      await controller.setLanguage(AppLanguage.amharic);
      await controller.setThemeMode(ThemeMode.dark);

      expect(store.readLanguage(), 'am');
      expect(store.readTheme(), 'dark');
    });

    test('sets explicit property load error when repository fails', () async {
      final store = LocalStore.memory();
      final controller = AppController(
        localStore: store,
        propertyRepository: _FakePropertyRepository(shouldThrow: true),
        pendingActionStore: InMemoryPendingActionStore(),
        favoriteStore: HiveFavoriteStore(store),
      );

      await controller.initialize();

      expect(controller.propertyLoadError, isNotNull);
      expect(controller.properties, isEmpty);
    });
  });
}
