// lib/features/properties/presentation/screens/property_list_screen.dart

import 'package:flutter/material.dart';

import '../core/entities.dart';
import '../core/localization/app_strings.dart';
import '../core/utils/app_formatters.dart';
import '../providers/mock_providers.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/offline_banner.dart';
import '../widgets/property_card.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({
    super.key,
    this.onPropertyTap,
    this.isLoggedIn = false,
    this.isOnline = true,
    this.syncState = BannerSyncState.offline,
    this.favoritedIds = const {},
    this.onFavoriteTap,
    this.onLoginTap,
    this.properties = const [],
    this.isLoading = false,
    this.onRefresh,
    this.errorMessage,
  });

  final ValueChanged<Property>? onPropertyTap;
  final bool isLoggedIn;
  final bool isOnline;
  final BannerSyncState syncState;
  final Set<String> favoritedIds;
  final ValueChanged<String>? onFavoriteTap;
  final VoidCallback? onLoginTap;
  final List<Property> properties;
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final String? errorMessage;

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  PropertyFilter _filter = PropertyFilter.empty;

  List<Property> get _filtered {
    final strings = AppStrings.of(context);
    return widget.properties.where((p) {
      if (_filter.location != null) {
        final query = _filter.location!.toLowerCase();
        final matchEn = p.location.toLowerCase().contains(query);
        final matchAm = p.locationAm?.toLowerCase().contains(query) ?? false;
        if (!matchEn && !matchAm) return false;
      }
      if (_filter.minPrice != null && p.price < _filter.minPrice!) {
        return false;
      }
      if (_filter.maxPrice != null && p.price > _filter.maxPrice!) {
        return false;
      }
      if (_filter.minBedrooms != null &&
          (p.bedrooms ?? 0) < _filter.minBedrooms!) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final showBanner =
        !widget.isOnline || widget.syncState == BannerSyncState.syncing;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        child: CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.discover,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_filtered.length} ${strings.properties}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              actions: [
                // Filter button with active dot
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      tooltip: strings.filterProperties,
                      onPressed: () => FilterSheet.show(
                        context,
                        current: _filter,
                        onApply: (f) => setState(() => _filter = f),
                        strings: strings,
                      ),
                    ),
                    if (_filter.isActive)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                if (!widget.isLoggedIn)
                  TextButton(
                    onPressed: widget.onLoginTap,
                    child: Text(strings.signIn),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        fakeUser.name[0],
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Offline Banner ────────────────────────────────────
            if (showBanner)
              SliverToBoxAdapter(
                child: OfflineBanner(
                  isVisible: true,
                  syncState: widget.syncState,
                ),
              ),

            // ── Active Filters ────────────────────────────────────
            if (_filter.isActive)
              SliverToBoxAdapter(
                child: _ActiveFilterChips(
                  filter: _filter,
                  onClear: () => setState(() => _filter = PropertyFilter.empty),
                ),
              ),

            // ── Body ──────────────────────────────────────────────
            if (widget.isLoading)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const PropertyCardSkeleton(),
                    childCount: 6,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                ),
              )
            else if (widget.errorMessage != null)
              SliverFillRemaining(
                child: _ErrorState(message: widget.errorMessage!),
              )
            else if (_filtered.isEmpty)
              SliverFillRemaining(child: _EmptyState(strings: strings))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final property = _filtered[i];
                    return PropertyCard(
                      property: property,
                      isFavorite: widget.favoritedIds.contains(property.id),
                      isLoggedIn: widget.isLoggedIn,
                      onTap: () => widget.onPropertyTap?.call(property),
                      onFavoriteTap: () =>
                          widget.onFavoriteTap?.call(property.id),
                    );
                  }, childCount: _filtered.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Active filter chips row ───────────────────────────────────────

class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({required this.filter, required this.onClear});

  final PropertyFilter filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (filter.location != null)
            _Chip(label: filter.location!, icon: Icons.location_on_rounded),
          if (filter.minPrice != null || filter.maxPrice != null)
            _Chip(
              label:
                  '${_fmt(filter.minPrice ?? 0)} - ${_fmt(filter.maxPrice ?? 50000000)}',
              icon: Icons.payments_rounded,
            ),
          if (filter.minBedrooms != null)
            _Chip(
              label: '${filter.minBedrooms}+ ${strings.beds}',
              icon: Icons.bed_rounded,
            ),
          const SizedBox(width: 4),
          ActionChip(
            label: Text(strings.clearAll),
            avatar: const Icon(Icons.close, size: 14),
            onPressed: onClear,
            side: BorderSide(
              color: theme.colorScheme.error.withValues(alpha: 0.4),
            ),
            labelStyle: TextStyle(color: theme.colorScheme.error),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    return AppFormatters.compactBirr(v);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            strings.emptyResults,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.emptyResultsHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
