import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aarogyamfin/theme/app_theme.dart';
import 'package:aarogyamfin/main.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'payment_screen.dart';
import 'privacy_screen.dart';
import 'terms_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // ── Plan limits (must match backend) ─────────────────
  static const Map<String, int> _planInputLimits = {
    'Basic':    25000,
    'Standard': 100000,
    'Pro':      300000,
    'Elite':    1500000,
    'Free':     0,
  };

  // ── State ─────────────────────────────────────────────
  bool _loadingStatus = true;
  bool _hasAccess = false;
  String _planName = 'Free';
  int _inputTokensUsed = 0;
  int _outputTokensUsed = 0;
  bool _sessionActive = false;

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onThemeChange);
    _loadStatus();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onThemeChange() => setState(() {});

  Future<void> _loadStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loadingStatus = false);
      return;
    }

    final status = await ApiService.checkPaymentStatus(user.uid);
    if (mounted) {
      setState(() {
        _hasAccess       = status['has_access'] == true;
        _planName        = status['plan'] ?? 'Free';
        _inputTokensUsed = status['input_tokens_used'] ?? 0;
        _outputTokensUsed= status['output_tokens_used'] ?? 0;
        _sessionActive   = status['has_access'] == true;
        _loadingStatus   = false;
      });
    }
  }

  // ── Computed ──────────────────────────────────────────
  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email?.split('@').first ?? 'there';
  }

  String get _userEmail => FirebaseAuth.instance.currentUser?.email ?? '';
  String get _userInitial => _userName[0].toUpperCase();

  int get _inputLimit => _planInputLimits[_planName] ?? 0;

  double get _usagePercent {
    if (_inputLimit == 0) return 0;
    return (_inputTokensUsed / _inputLimit).clamp(0.0, 1.0);
  }

  String get _usagePercentLabel {
    if (_inputLimit == 0) return '—';
    return '${(_usagePercent * 100).toStringAsFixed(0)}%';
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final mutedColor = isDark ? AppTheme.darkMuted : AppTheme.lightMuted;

    return SafeArea(
      child: _loadingStatus
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : RefreshIndicator(
              color: AppTheme.gold,
              onRefresh: _loadStatus,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [

                  // ── Header ─────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Text('PROFILE', style: AppTheme.label(11)),
                    ),
                  ),

                  // ── Avatar + Name + Email ───────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withOpacity(0.1),
                                border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                              ),
                              child: Center(
                                child: Text(
                                  _userInitial,
                                  style: const TextStyle(
                                    color: AppTheme.gold,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_userName, style: AppTheme.heading(20, isDark: isDark)),
                                  const SizedBox(height: 4),
                                  Text(_userEmail, style: AppTheme.mutedStyle(12, isDark: isDark)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.gold.withOpacity(0.1),
                                      border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      _planName == 'Free' ? 'FREE PLAN' : '${_planName.toUpperCase()} PLAN',
                                      style: AppTheme.label(9).copyWith(color: AppTheme.gold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Usage & Billing ─────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Text('USAGE & BILLING', style: AppTheme.label(11)),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [

                            // Usage % with progress bar
                            Container(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: borderColor)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.data_usage_outlined, color: AppTheme.gold, size: 18),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text('Usage', style: AppTheme.mutedStyle(14, isDark: isDark)),
                                      ),
                                      Text(
                                        _planName == 'Free' ? '—' : _usagePercentLabel,
                                        style: TextStyle(
                                          color: _usagePercent > 0.8
                                              ? const Color(0xFFF87171)
                                              : AppTheme.gold,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_planName != 'Free') ...[
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: _usagePercent,
                                        minHeight: 4,
                                        backgroundColor: AppTheme.gold.withOpacity(0.1),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _usagePercent > 0.8
                                              ? const Color(0xFFF87171)
                                              : AppTheme.gold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Session status
                            _UsageRow(
                              isDark: isDark,
                              icon: Icons.chat_bubble_outline,
                              label: 'AI Chat',
                              value: _planName == 'Free'
                                  ? 'No Session'
                                  : _sessionActive ? 'Active' : 'Expired',
                              valueColor: _planName == 'Free'
                                  ? null
                                  : _sessionActive
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFFF87171),
                              borderColor: borderColor,
                            ),

                            // Current plan
                            _UsageRow(
                              isDark: isDark,
                              icon: Icons.workspace_premium_outlined,
                              label: 'Current Plan',
                              value: _planName,
                              borderColor: borderColor,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Upgrade Button ──────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PaymentScreen()),
                          ).then((_) => _loadStatus());
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withOpacity(0.08),
                            border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _sessionActive ? 'Buy Another Plan' : 'Get Started',
                                    style: AppTheme.heading(16, isDark: isDark)
                                        .copyWith(color: AppTheme.gold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Basic · Standard · Pro · Elite',
                                    style: AppTheme.mutedStyle(12, isDark: isDark),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward, color: AppTheme.gold, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Settings ───────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Text('SETTINGS', style: AppTheme.label(11)),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            _SettingsRow(
                              isDark: isDark,
                              icon: isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                              label: isDark ? 'Light Mode' : 'Dark Mode',
                              borderColor: borderColor,
                              onTap: () => themeNotifier.toggle(),
                              isLast: true,
                              trailing: Switch(
                                value: isDark,
                                onChanged: (_) => themeNotifier.toggle(),
                                activeColor: AppTheme.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Legal ──────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Text('LEGAL', style: AppTheme.label(11)),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            _SettingsRow(
                              isDark: isDark,
                              icon: Icons.privacy_tip_outlined,
                              label: 'Privacy Policy',
                              borderColor: borderColor,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const PrivacyScreen())),
                            ),
                            _SettingsRow(
                              isDark: isDark,
                              icon: Icons.description_outlined,
                              label: 'Terms of Service',
                              borderColor: borderColor,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const TermsScreen())),
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── App Version ────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Center(
                        child: Text(
                          'AarogyamFin v1.0.0',
                          style: AppTheme.mutedStyle(11, isDark: isDark),
                        ),
                      ),
                    ),
                  ),

                  // ── Logout ─────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: surfaceColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(color: borderColor),
                              ),
                              title: Text('Logout', style: AppTheme.heading(18, isDark: isDark)),
                              content: Text(
                                'Are you sure you want to logout?',
                                style: AppTheme.mutedStyle(14, isDark: isDark),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Cancel', style: TextStyle(color: mutedColor)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _logout(context);
                                  },
                                  child: const Text('Logout',
                                      style: TextStyle(color: Color(0xFFF87171))),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF87171).withOpacity(0.06),
                            border: Border.all(color: const Color(0xFFF87171).withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Color(0xFFF87171), size: 16),
                              SizedBox(width: 10),
                              Text(
                                'LOGOUT',
                                style: TextStyle(
                                  color: Color(0xFFF87171),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
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

// ── Usage Row ─────────────────────────────────────────────
class _UsageRow extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final String value;
  final Color borderColor;
  final Color? valueColor;
  final bool isLast;

  const _UsageRow({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.value,
    required this.borderColor,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gold, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: AppTheme.mutedStyle(14, isDark: isDark)),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Row ──────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final Color borderColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isLast;

  const _SettingsRow({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.borderColor,
    required this.onTap,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.gold, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AppTheme.mutedStyle(14, isDark: isDark)),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.gold.withOpacity(0.5),
                  size: 14,
                ),
          ],
        ),
      ),
    );
  }
}
