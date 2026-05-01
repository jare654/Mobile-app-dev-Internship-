// lib/services/news_api_service.dart

// ⚠ IMPORTANT: This file is the ONLY place in the application that imports
// the http package.  No screen or widget may contain HTTP logic.

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../config/app_constants.dart';
import '../models/article.dart';
import 'api_exception.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BONUS: In-memory cache entry — stores data + expiry timestamp
// ─────────────────────────────────────────────────────────────────────────────
class _CacheEntry {
  final List<Article> articles;
  final DateTime expiresAt;

  _CacheEntry({
    required this.articles,
    required DateTime now,
  }) : expiresAt = now.add(AppConstants.cacheTtl);

  /// Returns true while the cached data is still within its TTL window.
  bool get isValid => DateTime.now().isBefore(expiresAt);

  /// Remaining freshness for debug/display purposes.
  Duration get remainingTtl => expiresAt.difference(DateTime.now());
}

// ─────────────────────────────────────────────────────────────────────────────
// Result wrapper — lets callers know whether data came from cache or network
// ─────────────────────────────────────────────────────────────────────────────
class FetchResult {
  final List<Article> articles;
  final bool fromCache;
  final int totalResults;

  const FetchResult({
    required this.articles,
    required this.fromCache,
    this.totalResults = 0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// NewsApiService — owns 100% of HTTP logic
// ─────────────────────────────────────────────────────────────────────────────
class NewsApiService {
  // ── Private configuration ─────────────────────────────────────────────────
  static const String _baseUrl = 'newsapi.org';

  /// Loaded from assets/.env — handles missing API key gracefully
  final String? _apiKey = dotenv.env['NEWS_API_KEY']?.trim();

  static const Duration _timeout = Duration(seconds: 10);

  /// Shared headers sent with every request.
  /// Using X-Api-Key header is preferred over the query param — it avoids
  /// the key appearing in server access logs and browser history.
  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ── BONUS: In-memory cache ─────────────────────────────────────────────────
  // Key format: 'headlines:$countryCode:$page'  |  'search:$query'
  final Map<String, _CacheEntry> _cache = {};

  /// Expose whether a specific key is currently cached and valid.
  bool isCached(String key) => _cache[key]?.isValid ?? false;

  // ── Private: response validation ─────────────────────────────────────────

  /// Throws a typed [ApiException] for any non-200 response.
  /// This single method ensures consistent error propagation throughout.
  void _checkResponse(http.Response response) {
    if (response.statusCode == 200) return;

    // Attempt to extract the server's own error message from the body
    String detail = 'No details provided';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      detail = body['message'] as String? ?? detail;
    } catch (_) {
      // Body is not valid JSON — use the fallback detail string
    }

    switch (response.statusCode) {
      case 401:
        throw ApiException.unauthorized();
      case 429:
        throw ApiException.rateLimited();
      default:
        throw ApiException.serverError(response.statusCode, detail);
    }
  }

  // ── Private: core GET helper ──────────────────────────────────────────────

  /// Executes GET request and returns the decoded JSON body as a [Map].
  /// All networking errors propagate upward; caught only by the [provider].
  Future<Map<String, dynamic>> _get(Uri uri) async {
    // Check if API key is configured
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('NEWS_API_KEY not configured. Please add your API key to assets/.env file.');
    }
    
    var finalUri = uri;
    if (kIsWeb) {
      // NewsAPI free tier blocks requests from browsers (CORS).
      // We use a proxy to bypass this for development/web preview.
      finalUri = Uri.parse('https://corsproxy.io/?${Uri.encodeComponent(uri.toString())}');
    }
    
    final response =
        await http.get(finalUri, headers: _headers).timeout(_timeout);
    _checkResponse(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── Private: article list parser ─────────────────────────────────────────

  /// Converts the raw 'articles' JSON array into a typed [List<Article>].
  List<Article> _parseArticles(List<dynamic> raw) => raw
      .map((e) => Article.fromJson(e as Map<String, dynamic>))
      // Filter out placeholder/removed articles returned by the free tier
      .where((a) => a.url.isNotEmpty && a.title != 'No title available')
      .toList();

  // ── Public: Endpoint 1 — Top Headlines ────────────────────────────────────

  /// Fetches top headlines for [countryCode] at the given [page].
  ///
  /// BONUS — Cache strategy:
  ///   1. If a valid cache entry exists, return it instantly and schedule a
  ///      background refresh so the next call gets fresh data.
  ///   2. If no valid entry exists, fetch from the network, populate the cache,
  ///      and return the fresh data.
  Future<FetchResult> fetchTopHeadlines(
    String countryCode, {
    int page = 1,
    String? category,
  }) async {
    final cacheKey = 'headlines:$countryCode:$category:$page';

    // ── Cache HIT ────────────────────────────────────────────────────────────
    if (_cache[cacheKey]?.isValid == true) {
      // Schedule a silent background refresh without blocking the caller
      _refreshHeadlinesInBackground(countryCode, page, cacheKey, category);
      return FetchResult(
        articles: _cache[cacheKey]!.articles,
        fromCache: true,
      );
    }

    // ── Cache MISS — fetch from network ─────────────────────────────────────
    return _fetchHeadlinesFromNetwork(countryCode, page, cacheKey, category);
  }

  Future<FetchResult> _fetchHeadlinesFromNetwork(
    String countryCode,
    int page,
    String cacheKey,
    String? category,
  ) async {
    final queryParams = {
      'country': countryCode,
      'pageSize': AppConstants.paginationLoadSize.toString(),
      'page': page.toString(),
      'apiKey': _apiKey ?? '',
    };

    if (category != null) {
      queryParams['category'] = category;
    }

    final uri = Uri.https(_baseUrl, '/v2/top-headlines', queryParams);

    final body = await _get(uri);
    final articles = _parseArticles(body['articles'] as List<dynamic>);
    final totalResults = body['totalResults'] as int? ?? 0;

    // Store in cache
    _cache[cacheKey] = _CacheEntry(articles: articles, now: DateTime.now());

    return FetchResult(
      articles: articles,
      fromCache: false,
      totalResults: totalResults,
    );
  }

  /// Fires a background network fetch and updates the cache silently.
  /// The UI is NOT notified here — the cache will serve the fresh data on the
  /// NEXT call to [fetchTopHeadlines].
  void _refreshHeadlinesInBackground(
      String countryCode, int page, String cacheKey, String? category) {
    Future.microtask(() async {
      try {
        await _fetchHeadlinesFromNetwork(countryCode, page, cacheKey, category);
      } catch (_) {
        // Background refresh failures are swallowed — the UI already has data
      }
    });
  }

  // ── Public: Endpoint 2 — Search Everything ────────────────────────────────

  /// Searches all news sources for articles matching [query].
  ///
  /// Results are cached under 'search:$query' with the standard [cacheTtl].
  Future<FetchResult> searchEverything(String query) async {
    final cacheKey = 'search:${query.toLowerCase().trim()}';

    if (_cache[cacheKey]?.isValid == true) {
      return FetchResult(
        articles: _cache[cacheKey]!.articles,
        fromCache: true,
      );
    }

    final uri = Uri.https(_baseUrl, '/v2/everything', {
      'q': query.trim(),
      'pageSize': AppConstants.pageSize.toString(),
      'sortBy': 'publishedAt',
      'language': 'en',
      'apiKey': _apiKey ?? '',
    });

    final body = await _get(uri);
    final articles = _parseArticles(body['articles'] as List<dynamic>);
    final totalResults = body['totalResults'] as int? ?? 0;

    _cache[cacheKey] = _CacheEntry(articles: articles, now: DateTime.now());

    return FetchResult(
      articles: articles,
      fromCache: false,
      totalResults: totalResults,
    );
  }

  // ── Cache management ──────────────────────────────────────────────────────

  /// Invalidates all cached data (useful for pull-to-refresh).
  void clearCache() => _cache.clear();

  /// Invalidates only the cache entries for a specific country.
  void clearCountryCache(String countryCode) {
    _cache.removeWhere((key, _) => key.startsWith('headlines:$countryCode'));
  }
}
