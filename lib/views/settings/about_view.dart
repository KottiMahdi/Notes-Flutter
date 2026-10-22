import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/error/app_logger.dart';
import '../../core/widgets/retry_snack_bar.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  Future<void> _contactSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'mkotti72@gmail.com',
    );
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Could not open the support email.',
        error: error,
        stackTrace: stackTrace,
        name: 'about',
      );
    }

    if (!opened && context.mounted) {
      showRetrySnackBar(
        context,
        message: 'Could not open your email app.',
        onRetry: () => _contactSupport(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? Colors.white70 : const Color(0xFF5F6368);
    final accent = isDark ? const Color(0xFFFFB74D) : const Color(0xFFC66A00);

    return Scaffold(
      appBar: AppBar(title: const Text('About NoteNest')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Privacy Policy',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text('Last updated: October 22, 2026',
              style: TextStyle(color: muted)),
          const SizedBox(height: 16),
          const Text(
            'Thank you for using NoteNest. This Privacy Policy explains what '
            'information NoteNest collects, how it is used, stored, and '
            'protected.',
          ),
          const SizedBox(height: 24),
          const _PolicySection(
            title: '1. Information We Collect',
            subsections: [
              _PolicySubsection(
                title: 'Account information',
                paragraphs: [
                  'When you create an account or sign in, NoteNest and its '
                      'authentication providers may process:',
                ],
                bullets: [
                  'Your email address and Firebase user ID.',
                  'Your username or profile name.',
                  'Google account information, if you choose Google sign-in.',
                ],
                closing:
                    'We use this information to authenticate your account and '
                    'provide access to NoteNest.',
              ),
              _PolicySubsection(
                title: 'Notes and categories',
                paragraphs: [
                  'NoteNest stores the content and details you create, '
                      'including:',
                ],
                bullets: [
                  'Notes and note titles.',
                  'Category names and settings, such as category type, icon, '
                      'and color.',
                  'Associated account identifiers and note creation timestamps.',
                ],
                closing:
                    'This information is used to save and synchronize your '
                    'notes and categories across your devices.',
              ),
              _PolicySubsection(
                title: 'App preferences',
                paragraphs: [
                  'NoteNest saves your light or dark theme preference locally '
                      'on your device.',
                ],
              ),
            ],
          ),
          const _PolicySection(
            title: '2. How We Use Your Information',
            paragraphs: [
              'We use your information to:',
            ],
            bullets: [
              'Authenticate your account.',
              'Save and synchronize your notes and categories.',
              "Provide NoteNest's core functionality.",
              'Maintain the reliability and security of the service.',
            ],
            closing: 'We do not sell your personal information.',
          ),
          const _PolicySection(
            title: '3. Data Storage',
            paragraphs: [
              'Account and app data are stored using Google Firebase services, '
                  'including Firebase Authentication and Cloud Firestore. Data '
                  'transmitted between your device and Firebase is protected '
                  'in transit using HTTPS.',
            ],
          ),
          const _PolicySection(
            title: '4. Data Sharing',
            paragraphs: [
              "We do not sell, rent, or share your personal information with "
                  'third parties for their advertising or marketing purposes. '
                  'Google Firebase processes information as needed to provide '
                  "authentication, storage, and related services. Google's "
                  'handling of information is also subject to Google\'s privacy '
                  'terms.',
            ],
          ),
          const _PolicySection(
            title: '5. Data Security',
            paragraphs: [
              'We rely on reasonable safeguards and Firebase security features '
                  'to help protect your information from unauthorized access, '
                  'disclosure, or loss. No method of electronic storage or '
                  'internet transmission is completely secure.',
            ],
          ),
          const _PolicySection(
            title: '6. Your Rights and Choices',
            paragraphs: [
              'You may access or update your account information and delete '
                  'your account from the app\'s settings. When you delete your '
                  'account using this feature, NoteNest deletes the associated '
                  'profile, categories, notes, and Firebase Authentication '
                  'account. You may also contact us with questions or requests '
                  'about your personal data.',
            ],
          ),
          const _PolicySection(
            title: "7. Children's Privacy",
            paragraphs: [
              'NoteNest is not intended for children under the age of 13. We '
                  'do not knowingly collect personal information from children '
                  'under 13.',
            ],
          ),
          const _PolicySection(
            title: '8. Changes to This Privacy Policy',
            paragraphs: [
              'We may update this Privacy Policy from time to time. Changes '
                  'will be posted on this page with an updated “Last updated” '
                  'date.',
            ],
          ),
          _PolicySection(
            title: '9. Contact Us',
            paragraphs: [
              'If you have questions about this Privacy Policy or your personal '
                  'data, contact us at:',
            ],
            children: [
              TextButton.icon(
                onPressed: () => _contactSupport(context),
                icon: const Icon(Icons.email_outlined),
                label: const Text('mkotti72@gmail.com'),
                style: TextButton.styleFrom(foregroundColor: accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  final String? closing;
  final List<_PolicySubsection> subsections;
  final List<Widget> children;

  const _PolicySection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
    this.closing,
    this.subsections = const [],
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(paragraph),
            ),
          ),
          ...bullets.map((bullet) => _PolicyBullet(text: bullet)),
          if (closing != null) ...[
            const SizedBox(height: 8),
            Text(closing!),
          ],
          ...subsections.map((subsection) => subsection),
          ...children,
        ],
      ),
    );
  }
}

class _PolicySubsection extends StatelessWidget {
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  final String? closing;

  const _PolicySubsection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
    this.closing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          ...paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(paragraph),
            ),
          ),
          ...bullets.map((bullet) => _PolicyBullet(text: bullet)),
          if (closing != null) ...[
            const SizedBox(height: 6),
            Text(closing!),
          ],
        ],
      ),
    );
  }
}

class _PolicyBullet extends StatelessWidget {
  final String text;

  const _PolicyBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
