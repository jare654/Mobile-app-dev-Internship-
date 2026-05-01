import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/loading_shimmer.dart';
import 'article_detail_screen.dart';

class AllArticlesScreen extends StatefulWidget {
  const AllArticlesScreen({super.key});

  @override
  State<AllArticlesScreen> createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMoreIfNeeded();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreIfNeeded();
    }
  }

  void _loadMoreIfNeeded() {
    final provider = context.read<NewsProvider>();
    if (!provider.isLoading && !provider.isLoadingMore && provider.hasMore) {
      provider.loadMoreHeadlines();
    }
  }

  void _openArticle(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(article: article),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await context.read<NewsProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('ALL ARTICLES'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<NewsProvider>(
            builder: (context, provider, _) {
              if (provider.isFromCache) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.offline_bolt_rounded, size: 20),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.pulseRed,
            child: provider.headlines.isEmpty
                ? provider.isLoading
                    ? const NewsLoadingShimmer()
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No articles available',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                : Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          '${provider.headlines.length} Articles Available',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.pulseRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: provider.headlines.length + (provider.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.headlines.length) {
                              return const Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.pulseRed,
                                  ),
                                ),
                              );
                            }
                            
                            final article = provider.headlines[index];
                            return ArticleCard(
                              article: article,
                              onTap: () => _openArticle(context, article),
                            );
                          },
                        ),
                      ),
                      if (!provider.hasMore && provider.headlines.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'You\'ve reached the end',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
