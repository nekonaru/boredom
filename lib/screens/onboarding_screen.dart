import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';

/// Walkthrough: 3 pages, skippable.
///
/// Shown automatically the first time only. Existing players can replay it
/// from Profile, in which case [popOnFinish] pops back to wherever it was
/// launched from instead of letting the startup gate swap the tree.
class OnboardingScreen extends StatefulWidget {
  final bool popOnFinish;
  const OnboardingScreen({super.key, this.popOnFinish = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final pages = [
      _OnboardingPageData(emoji: '🎲', title: s.onb1Title, body: s.onb1Body),
      _OnboardingPageData(emoji: '🔥', title: s.onb2Title, body: s.onb2Body),
      _OnboardingPageData(emoji: '🌍', title: s.onb3Title, body: s.onb3Body),
    ];
    final last = _page == pages.length - 1;

    return Scaffold(
      backgroundColor: pal.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _finish(context),
                child: Text(
                  s.onbSkip,
                  style: TextStyle(color: pal.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _OnboardingPage(data: pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page
                        ? pal.accent
                        : pal.textSecondary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (last) {
                      _finish(context);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(last ? s.onbStart : s.onbNext),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _finish(BuildContext context) {
    context.read<BoredomProvider>().completeOnboarding();
    // On a replay the startup gate is not driving this widget, so nothing
    // else would take the user back.
    if (widget.popOnFinish && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class _OnboardingPageData {
  final String emoji;
  final String title;
  final String body;
  const _OnboardingPageData({
    required this.emoji,
    required this.title,
    required this.body,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pal.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pal.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
