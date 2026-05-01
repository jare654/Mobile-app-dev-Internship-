// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../providers/accessibility_provider.dart';
import '../providers/history_provider.dart';
import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import '../services/news_api_service.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // ── Profile Section ────────────────────────────────────────────────
          const _ProfileCard(),
          const SizedBox(height: 32),

          // ── Personalization ───────────────────────────────────────────────
          _buildSectionHeader('PERSONALIZATION'),
          _buildRegionTile(context),
          const Divider(),
          _buildFollowedTopics(context),
          const SizedBox(height: 32),

          // ── Appearance ────────────────────────────────────────────────────
          _buildSectionHeader('APPEARANCE'),
          _buildThemeToggle(context),
          const Divider(),
          _buildTextScalePicker(context),
          const SizedBox(height: 32),

          // ── Data & Security ───────────────────────────────────────────────
          _buildSectionHeader('SYSTEM & PRIVACY'),
          _buildDataManagement(context),
          const Divider(),
          _buildLogoutTile(context),

          const SizedBox(height: 48),
          Center(
            child: Text(
              'PulseNews Pro v1.0.0\nAAU Unit 4 MAD Assignment',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: AppTheme.pulseRed,
        ),
      ),
    );
  }

  Widget _buildRegionTile(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        final selected = AppConstants.countries.firstWhere(
          (c) => c.code == provider.selectedCountry,
          orElse: () => AppConstants.countries.first,
        );

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Content Region'),
          subtitle: Text(selected.name),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: () => _showCountryDialog(context, provider),
        );
      },
    );
  }

  void _showCountryDialog(BuildContext context, NewsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text('SELECT REGION'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppConstants.countries.length,
            itemBuilder: (context, index) {
              final country = AppConstants.countries[index];
              return ListTile(
                leading: Text(country.flag, style: const TextStyle(fontSize: 20)),
                title: Text(country.name),
                selected: provider.selectedCountry == country.code,
                onTap: () {
                  provider.fetchTopHeadlines(country.code);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFollowedTopics(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Followed Topics'),
          subtitle: Text('${provider.followedCategories.length} categories active'),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        );
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, _) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Dark Mode'),
          subtitle: const Text('High-contrast editorial theme'),
          trailing: Switch.adaptive(
            value: provider.isDarkMode,
            onChanged: (_) => provider.toggleTheme(),
            activeColor: AppTheme.pulseRed,
          ),
        );
      },
    );
  }

  Widget _buildTextScalePicker(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Text Scaling'),
              subtitle: Text('${(provider.textScaleFactor * 100).toInt()}% magnification'),
            ),
            Slider(
              value: provider.textScaleFactor,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              activeColor: AppTheme.pulseRed,
              onChanged: (val) => provider.setTextScale(val),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataManagement(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Clear Storage & Cache'),
      subtitle: const Text('Remove bookmarks and reading history'),
      onTap: () async {
        context.read<NewsApiService>().clearCache();
        await context.read<HistoryProvider>().clearHistory();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All local data cleared')),
        );
      },
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Logout', style: TextStyle(color: AppTheme.pulseRed, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.logout_rounded, color: AppTheme.pulseRed, size: 20),
      onTap: () async {
        await context.read<AuthService>().signOut();
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightOutline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.pulseRed,
            child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yared Bekele',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Premium Member',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.pulseRed),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('EDIT PROFILE'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
