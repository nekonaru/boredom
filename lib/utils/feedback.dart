import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/boredom_provider.dart';

/// Single haptic tap, honoring the user setting in Profile.
/// Call from button handlers (never from build methods).
void buzzIfEnabled(BuildContext context) {
  if (!context.read<BoredomProvider>().hapticsEnabled) return;
  HapticFeedback.lightImpact();
}
