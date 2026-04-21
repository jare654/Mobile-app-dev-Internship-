// lib/features/properties/presentation/screens/property_detail_screen.dart

import 'package:flutter/material.dart';

import '../core/entities.dart';
import '../core/localization/app_strings.dart';
import '../core/utils/app_formatters.dart';
import '../providers/mock_providers.dart';
import '../widgets/property_image_carousel.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    this.isFavorite = false,
    this.isLoggedIn = false,
    this.onFavoriteTap,
    this.onInquirySubmit,
    this.onLoginTap,
    this.onBack,
  });

  final String propertyId;
  final bool isFavorite;
  final bool isLoggedIn;
  final VoidCallback? onFavoriteTap;
  final ValueChanged<String>? onInquirySubmit;
  final VoidCallback? onLoginTap;
  final VoidCallback? onBack;

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  Property? _property;
  bool _isLoading = true;
  String? _errorMessage;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final property = fakeProperties.firstWhere((p) => p.id == widget.propertyId);
      if (!mounted) return;
      setState(() {
        _property = property;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load this property.';
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite() {
    if (!widget.isLoggedIn) {
      widget.onLoginTap?.call();
      return;
    }
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteTap?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? AppStrings.of(context).addedToFavourites
              : AppStrings.of(context).removedFromFavourites,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _DetailSkeleton();
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 52),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    final property = _property!;
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final title = strings.isAmharic ? (property.titleAm ?? property.title) : property.title;
    final location = strings.isAmharic ? (property.locationAm ?? property.location) : property.location;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Image Header ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _CircleBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap:
                        widget.onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: _CircleBtn(
                      icon: Icons.share_rounded,
                      onTap: () {}, // share
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: PropertyImageCarousel(
                    imageUrls: property.imageUrls,
                    height: 300,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Status badge ──────────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _StatusBadge(status: property.status),
                      ),
                      const SizedBox(height: 10),

                      // ── Title + price ─────────────────────────
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Price ─────────────────────────────────
                      Text(
                        AppFormatters.birr(property.price),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Specs row ─────────────────────────────
                      if (property.bedrooms != null ||
                          property.bathrooms != null ||
                          property.areaSqM != null)
                        _SpecsRow(property: property),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // ── Description ───────────────────────────
                      Text(
                        strings.description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.propertyDescription(
                          property.id,
                          property.description,
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Last updated ──────────────────────────
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${strings.updated} ${_timeAgo(property.lastUpdated)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Fixed Bottom CTA ───────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomCTA(
              isLoggedIn: widget.isLoggedIn,
              isFavorite: _isFavorite,
              onFavoriteTap: _toggleFavorite,
              onInquiry: () => _showInquirySheet(context, title),
              onLoginTap: widget.onLoginTap,
              strings: strings,
            ),
          ),
        ],
      ),
    );
  }

  void _showInquirySheet(BuildContext context, String title) {
    if (!widget.isLoggedIn) {
      widget.onLoginTap?.call();
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InquirySheet(
        propertyTitle: title,
        onSubmit: widget.onInquirySubmit,
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    return AppFormatters.timeAgo(dt);
  }
}

// ── Supporting widgets ────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final PropertyStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPublished = status == PropertyStatus.published;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        isPublished
            ? AppStrings.of(context).published
            : AppStrings.of(context).archived,
        style: TextStyle(
          color: isPublished ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SpecsRow extends StatelessWidget {
  const _SpecsRow({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1F2A)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (property.bedrooms != null)
            _SpecItem(
              icon: Icons.bed_rounded,
              value: '${property.bedrooms}',
              label: AppStrings.of(context).bedrooms,
            ),
          if (property.bathrooms != null)
            _SpecItem(
              icon: Icons.bathtub_rounded,
              value: '${property.bathrooms}',
              label: AppStrings.of(context).bathrooms,
            ),
          if (property.areaSqM != null)
            _SpecItem(
              icon: Icons.straighten_rounded,
              value: '${property.areaSqM!.toInt()}',
              label: AppStrings.of(context).squareMeters,
            ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  const _SpecItem({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _BottomCTA extends StatelessWidget {
  const _BottomCTA({
    required this.isLoggedIn,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onInquiry,
    required this.strings,
    this.onLoginTap,
  });

  final bool isLoggedIn;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onInquiry;
  final AppStrings strings;
  final VoidCallback? onLoginTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Favourite toggle
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                color: isFavorite ? Colors.red : theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isFavorite ? Colors.red.shade50 : Colors.transparent,
            ),
            child: IconButton(
              onPressed: onFavoriteTap,
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite ? Colors.red : theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Inquiry button
          Expanded(
            child: FilledButton.icon(
              onPressed: onInquiry,
              icon: const Icon(Icons.mail_outline_rounded, size: 18),
              label: Text(
                isLoggedIn ? strings.sendInquiry : strings.signInToInquire,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Inquiry bottom sheet ──────────────────────────────────────────

class _InquirySheet extends StatefulWidget {
  const _InquirySheet({required this.propertyTitle, this.onSubmit});
  final String propertyTitle;
  final ValueChanged<String>? onSubmit;

  @override
  State<_InquirySheet> createState() => _InquirySheetState();
}

class _InquirySheetState extends State<_InquirySheet> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulate
    if (mounted) {
      widget.onSubmit?.call(_ctrl.text.trim());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, mq.viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            AppStrings.of(context).sendInquiryTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.propertyTitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppStrings.of(context).inquiryHint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          // Offline note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.of(context).inquiryOfflineNote,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _sending ? null : _send,
            child: _sending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(AppStrings.of(context).send),
          ),
        ],
      ),
    );
  }
}

// ── Detail skeleton ────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          // Image placeholder
          Container(height: 300, color: theme.colorScheme.surfaceContainerHigh),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmer(theme, 200, 24),
                const SizedBox(height: 10),
                _shimmer(theme, 140, 16),
                const SizedBox(height: 16),
                _shimmer(theme, 100, 32),
                const SizedBox(height: 20),
                _shimmer(theme, double.infinity, 14),
                const SizedBox(height: 8),
                _shimmer(theme, double.infinity, 14),
                const SizedBox(height: 8),
                _shimmer(theme, 200, 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer(ThemeData t, double w, double h) => Container(
    width: w,
    height: h,
    margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(
      color: t.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}
