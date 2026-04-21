import 'package:flutter/material.dart';
import 'package:aarogyamfin/theme/app_theme.dart';
import 'package:aarogyamfin/main.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppTheme.gold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('PRIVACY POLICY', style: AppTheme.label(11)),
                ],
              ),
            ),

            // ── Divider ──────────────────────────────
            Container(height: 1, color: borderColor, margin: const EdgeInsets.only(top: 12)),

            // ── Content ──────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Hero
                  _HeroBlock(isDark: isDark, borderColor: borderColor),
                  const SizedBox(height: 24),

                  _PolicySection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.lock_outline,
                    title: 'No Data Storage — Ever',
                    content:
                        'AarogyamFin is built on a simple principle: your financial data belongs to you, not us.\n\nWhen you upload a bank statement PDF, it is processed entirely in real-time and permanently deleted from our servers immediately after analysis. We do not retain, store, archive, or back up any uploaded files.\n\nYour PDF is deleted within seconds of processing — guaranteed by our code, not just policy.',
                  ),
                  const SizedBox(height: 16),

                  _PolicySection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.assignment_outlined,
                    title: 'What We Collect',
                    content:
                        'We collect absolutely no personal information. There are no user accounts beyond your Google login, no registration process, and no data harvesting.\n\nThe only data temporarily processed is the PDF you upload — which is deleted immediately. Your keyword searches and results exist only in your session and are never logged or stored on our servers.',
                  ),
                  const SizedBox(height: 16),

                  _PolicySection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.block_outlined,
                    title: 'What We Never Do',
                    content:
                        '— Sell, share, or transfer your data to any third party\n— Use your financial data to train AI models\n— Send you marketing emails or spam\n— Store your transaction history anywhere\n— Share information with advertisers or data brokers',
                  ),
                  const SizedBox(height: 16),

                  _PolicySection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.shield_outlined,
                    title: 'Security',
                    content:
                        'All data transmitted between your device and our servers is protected by 256-bit SSL encryption. Our servers are hosted on Railway\'s secure cloud infrastructure.\n\nFile uploads are limited to 10MB and only PDF files are accepted. Rate limiting is enforced to prevent abuse.',
                  ),
                  const SizedBox(height: 16),

                  _PolicySection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.person_outline,
                    title: 'Age Restriction',
                    content:
                        'AarogyamFin is intended for users who are 18 years of age or older. By using this tool, you confirm that you are at least 18 years old.\n\nIf you are under 18, please do not use this service.',
                  ),
                  const SizedBox(height: 16),

                  _PolicySection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.edit_note_outlined,
                    title: 'Changes to This Policy',
                    content:
                        'We reserve the right to update this Privacy Policy at any time. Changes will be reflected in the app with an updated date. We encourage you to review this policy periodically.\n\nContinued use of AarogyamFin after changes constitutes acceptance of the updated policy.',
                  ),
                  const SizedBox(height: 32),

                  // Footer
                  Center(
                    child: Text(
                      'Last updated: February 2026',
                      style: AppTheme.mutedStyle(11, isDark: isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '© 2026 AarogyamFin. All rights reserved.',
                      style: AppTheme.mutedStyle(11, isDark: isDark),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero Block ────────────────────────────────────────────
class _HeroBlock extends StatelessWidget {
  final bool isDark;
  final Color borderColor;
  const _HeroBlock({required this.isDark, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(0.04),
        border: Border.all(color: AppTheme.gold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                ),
                child: Text('LEGAL', style: AppTheme.label(9).copyWith(color: AppTheme.gold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Privacy Policy',
            style: AppTheme.heading(28, isDark: isDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Your financial data belongs to you. We process and immediately discard everything.',
            style: AppTheme.mutedStyle(13, isDark: isDark),
          ),
        ],
      ),
    );
  }
}

// ── Policy Section Card ───────────────────────────────────
class _PolicySection extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;
  final IconData icon;
  final String title;
  final String content;

  const _PolicySection({
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.gold, size: 18),
                const SizedBox(width: 12),
                Text(title, style: AppTheme.heading(15, isDark: isDark)),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              content,
              style: AppTheme.mutedStyle(13, isDark: isDark).copyWith(height: 1.8),
            ),
          ),
        ],
      ),
    );
  }
}
