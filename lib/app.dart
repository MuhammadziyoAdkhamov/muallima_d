import 'package:flutter/material.dart';

import 'data/local_learning_store.dart';
import 'screens/splash_screen.dart';
import 'screens/home/home_screen.dart';

class ArabTiliApp extends StatefulWidget {
  const ArabTiliApp({super.key, required this.store});

  final LocalLearningStore store;

  @override
  State<ArabTiliApp> createState() => _ArabTiliAppState();
}

class _ArabTiliAppState extends State<ArabTiliApp> {
  late ThemeMode _themeMode =
      widget.store.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _toggleTheme() async {
    final isDark = _themeMode != ThemeMode.dark;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    await widget.store.setDarkMode(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lug'at — Arab tili",
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => LearningHomePage(
              store: widget.store,
              onThemeToggle: _toggleTheme,
            ),
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    const lavender = Color(0xFF9B72D8);

    final scheme = ColorScheme.fromSeed(
      seedColor: lavender,
      brightness: brightness,
      surface: isDark ? const Color(0xFF1A1628) : const Color(0xFFFDF8FF),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      // ✅ Transparent — FloatingPetalsBackground o'z gradientini ko'rsatsin
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF3D1F6E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
