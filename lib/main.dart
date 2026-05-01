import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'package:news_app/config/app_theme.dart';
import 'package:news_app/providers/accessibility_provider.dart';
import 'package:news_app/providers/bookmarks_provider.dart';
import 'package:news_app/providers/daily_streak_provider.dart';
import 'package:news_app/providers/history_provider.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/providers/theme_provider.dart';
import 'package:news_app/screens/splash_screen.dart';
import 'package:news_app/services/news_api_service.dart';
import 'package:news_app/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WebView Platform
  if (!kIsWeb) {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        WebViewPlatform.instance = WebKitWebViewPlatform();
      }
    } catch (e) {
      print('WebView platform initialization failed: $e');
    }
  }

  // ── Environment variables ──────────────────────────────────────────────────
  try {
    await dotenv.load(fileName: 'assets/.env');
    
    // Check if API key is properly configured
    final apiKey = dotenv.env['NEWS_API_KEY'];
    
    if (apiKey == null || apiKey == 'your_newsapi_key_here' || apiKey.isEmpty) {
      print('⚠️  NEWS_API_KEY not configured!');
      print('Please edit assets/.env and add your NewsAPI key from https://newsapi.org/register');
      print('For now, running in demo mode with limited functionality.');
    }
  } catch (e) {
    print('⚠️  Failed to load .env file: $e');
    print('Please ensure assets/.env exists and is properly formatted.');
  }

  // ── Device orientation ────────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final newsApiService = NewsApiService();

  runApp(PulseNewsApp(newsApiService: newsApiService));
}

class PulseNewsApp extends StatelessWidget {
  final NewsApiService newsApiService;
  const PulseNewsApp({super.key, required this.newsApiService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NewsApiService>(create: (_) => newsApiService),
        ChangeNotifierProvider(create: (_) => NewsProvider(newsApiService)),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService()),
        ChangeNotifierProvider(create: (_) => DailyStreakProvider()),
      ],
      child: const PulseNewsAppContent(),
    );
  }
}

class PulseNewsAppContent extends StatelessWidget {
  const PulseNewsAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AccessibilityProvider, ThemeProvider, AuthService>(
      builder: (context, accessibility, themeProvider, authService, _) {
        // Set System UI overlay style based on theme
        SystemChrome.setSystemUIOverlayStyle(
          themeProvider.isDarkMode 
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: AppTheme.darkBackground,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: AppTheme.lightBackground,
              ),
        );

        return MaterialApp(
          title: 'PulseNews Pro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(accessibility.textScaleFactor),
              ),
              child: child!,
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
