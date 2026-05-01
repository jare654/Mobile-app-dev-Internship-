import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/article.dart';
import '../services/news_api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_shimmer.dart';
import '../providers/news_provider.dart';
import 'article_detail_screen.dart';

class CategoryFeedScreen extends StatefulWidget {
  final String category;
  final String categoryName;

  const CategoryFeedScreen({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  State<CategoryFeedScreen> createState() => _CategoryFeedScreenState();
}

class _CategoryFeedScreenState extends State<CategoryFeedScreen> {
  late Future<FetchResult> _feedFuture;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  void _loadFeed() {
    final country = context.read<NewsProvider>().selectedCountry;
    _feedFuture = context.read<NewsApiService>().fetchTopHeadlines(
      country,
      category: widget.category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: FutureBuilder<FetchResult>(
        future: _feedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const NewsLoadingShimmer();
          }

          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _loadFeed()),
            );
          }

          final articles = snapshot.data?.articles ?? [];
          if (articles.isEmpty) {
            return const Center(child: Text('No articles found in this category.'));
          }

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return ArticleCard(
                article: articles[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(article: articles[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
