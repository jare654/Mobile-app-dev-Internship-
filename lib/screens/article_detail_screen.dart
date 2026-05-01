// lib/screens/article_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_theme.dart';
import '../models/article.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/loading_shimmer.dart';
import 'web_view_screen.dart';

/// Full-detail view for a single [Article].
class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Add to history on screen entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HistoryProvider>().addToHistory(widget.article);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildBody(context)),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: _BackButton(),
      actions: [
        Consumer<BookmarksProvider>(
          builder: (context, provider, _) {
            final isSaved = provider.isBookmarked(widget.article);
            return IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isSaved ? AppTheme.accent : colorScheme.onSurface,
              ),
              tooltip: isSaved ? 'Remove Bookmark' : 'Save Article',
              onPressed: () => provider.toggleBookmark(widget.article),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.ios_share_rounded),
          tooltip: 'Share',
          onPressed: () => _shareArticle(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero image
                  CachedNetworkImage(
                    imageUrl: widget.article.urlToImage!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ShimmerBox(height: double.infinity),
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.surface,
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: theme.dividerColor,
                        size: 48,
                      ),
                    ),
                  ),
                  // Gradient scrim so AppBar icons remain legible
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xCC0D1117),
                          Colors.transparent,
                          Color(0xDD0D1117),
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Article body ───────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Source + date row ─────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SourceBadge(sourceName: widget.article.sourceName),
              const SizedBox(width: 10),
              const Spacer(),
              Text(
                _formatDate(widget.article.publishedAt),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Title ─────────────────────────────────────────────────────
          Text(
            widget.article.title,
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),

          // ── Author ────────────────────────────────────────────────────
          if (widget.article.author != null) ...[
            Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    size: 14, color: AppTheme.textCaption),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'By ${widget.article.author}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSecond,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // ── Divider ───────────────────────────────────────────────────
          const Divider(),
          const SizedBox(height: 16),

          // ── Description ───────────────────────────────────────────────
          if (widget.article.description != null) ...[
            Text(
              widget.article.description!,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.75,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Free-tier notice ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.elevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppTheme.textCaption),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'The full article content is available on the '
                    'publisher\'s website.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textCaption,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Primary CTA — Read Full Article ──────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openInAppReader(context),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Read Full Article'),
            ),
          ),
          const SizedBox(height: 12),

          // ── Secondary — Copy Link ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _copyLink(context),
              icon: const Icon(Icons.link_rounded, size: 18),
              label: const Text('Copy Link'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecond,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _openInAppReader(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewScreen(
          url: widget.article.url,
          title: widget.article.sourceName,
        ),
      ),
    );
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.article.url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard.')),
    );
  }

  void _shareArticle(BuildContext context) {
    Share.share(
      '${widget.article.title}\n\nRead more at: ${widget.article.url}',
      subject: widget.article.title,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) {
    return DateFormat('d MMM yyyy, HH:mm').format(dt.toLocal());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 18),
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String sourceName;
  const _SourceBadge({required this.sourceName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accentMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        sourceName.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.accent,
              letterSpacing: 0.8,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
