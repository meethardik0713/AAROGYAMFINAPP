import 'package:flutter/material.dart';
import 'package:aarogyamfin/theme/app_theme.dart';
import 'package:aarogyamfin/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    final mutedColor = isDark ? AppTheme.darkMuted : AppTheme.lightMuted;

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Aarogyam',
                            style: AppTheme.heading(36, isDark: isDark),
                          ),
                          TextSpan(
                            text: 'Fin',
                            style: AppTheme.heading(36, isDark: isDark)
                                .copyWith(color: AppTheme.gold),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Gold line
                    Container(
                      width: 60,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.gold, Colors.transparent],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    Text(
                      'Welcome back.',
                      style: AppTheme.heading(32, isDark: isDark),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Sign in to access your financial intelligence dashboard.',
                      style: AppTheme.mutedStyle(14, isDark: isDark),
                    ),

                    const SizedBox(height: 60),

                    // Google Sign In Button
_GoogleSignInButton(
  isDark: isDark,
  onTap: () async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return;
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: const Color(0xFFF87171),
          ),
        );
      }
    }
  },
),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: borderColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('SECURE LOGIN', style: AppTheme.label(10)),
                        ),
                        Expanded(
                          child: Container(height: 1, color: borderColor),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Security note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, color: mutedColor, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          '256-bit SSL encrypted · Zero data storage',
                          style: AppTheme.mutedStyle(12, isDark: isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Theme toggle button — top right
              Positioned(
                top: 16,
                right: 16,
                child: _ThemeToggleButton(isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Theme Toggle ─────────────────────────────────────────
class _ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => themeNotifier.toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.darkSurface
              : AppTheme.lightSurface,
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          color: AppTheme.gold,
          size: 18,
        ),
      ),
    );
  }
}

// ── Google Sign In Button ────────────────────────────────
class _GoogleSignInButton extends StatefulWidget {
  final Future<void> Function() onTap;
  final bool isDark;
  const _GoogleSignInButton({required this.onTap, required this.isDark});

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) async {
        setState(() => _pressed = false);
        await widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _pressed
              ? AppTheme.gold.withOpacity(0.15)
              : AppTheme.gold.withOpacity(0.08),
          border: Border.all(
            color: _pressed
                ? AppTheme.gold.withOpacity(0.6)
                : widget.isDark
                    ? AppTheme.darkBorder
                    : AppTheme.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text('CONTINUE WITH GOOGLE', style: AppTheme.label(12)),
          ],
        ),
      ),
    );
  }
}
