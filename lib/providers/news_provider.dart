import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_constants.dart';
import '../models/article.dart';
import '../services/api_exception.dart';
import '../services/news_api_service.dart';

enum LoadingState { idle, loading, loadingMore, refreshing }

class NewsProvider extends ChangeNotifier {
  final NewsApiService _service;

  NewsProvider(this._service) {
    _loadPreferences();
  }

  // ── Private state ─────────────────────────────────────────────────────────
  List<Article> _headlines = [];
  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;
  String _selectedCountry = AppConstants.countries.first.code;
  bool _isFromCache = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalResults = 0;

  // Personalization
  List<String> _followedCategories = [];
  List<String> _followedSources = [];
  
  // ── Public getters ────────────────────────────────────────────────────────
  List<Article> get headlines => List.unmodifiable(_headlines);
  LoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get isLoadingMore => _loadingState == LoadingState.loadingMore;
  bool get isRefreshing => _loadingState == LoadingState.refreshing;
  String? get errorMessage => _errorMessage;
  String get selectedCountry => _selectedCountry;
  bool get isFromCache => _isFromCache;
  bool get hasMore => _hasMore;
  int get totalResults => _totalResults;
  List<String> get followedCategories => List.unmodifiable(_followedCategories);
  List<String> get followedSources => List.unmodifiable(_followedSources);

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _followedCategories = prefs.getStringList('followed_categories') ?? [];
    _followedSources = prefs.getStringList('followed_sources') ?? [];
    notifyListeners();
  }

  Future<void> toggleCategory(String category) async {
    if (_followedCategories.contains(category)) {
      _followedCategories.remove(category);
    } else {
      _followedCategories.add(category);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('followed_categories', _followedCategories);
  }

  bool isFollowingCategory(String category) => _followedCategories.contains(category);

  // ── Fetch: Top Headlines (initial / country change) ───────────────────────

  Future<void> fetchTopHeadlines(String countryCode) async {
    _selectedCountry = countryCode;
    _currentPage = 1;
    _hasMore = true;
    _headlines = [];
    _errorMessage = null;
    _loadingState = LoadingState.loading;
    notifyListeners();

    await _performFetch(countryCode, page: 1, append: false);
  }

  Future<void> loadMoreHeadlines() async {
    if (_loadingState != LoadingState.idle || !_hasMore) return;

    _loadingState = LoadingState.loadingMore;
    notifyListeners();

    await _performFetch(_selectedCountry, page: _currentPage + 1, append: true);
  }

  Future<void> refresh() async {
    _service.clearCountryCache(_selectedCountry);
    _currentPage = 1;
    _hasMore = true;
    _loadingState = LoadingState.refreshing;
    _errorMessage = null;
    notifyListeners();

    await _performFetch(_selectedCountry, page: 1, append: false);
  }

  Future<void> _performFetch(
    String countryCode, {
    required int page,
    required bool append,
  }) async {
    try {
      final result = await _service.fetchTopHeadlines(
        countryCode,
        page: page,
      );

      if (append) {
        _headlines = [..._headlines, ...result.articles];
      } else {
        _headlines = result.articles;
      }

      _currentPage = page;
      _totalResults = result.totalResults;
      _isFromCache = result.fromCache;

      _hasMore = _headlines.length < _totalResults &&
          result.articles.length == AppConstants.paginationLoadSize;

      _errorMessage = null;
      _loadingState = LoadingState.idle;
    } on SocketException {
      _errorMessage = AppConstants.errorNoInternet;
      _loadingState = LoadingState.idle;
    } on TimeoutException {
      _errorMessage = AppConstants.errorTimeout;
      _loadingState = LoadingState.idle;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      _loadingState = LoadingState.idle;
    } on FormatException {
      _errorMessage = AppConstants.errorFormat;
      _loadingState = LoadingState.idle;
    } catch (e) {
      _errorMessage = '${AppConstants.errorGeneric}\n${e.toString()}';
      _loadingState = LoadingState.idle;
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
