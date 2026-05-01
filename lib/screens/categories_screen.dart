import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../config/app_theme.dart';
import '../providers/news_provider.dart';
import 'category_feed_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'business',
      'name': 'Business',
      'icon': Icons.business_center_rounded,
      'color': Color(0xFF6366F1),
      'image': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=500&auto=format&fit=crop'
    },
    {
      'id': 'technology',
      'name': 'Technology',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFF10B981),
      'image': 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?q=80&w=500&auto=format&fit=crop'
    },
    {
      'id': 'sports',
      'name': 'Sports',
      'icon': Icons.sports_basketball_rounded,
      'color': Color(0xFFF59E0B),
      'image': 'https://images.unsplash.com/photo-1461896704075-8715527f6a95?q=80&w=500&auto=format&fit=crop'
    },
    {
      'id': 'science',
      'name': 'Science',
      'icon': Icons.science_rounded,
      'color': Color(0xFF8B5CF6),
      'image': 'https://images.unsplash.com/photo-1507413245164-6160d8298b31?q=80&w=500&auto=format&fit=crop'
    },
    {
      'id': 'health',
      'name': 'Health',
      'icon': Icons.health_and_safety_rounded,
      'color': Color(0xFFEF4444),
      'image': 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?q=80&w=500&auto=format&fit=crop'
    },
    {
      'id': 'entertainment',
      'name': 'Entertainment',
      'icon': Icons.movie_filter_rounded,
      'color': Color(0xFFEC4899),
      'image': 'https://images.unsplash.com/photo-1499364615650-ec38552f4f34?q=80&w=500&auto=format&fit=crop'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Explore',
                style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: Consumer<NewsProvider>(
              builder: (context, provider, _) {
                return AnimationLimiter(
                  child: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = _categories[index];
                        final isFollowing = provider.isFollowingCategory(category['id']);

                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          columnCount: 2,
                          child: ScaleAnimation(
                            scale: 0.9,
                            child: FadeInAnimation(
                              child: _ModernCategoryCard(
                                name: category['name'],
                                icon: category['icon'],
                                color: category['color'],
                                imageUrl: category['image'],
                                isFollowing: isFollowing,
                                onFollowToggle: () => provider.toggleCategory(category['id']),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CategoryFeedScreen(
                                        category: category['id'],
                                        categoryName: category['name'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _categories.length,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernCategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final String imageUrl;
  final bool isFollowing;
  final VoidCallback onFollowToggle;
  final VoidCallback onTap;

  const _ModernCategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.imageUrl,
    required this.isFollowing,
    required this.onFollowToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheHeight: 300,
              memCacheWidth: 400,
            ),
            // Gradient Overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(150),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            // Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withAlpha(200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, size: 20, color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: onFollowToggle,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isFollowing ? Colors.white : Colors.white.withOpacity(0.24),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFollowing ? Icons.check_rounded : Icons.add_rounded,
                                size: 16,
                                color: isFollowing ? color : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFollowing ? 'Following' : 'Explore',
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
