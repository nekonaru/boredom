import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Builds a shareable image card for a completed mission and hands it to
/// the platform share sheet. Uses dart:ui directly (no screenshot plugin,
/// no extra dependency) and shares the PNG bytes in memory.
class ShareCard {
  ShareCard._();
  static const double _width = 1080;
  static const double _height = 1080;

  /// Returns false when the platform cannot build or share the card.
  static Future<bool> shareMission({
    required String emoji,
    required String title,
    required String description,
    required int xp,
    required int level,
    required String levelTitle,
    required Color accent,
    Color background = const Color(0xFF0E0E12),
    Rect? origin,
  }) async {
    try {
      final bytes = await _renderPng(
        emoji: emoji,
        title: title,
        description: description,
        xp: xp,
        level: level,
        levelTitle: levelTitle,
        accent: accent,
        background: background,
      );
      await SharePlus.instance.share(
        ShareParams(
          text: 'Level $level on Boredom',
          files: [XFile.fromData(bytes, mimeType: 'image/png', name: 'boredom.png')],
          fileNameOverrides: const ['boredom.png'],
          sharePositionOrigin: origin,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('ShareCard failed: $e');
      return false;
    }
  }

  /// Shares plain text, used as the lightweight fallback.
  static Future<bool> shareText(String text, {Rect? origin}) async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: text, sharePositionOrigin: origin),
      );
      return true;
    } catch (e) {
      debugPrint('ShareCard text failed: $e');
      return false;
    }
  }

  static Future<Uint8List> _renderPng({
    required String emoji,
    required String title,
    required String description,
    required int xp,
    required int level,
    required String levelTitle,
    required Color accent,
    required Color background,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(_width, _height);

    // Background and a subtle accent glow band at the top.
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(80, 90, _width - 160, 300),
        const Radius.circular(48),
      ),
      Paint()..color = accent.withValues(alpha: 0.12),
    );

    _text(
      canvas,
      emoji,
      Offset(120, 150),
      fontSize: 160,
      color: const Color(0xFFF4F4F7),
    );
    _text(
      canvas,
      'MISSION COMPLETE',
      Offset(120, 430),
      fontSize: 36,
      color: accent,
      letterSpacing: 6,
      bold: true,
    );
    _text(
      canvas,
      title,
      Offset(120, 500),
      fontSize: 72,
      color: const Color(0xFFF4F4F7),
      bold: true,
      maxWidth: _width - 240,
      maxLines: 2,
    );
    _text(
      canvas,
      description,
      Offset(120, 650),
      fontSize: 40,
      color: const Color(0xFF9B9BA8),
      maxWidth: _width - 240,
      maxLines: 4,
    );

    // Footer: XP, level, level title.
    final footerY = 880.0;
    canvas.drawRect(
      Rect.fromLTWH(120, footerY - 40, _width - 240, 4),
      Paint()..color = accent.withValues(alpha: 0.4),
    );
    _text(
      canvas,
      '+$xp XP',
      Offset(120, footerY),
      fontSize: 56,
      color: const Color(0xFF57D19C),
      bold: true,
    );
    _text(
      canvas,
      'LV.$level  $levelTitle',
      Offset(420, footerY + 8),
      fontSize: 40,
      color: const Color(0xFF9B9BA8),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(_width.toInt(), _height.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  /// Draws [text] at [origin], wrapping into [maxLines] when needed.
  /// Returns nothing; overflow is clipped by the layout itself.
  static void _text(
    Canvas canvas,
    String text,
    Offset origin, {
    required double fontSize,
    required Color color,
    bool bold = false,
    double letterSpacing = 0,
    double? maxWidth,
    int maxLines = 1,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
          letterSpacing: letterSpacing,
          height: 1.25,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth ?? _width);
    painter.paint(canvas, origin);
  }
}