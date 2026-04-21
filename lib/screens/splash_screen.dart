import 'package:flutter/material.dart';
import 'package:aarogyamfin/theme/app_theme.dart';
import 'package:aarogyamfin/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _lineController;
  late AnimationController _taglineController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _lineAnim;
  late Animation<double> _taglineAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _lineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeOut),
    );
    _taglineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    // Sequence
    _fadeController.forward();
    _scaleController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      _lineController.forward();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      _taglineController.forward();
    });

    // Navigate to Login
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const LoginScreen(),
            transitionsBuilder: (_, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _lineController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Aarogyam',
                        style: AppTheme.heading(44, isDark: true),                      ),
                      TextSpan(
                        text: 'Fin',
                        style: AppTheme.heading(44).copyWith(
                          color: AppTheme.gold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Gold line animation
                AnimatedBuilder(
                  animation: _lineAnim,
                  builder: (context, child) {
                    return Container(
                      width: 200 * _lineAnim.value,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.gold,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Tagline
                FadeTransition(
                  opacity: _taglineAnim,
                  child: Text(
                    'AI FINANCIAL INTELLIGENCE',
                    style: AppTheme.label(11),
                  ),
                ),

                const SizedBox(height: 48),

                // Loading dots
                FadeTransition(
                  opacity: _taglineAnim,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      return _LoadingDot(delay: i * 200);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDot extends StatefulWidget {
  final int delay;
  const _LoadingDot({required this.delay});

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          color: AppTheme.gold,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
