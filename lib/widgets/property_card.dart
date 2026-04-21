// lib/features/properties/presentation/widgets/property_card.dart

import 'package:flutter/material.dart';

import '../core/entities.dart';
import '../core/localization/app_strings.dart';
import '../core/utils/app_formatters.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.isFavorite,
    required this.isLoggedIn,
    this.onTap,
    this.onFavoriteTap,
  });

  final Property property;
  final bool isFavorite;
  final bool isLoggedIn;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);
    final title = strings.isAmharic ? (property.titleAm ?? property.title) : property.title;
    final location = strings.isAmharic ? (property.locationAm ?? property.location) : property.location;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _PropertyImage(
                      url: property.imageUrls.isNotEmpty
                          ? property.imageUrls.first
                          : null,
                    ),
                    // Favorite button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _FavoriteChip(
                        isFavorite: isFavorite,
                        isLoggedIn: isLoggedIn,
                        onTap: onFavoriteTap,
                      ),
                    ),
                    // Price badge
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppFormatters.compactBirr(property.price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (property.bedrooms != null || property.areaSqM != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          if (property.bedrooms != null)
                            _Spec(
                              icon: Icons.bed_rounded,
                              label: '${property.bedrooms}',
                            ),
                          if (property.bathrooms != null) ...[
                            const SizedBox(width: 10),
                            _Spec(
                              icon: Icons.bathtub_rounded,
                              label: '${property.bathrooms}',
                            ),
                          ],
                          if (property.areaSqM != null) ...[
                            const SizedBox(width: 10),
                            _Spec(
                              icon: Icons.straighten_rounded,
                              label: '${property.areaSqM!.toInt()} m²',
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Icon(
          Icons.home_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    if (url!.startsWith('http')) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _shimmer(context),
        errorBuilder: (ctx, error, stackTrace) => ColoredBox(
          color: Theme.of(ctx).colorScheme.surfaceContainerHigh,
          child: Icon(
            Icons.home_rounded,
            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Image.asset(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (ctx, error, stackTrace) => ColoredBox(
        color: Theme.of(ctx).colorScheme.surfaceContainerHigh,
        child: Icon(
          Icons.home_rounded,
          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _shimmer(BuildContext context) =>
      ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHigh);
}

class _FavoriteChip extends StatelessWidget {
  const _FavoriteChip({
    required this.isFavorite,
    required this.isLoggedIn,
    this.onTap,
  });

  final bool isFavorite;
  final bool isLoggedIn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isFavorite
              ? Colors.red.shade50
              : Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            key: ValueKey(isFavorite),
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? Colors.red : Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Skeleton card for loading state ──────────────────────────────

class PropertyCardSkeleton extends StatefulWidget {
  const PropertyCardSkeleton({super.key});

  @override
  State<PropertyCardSkeleton> createState() => _PropertyCardSkeletonState();
}

class _PropertyCardSkeletonState extends State<PropertyCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) {
        final base = isDark
            ? Color.lerp(
                const Color(0xFF1C1F2A),
                const Color(0xFF252836),
                _anim.value,
              )!
            : Color.lerp(
                const Color(0xFFE5E7EB),
                const Color(0xFFF3F4F6),
                _anim.value,
              )!;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ColoredBox(color: base),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(color: base, height: 14, width: 130),
                    const SizedBox(height: 6),
                    _SkeletonBox(color: base, height: 11, width: 90),
                    const SizedBox(height: 10),
                    _SkeletonBox(color: base, height: 11, width: 110),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.color,
    required this.height,
    required this.width,
  });
  final Color color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}
