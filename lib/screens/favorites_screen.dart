// lib/features/favorites/presentation/screens/favorites_screen.dart

import 'package:flutter/material.dart';

import '../core/entities.dart';
import '../core/localization/app_strings.dart';
import '../widgets/property_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    this.isLoggedIn = false,
    this.favoritedIds = const {'1', '3'},
    this.onPropertyTap,
    this.onFavoriteTap,
    this.onLoginTap,
    this.hasPendingSync = false,
    this.properties = const [],
  });

  final bool isLoggedIn;
  final Set<String> favoritedIds;
  final ValueChanged<Property>? onPropertyTap;
  final ValueChanged<String>? onFavoriteTap;
  final VoidCallback? onLoginTap;
  final bool hasPendingSync;
  final List<Property> properties;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Set<String> _favoritedIds;

  @override
  void initState() {
    super.initState();
    _favoritedIds = Set.from(widget.favoritedIds);
  }

  @override
  void didUpdateWidget(covariant FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoritedIds != widget.favoritedIds) {
      _favoritedIds = Set.from(widget.favoritedIds);
    }
  }

  List<Property> get _favorites =>
      widget.properties.where((p) => _favoritedIds.contains(p.id)).toList();

  void _toggleFavorite(String id) {
    setState(() {
      if (_favoritedIds.contains(id)) {
        _favoritedIds.remove(id);
      } else {
        _favoritedIds.add(id);
      }
    });
    widget.onFavoriteTap?.call(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    if (!widget.isLoggedIn) {
      return _GuestPlaceholder(onLogin: widget.onLoginTap, strings: strings);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.favourites,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _favorites.length == 1
                      ? '1 ${strings.savedProperty}'
                      : '${_favorites.length} ${strings.savedProperties}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              if (widget.hasPendingSync)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Tooltip(
                    message: strings.pendingSync,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_favorites.isEmpty)
            SliverFillRemaining(child: _EmptyFavourites(strings: strings))
          else ...[
            // Pending sync notice
            if (widget.hasPendingSync)
              SliverToBoxAdapter(child: _PendingSyncBanner(strings: strings)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((ctx, i) {
                  final property = _favorites[i];
                  return PropertyCard(
                    property: property,
                    isFavorite: true,
                    isLoggedIn: true,
                    onTap: () => widget.onPropertyTap?.call(property),
                    onFavoriteTap: () => _toggleFavorite(property.id),
                  );
                }, childCount: _favorites.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Pending sync banner ───────────────────────────────────────────

class _PendingSyncBanner extends StatelessWidget {
  const _PendingSyncBanner({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_queue_rounded,
            size: 16,
            color: Colors.amber.shade800,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              strings.pendingSyncHint,
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────

class _EmptyFavourites extends StatelessWidget {
  const _EmptyFavourites({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 72,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            strings.noFavouritesYet,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.favouritesHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guest placeholder ─────────────────────────────────────────────

class _GuestPlaceholder extends StatelessWidget {
  const _GuestPlaceholder({this.onLogin, required this.strings});
  final VoidCallback? onLogin;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  strings.signInToViewFavourites,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  strings.guestSaveHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onLogin,
                  icon: const Icon(Icons.login_rounded),
                  label: Text(strings.signIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
