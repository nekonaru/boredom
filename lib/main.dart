import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boredom_provider.dart';
import 'providers/language_provider.dart';
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
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, lang, _) => MaterialApp(
          title: 'Boredom',
          debugShowCheckedModeBanner: false,
          theme: buildBoredomTheme(),
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
    if (!loaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }
    return const RootShell();
  }
}
