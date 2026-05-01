import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('TERMS OF SERVICE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Terms of Service',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.pulseRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to PulseNews Pro. By using our app, you agree to these terms and conditions.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 32),
            
            // Terms Sections
            _buildSection(
              context,
              'Acceptance of Terms',
              [
                'By downloading and using PulseNews Pro, you accept and agree to be bound by these Terms of Service.',
                'If you do not agree to these terms, please do not use our app.',
                'We reserve the right to update these terms at any time without prior notice.',
              ],
            ),
            
            _buildSection(
              context,
              'User Accounts',
              [
                'You must provide accurate information when creating an account.',
                'You are responsible for maintaining the confidentiality of your account credentials.',
                'You are responsible for all activities that occur under your account.',
                'You must notify us immediately of any unauthorized use of your account.',
              ],
            ),
            
            _buildSection(
              context,
              'Content and Services',
              [
                'PulseNews Pro provides access to news articles from various sources.',
                'We do not create or edit the news content displayed in the app.',
                'Content is provided "as is" without any warranties.',
                'We are not responsible for the accuracy or reliability of news content.',
              ],
            ),
            
            _buildSection(
              context,
              'Acceptable Use',
              [
                'You may use the app for personal, non-commercial purposes only.',
                'You may not attempt to reverse engineer or hack the app.',
                'You may not use automated bots to access our services.',
                'You must respect all applicable laws and regulations.',
              ],
            ),
            
            _buildSection(
              context,
              'Intellectual Property',
              [
                'The app and its original content are owned by PulseNews Pro.',
                'News content remains the property of its respective publishers.',
                'You may not reproduce, distribute, or create derivative works.',
                'All trademarks, service marks, and trade names are proprietary.',
              ],
            ),
            
            _buildSection(
              context,
              'Limitation of Liability',
              [
                'PulseNews Pro is provided on an "as is" basis.',
                'We are not liable for any damages arising from your use of the app.',
                'We are not responsible for news content accuracy or reliability.',
                'Our total liability shall not exceed the amount you paid for the service.',
              ],
            ),
            
            _buildSection(
              context,
              'Termination',
              [
                'We may terminate or suspend your account at our sole discretion.',
                'You may terminate your account at any time through the app settings.',
                'Upon termination, your right to use the app ceases immediately.',
                'We may delete all your data upon termination.',
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Contact
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.pulseRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.pulseRed.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Questions About Terms?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have any questions about these Terms of Service, please contact us at:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'legal@pulsenews.com',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.pulseRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Footer
            Center(
              child: Text(
                'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...points.map((point) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '• $point',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        )),
      ],
    );
  }
}
