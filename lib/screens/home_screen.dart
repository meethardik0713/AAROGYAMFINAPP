import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aarogyamfin/theme/app_theme.dart';
import 'package:aarogyamfin/main.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'results_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  int _currentTab = 0;

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName?.split(' ').first
        ?? user?.email?.split('@').first
        ?? 'there';
  }

  String get _userInitial {
    final name = _userName;
    return name[0].toUpperCase();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: _BottomNav(
        currentTab: _currentTab,
        isDark: isDark,
        onTap: (i) => setState(() => _currentTab = i),
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildHomeTab(),
          const ChatScreen(),
          const ProfileScreen(),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final mutedColor = isDark ? AppTheme.darkMuted : AppTheme.lightMuted;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Aarogyam',
                            style: AppTheme.heading(22, isDark: isDark),
                          ),
                          TextSpan(
                            text: 'Fin',
                            style: AppTheme.heading(22, isDark: isDark)
                                .copyWith(color: AppTheme.gold),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            themeNotifier.toggle();
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.wb_sunny_outlined
                                  : Icons.nightlight_round,
                              color: AppTheme.gold,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8),
                            color: surfaceColor,
                          ),
                          child: Center(
                            child: Text(
                              _userInitial,
                              style: const TextStyle(
                                color: AppTheme.gold,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Greeting ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting, style: AppTheme.mutedStyle(14, isDark: isDark)),
                    const SizedBox(height: 4),
                    Text('$_userName.', style: AppTheme.heading(36, isDark: isDark)),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.gold, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Upload Card ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: _UploadCard(isDark: isDark),
              ),
            ),

            // ── Stats Row ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    _StatCard(isDark: isDark, label: 'Banks\nSupported', value: '8+', icon: Icons.account_balance_outlined),
                    const SizedBox(width: 12),
                    _StatCard(isDark: isDark, label: 'Accuracy\nRate', value: '100%', icon: Icons.verified_outlined),
                    const SizedBox(width: 12),
                    _StatCard(isDark: isDark, label: 'Parse\nTime', value: '<3s', icon: Icons.bolt_outlined),
                  ],
                ),
              ),
            ),

            // ── Recent Section ───────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Text('RECENT ANALYSIS', style: AppTheme.label(11)),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.upload_file_outlined, color: mutedColor, size: 40),
                      const SizedBox(height: 16),
                      Text('No statements analyzed yet', style: AppTheme.mutedStyle(14, isDark: isDark)),
                      const SizedBox(height: 8),
                      Text(
                        'Upload your first bank statement\nto get started',
                        style: AppTheme.mutedStyle(12, isDark: isDark),
                        textAlign: TextAlign.center,
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

// ── Upload Card ───────────────────────────────────────────
class _UploadCard extends StatefulWidget {
  final bool isDark;
  const _UploadCard({required this.isDark});

  @override
  State<_UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<_UploadCard> {
  bool _pressed = false;
  String? _fileName;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    HapticFeedback.mediumImpact();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _isLoading = true;
      });

      final fileBytes = result.files.single.bytes;
      final filePath = kIsWeb ? null : result.files.single.path;
      final response = await ApiService.parsePdf(
        filePath, _fileName!,
        bytes: fileBytes != null ? List<int>.from(fileBytes) : null,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (response['success']) {
          final transactions = List<Map<String, dynamic>>.from(response['data']['transactions']);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ResultsScreen(filename: _fileName!, transactions: transactions),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response['error'] ?? 'Parse failed'),
            backgroundColor: const Color(0xFFF87171),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { HapticFeedback.lightImpact(); setState(() => _pressed = true); },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _pickFile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _pressed ? AppTheme.gold.withOpacity(0.08) : AppTheme.gold.withOpacity(0.04),
          border: Border.all(color: _pressed ? AppTheme.gold.withOpacity(0.5) : AppTheme.gold.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(_pressed ? 0.15 : 0.08),
                border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
              ),
              child: const Icon(Icons.upload_file_outlined, color: AppTheme.gold, size: 28),
            ),
            const SizedBox(height: 20),
            Text('Upload Bank Statement', style: AppTheme.heading(20, isDark: widget.isDark)),
            const SizedBox(height: 8),
            Text(
              'PDF · HDFC · SBI · Canara · Kotak · Axis\nPNB · BOB · ICICI and more',
              style: AppTheme.mutedStyle(12, isDark: widget.isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              color: AppTheme.gold,
              child: Text('CHOOSE FILE', style: AppTheme.label(11).copyWith(color: const Color(0xFF060810), letterSpacing: 2)),
            ),
            if (_fileName != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.gold.withOpacity(0.3))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppTheme.gold, size: 14),
                    const SizedBox(width: 8),
                    Flexible(child: Text(_fileName!, style: AppTheme.label(11), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 1.5),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.isDark, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: surfaceColor, border: Border.all(color: borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.gold, size: 18),
            const SizedBox(height: 12),
            Text(value, style: AppTheme.heading(22, isDark: isDark).copyWith(color: AppTheme.gold)),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.mutedStyle(10, isDark: isDark)),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentTab;
  final bool isDark;
  final Function(int) onTap;

  const _BottomNav({required this.currentTab, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    return Container(
      decoration: BoxDecoration(color: bg, border: Border(top: BorderSide(color: borderColor))),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', isActive: currentTab == 0, isDark: isDark, onTap: () => onTap(0)),
              _NavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'AI Chat', isActive: currentTab == 1, isDark: isDark, onTap: () => onTap(1)),
              _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', isActive: currentTab == 2, isDark: isDark, onTap: () => onTap(2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.isActive, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.gold.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon,
              color: isActive ? AppTheme.gold : (isDark ? const Color(0x73E8E4D9) : const Color(0x99000000)), size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10,
              color: isActive ? AppTheme.gold : (isDark ? const Color(0x73E8E4D9) : const Color(0x99000000)), letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
