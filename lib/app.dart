import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/app_strings.dart';
import 'providers/app_riverpod_providers.dart';
import 'screens/favorites_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/property_detail_screen.dart';
import 'screens/property_list_screen.dart';
import 'state/app_controller_scope.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/offline_banner.dart';

class PropertyApp extends ConsumerWidget {
  const PropertyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final strings = AppStrings(controller.language);
    return AppControllerScope(
      controller: controller,
      child: MaterialApp(
        title: strings.appTitle,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: controller.themeMode,
        debugShowCheckedModeBanner: false,
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  BannerSyncState? _bannerState(AppController controller) {
    if (!controller.isOnline) {
      return BannerSyncState.offline;
    }
    if (controller.pendingActionsCount > 0) {
      return BannerSyncState.syncing;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final strings = AppStrings.of(context);
    final selectedProperty = controller.selectedProperty;
    final showNav = !controller.showAuth && selectedProperty == null;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(
            '${controller.selectedTab}-${controller.showAuth}-${controller.selectedPropertyId}-${controller.language.name}',
          ),
          child: controller.showAuth
              ? LoginScreen(
                  isRegisterMode: controller.isRegisterMode,
                  onLoginSuccess:
                      ({
                        required String email,
                        required String password,
                        String? name,
                      }) => controller.login(
                        email: email,
                        password: password,
                        name: name,
                      ),
                  onRegisterSuccess:
                      ({
                        required String name,
                        required String email,
                        required String password,
                      }) => controller.register(
                        name: name,
                        email: email,
                        password: password,
                      ),
                  onContinueAsGuest: controller.closeAuth,
                  onToggleMode: controller.switchAuthMode,
                )
              : selectedProperty != null
              ? PropertyDetailScreen(
                  propertyId: selectedProperty.id,
                  isLoggedIn: controller.isLoggedIn,
                  isFavorite: controller.favoritedIds.contains(
                    selectedProperty.id,
                  ),
                  onFavoriteTap: () {
                    controller.toggleFavorite(selectedProperty.id);
                  },
                  onInquirySubmit: (message) async {
                    await controller.queueInquiry(message);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          controller.isOnline
                              ? strings.inquirySent
                              : strings.inquiryQueued,
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onLoginTap: () => controller.openLogin(),
                  onBack: controller.closeProperty,
                )
              : _BodyByTab(
                  controller: controller,
                  bannerState: _bannerState(controller),
                ),
        ),
      ),
      persistentFooterButtons: showNav
          ? [
              SizedBox(
                height: 28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'DEV: ',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    _DevToggle(
                      label: controller.isOnline ? '🌐 Online' : '📵 Offline',
                      onTap: () {
                        controller.toggleConnectivity().then((_) {
                          if (!context.mounted) return;
                          if (controller.isOnline) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(strings.queuedActionsSynced),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _DevToggle(
                      label: controller.isLoggedIn ? '👤 User' : '👁 Guest',
                      onTap: () {
                        if (controller.isLoggedIn) {
                          controller.logout();
                        } else {
                          controller.openLogin();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _DevToggle(
                      label: controller.language == AppLanguage.amharic
                          ? 'አማ'
                          : 'EN',
                      onTap: () {
                        final nextLanguage =
                            controller.language == AppLanguage.english
                            ? AppLanguage.amharic
                            : AppLanguage.english;
                        controller.setLanguage(nextLanguage);
                      },
                    ),
                  ],
                ),
              ),
            ]
          : null,
      persistentFooterAlignment: AlignmentDirectional.center,
      bottomNavigationBar: showNav
          ? NavigationBar(
              selectedIndex: controller.selectedTab,
              onDestinationSelected: controller.selectTab,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.search_rounded),
                  selectedIcon: const Icon(Icons.search_rounded),
                  label: strings.discover,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.favorite_border_rounded),
                  selectedIcon: const Icon(Icons.favorite_rounded),
                  label: strings.favourites,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: strings.profile,
                ),
              ],
            )
          : null,
    );
  }
}

class _BodyByTab extends StatelessWidget {
  const _BodyByTab({required this.controller, required this.bannerState});

  final AppController controller;
  final BannerSyncState? bannerState;

  @override
  Widget build(BuildContext context) {
    return switch (controller.selectedTab) {
      0 => PropertyListScreen(
        isLoggedIn: controller.isLoggedIn,
        isOnline: controller.isOnline,
        syncState: bannerState ?? BannerSyncState.offline,
        favoritedIds: controller.favoritedIds,
        properties: controller.properties,
        isLoading: controller.isLoadingProperties,
        onRefresh: controller.refreshProperties,
        errorMessage: controller.propertyLoadError,
        onPropertyTap: controller.openProperty,
        onFavoriteTap: (id) {
          controller.toggleFavorite(id);
        },
        onLoginTap: () => controller.openLogin(),
      ),
      1 => FavoritesScreen(
        isLoggedIn: controller.isLoggedIn,
        properties: controller.properties,
        favoritedIds: controller.favoritedIds,
        hasPendingSync: controller.pendingActionsCount > 0,
        onPropertyTap: controller.openProperty,
        onFavoriteTap: (id) {
          controller.toggleFavorite(id);
        },
        onLoginTap: () => controller.openLogin(),
      ),
      2 => ProfileScreen(
        isLoggedIn: controller.isLoggedIn,
        themeMode: controller.themeMode,
        appLanguage: controller.language,
        isOnline: controller.isOnline,
        currentUser: controller.currentUser,
        pendingActionsCount: controller.pendingActionsCount,
        onThemeChange: (mode) {
          controller.setThemeMode(mode);
        },
        onLanguageChange: (language) {
          controller.setLanguage(language);
        },
        onLogout: () {
          controller.logout();
        },
        onLogin: () => controller.openLogin(),
        onRegister: () => controller.openLogin(register: true),
        onToggleConnection: () {
          controller.toggleConnectivity();
        },
        actionErrorMessage: controller.lastActionError,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _DevToggle extends StatelessWidget {
  const _DevToggle({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}
