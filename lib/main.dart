import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aarogyamfin/theme/app_theme.dart';
import 'package:aarogyamfin/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://nehapaqtsjpzetuxutuv.supabase.co',
    anonKey: 'sb_publishable_3MDkLjxOX6ugz9uB66KguQ_IRMhJPxQ',
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AarogyamFinApp());
}

// ── Theme Notifier ────────────────────────────────────────
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness:
            _isDark ? Brightness.light : Brightness.dark,
      ),
    );
    notifyListeners();
  }
}

// Global instance
final themeNotifier = ThemeNotifier();

// ── App ───────────────────────────────────────────────────
class AarogyamFinApp extends StatefulWidget {
  const AarogyamFinApp({super.key});

  @override
  State<AarogyamFinApp> createState() => _AarogyamFinAppState();
}

class _AarogyamFinAppState extends State<AarogyamFinApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(() => setState(() {}));
    supabase.auth.onAuthStateChange.listen((data) {
      if ((data.event == AuthChangeEvent.signedIn || 
           data.event == AuthChangeEvent.initialSession) && 
          data.session != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AarogyamFin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
      home: _getHomeScreen(),
    );
  }

  Widget _getHomeScreen() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      return const HomeScreen();
    }
    return const SplashScreen();
  }
}
