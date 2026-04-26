import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/accessibility_provider.dart';
import 'providers/bookmarks_provider.dart';
import 'providers/history_provider.dart';
import 'providers/news_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_container.dart';
import 'services/news_api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Environment variables ──────────────────────────────────────────────────
  await dotenv.load(fileName: 'assets/.env');

  // ── Device orientation ────────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final newsApiService = NewsApiService();

  runApp(
    MultiProvider(
      providers: [
        Provider<NewsApiService>(create: (_) => newsApiService),
        ChangeNotifierProvider(create: (_) => NewsProvider(newsApiService)),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const PulseNewsApp(),
    ),
  );
}

class PulseNewsApp extends StatelessWidget {
  const PulseNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AccessibilityProvider, ThemeProvider>(
      builder: (context, accessibility, themeProvider, _) {
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
                textScaleFactor: accessibility.textScaleFactor,
              ),
              child: child!,
            );
          },
          home: const MainNavigationContainer(),
        );
      },
    );
  }
}
