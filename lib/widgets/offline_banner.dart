// lib/features/properties/presentation/widgets/offline_banner.dart

import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';

enum BannerSyncState { offline, syncing, failed }

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.isVisible,
    this.syncState = BannerSyncState.offline,
    this.failureMessage,
  });

  final bool isVisible;
  final BannerSyncState syncState;
  final String? failureMessage;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      offset: isVisible ? Offset.zero : const Offset(0, -1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 320),
        opacity: isVisible ? 1 : 0,
        child: _BannerContent(
          syncState: syncState,
          failureMessage: failureMessage,
        ),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({required this.syncState, this.failureMessage});

  final BannerSyncState syncState;
  final String? failureMessage;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final (bg, fg, icon, label) = switch (syncState) {
      BannerSyncState.offline => (
        const Color(0xFFF59E0B),
        Colors.white,
        Icons.wifi_off_rounded,
        strings.offlineCached,
      ),
      BannerSyncState.syncing => (
        const Color(0xFF3B82F6),
        Colors.white,
        Icons.sync_rounded,
        strings.syncingChanges,
      ),
      BannerSyncState.failed => (
        const Color(0xFFEF4444),
        Colors.white,
        Icons.error_outline_rounded,
        failureMessage ?? strings.syncFailed,
      ),
    };

    return Material(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (syncState == BannerSyncState.syncing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              else
                Icon(icon, color: fg, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (syncState == BannerSyncState.offline)
                Text(
                  'CACHED',
                  style: TextStyle(
                    color: fg.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
