// lib/widgets/article_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../models/article.dart';
import '../providers/bookmarks_provider.dart';
import 'loading_shimmer.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            article.sourceName.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.pulseRed,
                                  fontSize: 10,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.circle, size: 3, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(article.publishedAt),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white60 
                                : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: GoogleFonts.newsreader().fontFamily,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ShimmerBox(height: 100, width: 100),
                      errorWidget: (_, __, ___) => Container(color: AppTheme.lightSurfaceContainer),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (article.description != null)
              Text(
                article.description!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              children: [
                const Spacer(),
                Consumer<BookmarksProvider>(
                  builder: (context, provider, _) {
                    final isSaved = provider.isBookmarked(article);
                    return IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 18,
                        color: isSaved ? AppTheme.pulseRed : Colors.grey,
                      ),
                      onPressed: () => provider.toggleBookmark(article),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
