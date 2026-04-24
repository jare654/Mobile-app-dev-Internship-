// lib/screens/search_screen.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../models/article.dart';
import '../services/api_exception.dart';
import '../services/news_api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';
import 'article_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Future<List<Article>>? _searchFuture;
  Timer? _debounceTimer;
  bool _isDebouncing = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.length < 2) {
      if (mounted) {
        setState(() {
          _isDebouncing = false;
          _searchFuture = null;
          _lastQuery = '';
        });
      }
      return;
    }

    if (mounted) setState(() => _isDebouncing = true);

    _debounceTimer = Timer(AppConstants.debounceDelay, () {
      if (!mounted) return;
      setState(() {
        _isDebouncing = false;
        _lastQuery = trimmed;
        _searchFuture = _executeSearch(trimmed);
      });
    });
  }

  Future<List<Article>> _executeSearch(String query) async {
    final result = await context.read<NewsApiService>().searchEverything(query);
    return result.articles;
  }

  void _retrySearch() {
    if (_lastQuery.isEmpty) return;
    setState(() {
      _searchFuture = _executeSearch(_lastQuery);
    });
  }

  void _openArticle(Article article) {
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: const Text('SEARCH'),
              centerTitle: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightOutline),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onQueryChanged,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Topics, sources, keywords...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textCaption),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _isDebouncing
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.pulseRed),
                            ),
                          )
                        : _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _controller.clear();
                                  _onQueryChanged('');
                                },
                              )
                            : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none || _searchFuture == null) {
          return const _SearchPrompt();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.pulseRed));
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: _friendlyError(snapshot.error!),
            onRetry: _retrySearch,
          );
        }

        final articles = snapshot.data ?? [];
        if (articles.isEmpty) {
          return _NoResults(query: _lastQuery);
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: articles.length,
          itemBuilder: (_, i) => ArticleCard(
            article: articles[i],
            onTap: () => _openArticle(articles[i]),
          ),
        );
      },
    );
  }

  String _friendlyError(Object error) {
    if (error is SocketException) return AppConstants.errorNoInternet;
    if (error is TimeoutException) return AppConstants.errorTimeout;
    if (error is ApiException) return error.userMessage;
    return AppConstants.errorGeneric;
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 48, color: AppTheme.pulseRed.withAlpha(100)),
          const SizedBox(height: 16),
          Text(
            'Global search across\nhundreds of publishers.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: GoogleFonts.newsreader().fontFamily,
                  fontSize: 22,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'No results found for "$query".',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
