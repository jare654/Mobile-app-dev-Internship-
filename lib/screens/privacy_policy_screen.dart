import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('PRIVACY POLICY'),
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
              'Your Privacy Matters',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.pulseRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'At PulseNews Pro, we are committed to protecting your privacy and ensuring the security of your personal information.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 32),
            
            // Privacy Sections
            _buildSection(
              context,
              'Information We Collect',
              [
                '• Account information (email, password)',
                '• Reading preferences and bookmarked articles',
                '• App usage analytics and crash reports',
                '• Device information for optimization',
              ],
            ),
            
            _buildSection(
              context,
              'How We Use Your Information',
              [
                '• To provide personalized news content',
                '• To improve app performance and features',
                '• To send important app notifications',
                '• To analyze usage patterns for better UX',
              ],
            ),
            
            _buildSection(
              context,
              'Data Protection',
              [
                '• All data is encrypted in transit and at rest',
                '• We never sell your personal information',
                '• Limited access to data for authorized personnel only',
                '• Regular security audits and updates',
              ],
            ),
            
            _buildSection(
              context,
              'Your Rights',
              [
                '• Access your personal data anytime',
                '• Request deletion of your account and data',
                '• Opt-out of analytics tracking',
                '• Export your data in portable format',
              ],
            ),
            
            _buildSection(
              context,
              'Third-Party Services',
              [
                '• News API services for content delivery',
                '• Analytics services for app improvement',
                '• Cloud storage for bookmark synchronization',
                '• All third parties are carefully vetted',
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
                    'Questions About Privacy?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have any questions about this Privacy Policy or how we handle your data, please contact us at:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'privacy@pulsenews.com',
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
            point,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        )),
      ],
    );
  }
}
