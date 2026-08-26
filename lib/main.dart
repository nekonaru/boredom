import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boredom_provider.dart';
import 'screens/root_shell.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const BoredomApp());
}

class BoredomApp extends StatelessWidget {
  const BoredomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BoredomProvider()..init(),
      child: MaterialApp(
        title: 'Boredom',
        debugShowCheckedModeBanner: false,
        theme: buildBoredomTheme(),
        home: const _AppGate(),
      ),
    );
  }
}

/// Nunggu progress selesai dimuat dari local storage sebelum render UI utama,
/// biar nggak ada flicker "level 1 XP 0" sepersekian detik pas app dibuka.
class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BoredomProvider>();
    if (!provider.loaded) {
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
