// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../config/app_theme.dart';
import '../models/article.dart';
import '../providers/history_provider.dart';
import '../providers/news_provider.dart';
import '../providers/daily_streak_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/cached_badge.dart';
import '../widgets/daily_streak_widget.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_shimmer.dart';
import 'article_detail_screen.dart';
import 'all_articles_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NewsProvider>().fetchTopHeadlines(
            context.read<NewsProvider>().selectedCountry,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final progress = _scrollController.offset / _scrollController.position.maxScrollExtent;
      setState(() => _scrollProgress = progress.clamp(0.0, 1.0));
    }
  }

  Future<void> _onRefresh() async {
    await context.read<NewsProvider>().refresh();
  }

  void _openArticle(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Consumer2<NewsProvider, HistoryProvider>(
            builder: (context, newsProvider, historyProvider, _) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.pulseRed,
                backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                edgeOffset: 100,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── Modern AppBar ──────────────────────────────────────────
                    _buildAppBar(context, newsProvider),

                    // ── Content Sections ───────────────────────────────────────
                    if (newsProvider.isLoading)
                      const SliverFillRemaining(child: NewsLoadingShimmer())
                    else if (newsProvider.errorMessage != null && newsProvider.headlines.isEmpty)
                      SliverFillRemaining(
                        child: ErrorView(
                          message: newsProvider.errorMessage!,
                          onRetry: () => newsProvider.fetchTopHeadlines(newsProvider.selectedCountry),
                        ),
                      )
                    else if (newsProvider.headlines.isEmpty)
                      const SliverFillRemaining(child: _EmptyState())
                    else ...[
                      // Daily Streak Widget
                      SliverToBoxAdapter(
                        child: GestureDetector(
                          onTap: () {
                            context.read<DailyStreakProvider>().recordDailyVisit();
                          },
                          child: const DailyStreakWidget(),
                        ),
                      ),
                      // 1. Featured Hero
                      SliverToBoxAdapter(
                        child: _FeaturedHero(
                          article: newsProvider.headlines.first,
                          onTap: () => _openArticle(context, newsProvider.headlines.first),
                        ),
                      ),

                      // 2. Secondary Headlines (Bento Sidebar style)
                      if (newsProvider.headlines.length > 1)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final article = newsProvider.headlines[index + 1];
                                return Column(
                                  children: [
                                    _SecondaryStoryTile(
                                      article: article,
                                      onTap: () => _openArticle(context, article),
                                    ),
                                    if (index < 2) const Divider(height: 32),
                                  ],
                                );
                              },
                              childCount: (newsProvider.headlines.length - 1).clamp(0, 3),
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      const SliverToBoxAdapter(child: Divider()),

                      // 3. Continue Reading (History)
                      if (historyProvider.history.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildHistorySection(context, historyProvider),
                        ),

                      // 4. Latest Feed
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LATEST STORIES',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.pulseRed,
                                      letterSpacing: 1.5,
                                    ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AllArticlesScreen(),
                                    ),
                                  );
                                },
                                child: const Text('SEE ALL'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Skip the hero and secondary stories
                            final offset = 4;
                            if (index + offset >= newsProvider.headlines.length) return null;
                            final article = newsProvider.headlines[index + offset];
                            return ArticleCard(
                              article: article,
                              onTap: () => _openArticle(context, article),
                            );
                          },
                          childCount: (newsProvider.headlines.length - 4).clamp(0, 100),
                        ),
                      ),

                      // Pagination
                      SliverToBoxAdapter(
                        child: _buildPaginationFooter(context, newsProvider),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ],
                ),
              );
            },
          ),
          
          // ── Reading Progress Bar ─────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 56, // Height of AppBar
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: isDark ? Colors.white10 : Colors.black12,
              child: UnconstrainedBox(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 2,
                  width: MediaQuery.of(context).size.width * _scrollProgress,
                  color: AppTheme.pulseRed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, NewsProvider provider) {
    return SliverAppBar(
      toolbarHeight: 56,
      floating: true,
      pinned: true,
      centerTitle: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      title: const Text('PULSENEWS PRO'),
      actions: [
        if (provider.isFromCache) const CachedBadge(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context, HistoryProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Text(
            'CONTINUE READING',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.5,
                ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final article = provider.history[index];
              return _SmallHistoryCard(
                article: article,
                onTap: () => _openArticle(context, article),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
      ],
    );
  }

  Widget _buildPaginationFooter(BuildContext context, NewsProvider provider) {
    if (provider.isLoading || provider.headlines.isEmpty) return const SizedBox.shrink();
    if (provider.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: AppTheme.pulseRed)),
      );
    }
    if (provider.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: OutlinedButton(
          onPressed: provider.loadMoreHeadlines,
          child: const Text('LOAD MORE STORIES'),
        ),
      );
    }
    return const SizedBox(height: 40);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Widgets for HomeScreen
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedHero extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _FeaturedHero({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.lightSurfaceContainer),
                  errorWidget: (_, __, ___) => Container(color: AppTheme.lightSurfaceContainer),
                  memCacheHeight: 400,
                  memCacheWidth: 800,
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    'TOP HEADLINE',
                    style: GoogleFonts.workSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                if (article.description != null)
                  Text(
                    article.description!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'By ${article.author ?? article.sourceName}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 12),
                    const Text('|'),
                    const SizedBox(width: 12),
                    Text(
                      'FEATURED',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.pulseRed),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(indent: 20, endIndent: 20),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SecondaryStoryTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _SecondaryStoryTile({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.urlToImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.lightSurfaceContainer),
                  errorWidget: (_, __, ___) => Container(color: AppTheme.lightSurfaceContainer),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'LATEST NEWS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.pulseRed,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            article.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            article.description ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SmallHistoryCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _SmallHistoryCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(50)),
        ),
        child: Row(
          children: [
            if (article.urlToImage != null)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                child: SizedBox(
                  width: 90,
                  height: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: article.urlToImage!,
                    fit: BoxFit.cover,
                    memCacheHeight: 200,
                    memCacheWidth: 120,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      article.sourceName.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No news available.'));
  }
}
