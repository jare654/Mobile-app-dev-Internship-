// lib/screens/bookmarks_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../providers/bookmarks_provider.dart';
import '../widgets/article_card.dart';
import 'article_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SAVED ARTICLES'),
        centerTitle: true,
      ),
      body: Consumer<BookmarksProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.pulseRed));
          }

          if (provider.bookmarks.isEmpty) {
            return _EmptyBookmarks();
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            itemCount: provider.bookmarks.length,
            itemBuilder: (context, index) {
              final article = provider.bookmarks[index];
              return ArticleCard(
                article: article,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(article: article),
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

class _EmptyBookmarks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border_rounded, size: 64, color: AppTheme.pulseRed.withAlpha(100)),
            const SizedBox(height: 24),
            Text(
              'Your library is empty.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: GoogleFonts.newsreader().fontFamily,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Articles you save will appear here for\ncurated offline reading.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
