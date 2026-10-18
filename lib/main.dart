import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boredom_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/root_shell.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const BoredomApp());
}

class BoredomApp extends StatelessWidget {
  const BoredomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BoredomProvider()..init()),
        ChangeNotifierProvider.value(value: LanguageProvider.instance..load()),
        ChangeNotifierProvider.value(value: ThemeProvider.instance..load()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, lang, tp, _) => MaterialApp(
          title: 'Boredom',
          debugShowCheckedModeBanner: false,
          theme: buildBoredomTheme(light: true, accent: tp.accent),
          darkTheme: buildBoredomTheme(light: false, accent: tp.accent),
          themeMode: tp.isLight ? ThemeMode.light : ThemeMode.dark,
          locale: lang.locale,
          home: const _AppGate(),
        ),
      ),
    );
  }
}

/// Waits for local progress to load before rendering the main UI,
/// so there is no "level 1, 0 XP" flicker for a split second on launch.
class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    final loaded = context.select<BoredomProvider, bool>((p) => p.loaded);
    final error = context.select<BoredomProvider, String?>((p) => p.loadError);
    if (!loaded) {
      final pal = context.palette;
      return Scaffold(
        backgroundColor: pal.background,
        body: Center(
          child: CircularProgressIndicator(color: pal.accent),
        ),
      );
    }
    if (error != null) return _LoadFailedScreen(message: error);
    final seenOnboarding = context.select<BoredomProvider, bool>(
      (p) => p.onboardingDone,
    );
    if (!seenOnboarding) return const OnboardingScreen();
    return const RootShell();
  }
}

/// Shown when local data could not be read at startup. Previously this
/// state was an endless spinner with no way out.
class _LoadFailedScreen extends StatelessWidget {
  final String message;
  const _LoadFailedScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Scaffold(
      backgroundColor: pal.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('😵', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Could not read your saved data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: pal.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your progress is still on this phone. Try again, and if it keeps '
                  'failing, restart the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: pal.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.read<BoredomProvider>().retryLoad(),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
