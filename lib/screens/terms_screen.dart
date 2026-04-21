import 'package:flutter/material.dart';
import 'package:aarogyamfin/theme/app_theme.dart';
import 'package:aarogyamfin/main.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                  Text('TERMS OF SERVICE', style: AppTheme.label(11)),
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

                  _TermsSection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.handshake_outlined,
                    title: 'Acceptance of Terms',
                    content:
                        'By accessing or using AarogyamFin ("the Service"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use this service.\n\nThese terms apply to all users of the Service. We reserve the right to modify these terms at any time — continued use constitutes acceptance of updated terms.',
                  ),
                  const SizedBox(height: 16),

                  _TermsSection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.warning_amber_outlined,
                    title: 'Not Financial Advice',
                    content:
                        'AarogyamFin is a statement analysis tool only. It is not a financial advisor, investment advisor, or banking service.\n\nAarogyamFin is not a registered financial advisor. Nothing on this platform constitutes financial, investment, legal, or tax advice.\n\n⚠️ Do not make financial decisions solely based on results from this tool. Always verify with your bank and consult a qualified financial advisor for important decisions.',
                    isWarning: true,
                  ),
                  const SizedBox(height: 16),

                  _TermsSection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.gps_fixed_outlined,
                    title: 'Accuracy Disclaimer',
                    content:
                        'While we strive for accuracy, AarogyamFin may make errors in reading, parsing, or categorizing transactions. Results depend heavily on the quality and format of the uploaded PDF.\n\nWe do not guarantee that all transactions will be detected, correctly categorized, or accurately represented. Always cross-verify important figures with your official bank statement.\n\n💡 This tool is best used as a quick reference and search aid — not as a substitute for official bank records.',
                  ),
                  const SizedBox(height: 16),

                  _TermsSection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.remove_circle_outline,
                    title: 'Limitation of Liability',
                    content:
                        'AarogyamFin and its creator are not liable for any financial loss, damage, or harm arising from the use or misuse of this service.\n\nThis includes but is not limited to: incorrect transaction analysis, missed transactions, wrong Credit/Debit classification, or any decisions made based on the tool\'s output.\n\nYou use this service entirely at your own risk.',
                  ),
                  const SizedBox(height: 16),

                  _TermsSection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.person_outline,
                    title: 'Eligibility',
                    content:
                        'You must be at least 18 years of age to use AarogyamFin. By using this service, you confirm that you are 18 or older.\n\nYou are responsible for ensuring that your use of this service complies with all applicable laws in your jurisdiction.',
                  ),
                  const SizedBox(height: 16),

                  _TermsSection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.check_circle_outline,
                    title: 'Acceptable Use',
                    content:
                        'You agree to use AarogyamFin only for lawful purposes. You must not:\n\n— Upload files containing malicious code or attempt to compromise our servers\n— Use automated bots or scripts to abuse the service\n— Attempt to reverse engineer, copy, or replicate the service\n— Use the service for any illegal financial activity\n— Upload files that you do not have legal right to access',
                  ),
                  const SizedBox(height: 16),

                  _TermsSection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.sync_outlined,
                    title: 'Service Availability',
                    content:
                        'We do not guarantee uninterrupted availability of AarogyamFin. The service may be temporarily unavailable due to maintenance, updates, or technical issues.\n\nWe reserve the right to modify, suspend, or discontinue the service at any time without prior notice.',
                  ),
                  const SizedBox(height: 16),

                  _TermsSection(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    icon: Icons.balance_outlined,
                    title: 'Governing Law',
                    content:
                        'These Terms of Service shall be governed by and construed in accordance with the laws of India. Any disputes arising from use of this service shall be subject to the jurisdiction of Indian courts.',
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
            'Terms of Service',
            style: AppTheme.heading(28, isDark: isDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Please read these terms carefully before using AarogyamFin.',
            style: AppTheme.mutedStyle(13, isDark: isDark),
          ),
        ],
      ),
    );
  }
}

// ── Terms Section Card ────────────────────────────────────
class _TermsSection extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;
  final IconData icon;
  final String title;
  final String content;
  final bool isWarning;

  const _TermsSection({
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.icon,
    required this.title,
    required this.content,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFF87171).withOpacity(0.04)
            : surfaceColor,
        border: Border.all(
          color: isWarning
              ? const Color(0xFFF87171).withOpacity(0.25)
              : borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isWarning
                      ? const Color(0xFFF87171).withOpacity(0.2)
                      : borderColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isWarning ? const Color(0xFFF87171) : AppTheme.gold,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTheme.heading(15, isDark: isDark).copyWith(
                    color: isWarning ? const Color(0xFFF87171) : null,
                  ),
                ),
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
