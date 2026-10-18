import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:renty/utils/language_manager.dart';
import 'package:renty/utils/theme_manager.dart';
import 'package:renty/utils/favorites_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:renty/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/core/blocs/blocs.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:renty/utils/translations.dart';
import 'package:renty/core/services/secure_storage_service.dart';

late SharedPreferences sharedPref;

// In-memory token cache so synchronous callers (interceptors) can read the
// token without blocking on async Keystore/Keychain I/O.
String? cachedToken;
String? cachedRefreshToken;
String? cachedUserId;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPreferences.getInstance();

  // ── SECURITY: Root / Jailbreak Detection ─────────────────────────────────
  // Check before loading any user data. On compromised devices the attacker
  // can bypass app sandboxing and read Keystore-backed secrets with root.
  bool isRooted = false;
  try {
    isRooted = await FlutterJailbreakDetection.jailbroken;
  } catch (_) {
    isRooted = false; // Fail open — detection error should not block users
  }

  if (isRooted) {
    runApp(_RootedBlockerApp());
    return;
  }

  // ── Warm up secure token cache ────────────────────────────────────────────
  cachedToken        = await SecureStorageService.getToken();
  cachedRefreshToken = await SecureStorageService.getRefreshToken();
  cachedUserId       = await SecureStorageService.getUserId();

  // Initialize managers
  await LanguageManager.initialize();
  await ThemeManager.initialize();
  await FavoritesManager.initialize();

  runApp(const MyApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// Blocking screen for rooted / jailbroken devices
// ─────────────────────────────────────────────────────────────────────────────
class _RootedBlockerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 80, color: Color(0xFFEF4444)),
                const SizedBox(height: 24),
                const Text(
                  'Security Alert',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This device appears to be rooted or jailbroken.\n\n'
                  'Renty cannot run on compromised devices to protect your '
                  'financial data and privacy.',
                  style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => SystemNavigator.pop(),
                    child: const Text(
                      'Close App',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Main app
// ─────────────────────────────────────────────────────────────────────────────
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  void _loadUserPreferences() {
    // user_id is now in secure storage (cached in cachedUserId)
    final userId = cachedUserId;
    if (userId != null && userId.isNotEmpty) {
      LanguageManager.setCurrentUser(userId);
      ThemeManager.setCurrentUser(userId);
      FavoritesManager.setCurrentUser(userId);
    }

    // Load saved language (non-sensitive — stays in SharedPreferences)
    final languageCode = LanguageManager.getCurrentLanguageCode();
    _locale = Locale(languageCode);

    // Load saved theme (non-sensitive — stays in SharedPreferences)
    _themeMode = ThemeManager.getThemeMode();

    setState(() {});
  }

  void changeLanguage(String languageCode) async {
    await LanguageManager.setLanguage(languageCode);
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  void changeTheme(ThemeMode themeMode) async {
    await ThemeManager.setThemeMode(themeMode);
    setState(() {
      _themeMode = themeMode;
    });
  }

  String _getInitialRoute() {
    // Use the in-memory cache populated from Keystore/Keychain at startup
    if (cachedUserId != null && cachedUserId!.isNotEmpty) {
      return '/main';
    }
    final step = sharedPref.getString('step');
    if (step == '1') return '/login';
    return '/onboarding';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>.value(
          value: NavigationCubit.instance,
        ),
        BlocProvider<NotificationBadgeCubit>.value(
          value: NotificationBadgeCubit.instance,
        ),
      ],
      child: MaterialApp(
        title: 'Renty',
        debugShowCheckedModeBanner: false,
        navigatorKey: AppNavigator.navigatorKey,
        scaffoldMessengerKey: AppNavigator.messengerKey,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        supportedLocales: const [
          Locale('en', ''),
          Locale('ar', ''),
        ],

        locale: _locale,

        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: _themeMode,

        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: _getInitialRoute(),
      ),
    );
  }
}
