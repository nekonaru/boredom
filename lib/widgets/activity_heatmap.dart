import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../widgets/kit.dart';

/// GitHub-style year view of activity. 365 cells, drawn with one painter so
/// a dense year never becomes 365 widgets. Tap a cell to read its count.
class ActivityHeatmap extends StatefulWidget {
  /// Map of day -> number of completed missions on that day.
  final Map<DateTime, int> counts;
  const ActivityHeatmap({super.key, required this.counts});

  @override
  State<ActivityHeatmap> createState() => _ActivityHeatmapState();
}

class _ActivityHeatmapState extends State<ActivityHeatmap> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List<DateTime>.generate(365, (i) {
      return today.subtract(Duration(days: 364 - i));
    });
    final selectedCount = _selected == null ? 0 : (widget.counts[_selected] ?? 0);

    return AppKit.card(
      color: pal.surface,
      padding: const EdgeInsets.all(AppKit.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final local = box.globalToLocal(details.globalPosition);
              final i = _indexAt(local, box.size);
              if (i != null && i >= 0 && i < days.length) {
                setState(() => _selected = days[i]);
              }
            },
            child: AspectRatio(
              aspectRatio: 2.1,
              child: CustomPaint(
                painter: _HeatmapPainter(
                  days: days,
                  counts: widget.counts,
                  selected: _selected,
                  active: pal.accent,
                  empty: pal.emptyBar,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppKit.sm),
          Text(
            _selected == null
                ? '365 days of activity'
                : '${_selected!.day}/${_selected!.month}: $selectedCount',
            style: TextStyle(color: pal.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// Maps a tap position to a day index using the same geometry as the
  /// painter: 53 columns of 7 rows, laid out newest column on the right.
  int? _indexAt(Offset point, Size size) {
    const columns = 53;
    const rows = 7;
    final cell = size.width / columns;
    final col = (point.dx / cell).floor();
    final row = (point.dy / (size.height / rows)).floor();
    if (col < 0 || col >= columns || row < 0 || row >= rows) return null;
    // Painter fills column-major with day 0 at column 0 row (weekday-1).
    return col * rows + row;
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<DateTime> days;
  final Map<DateTime, int> counts;
  final DateTime? selected;
  final Color active;
  final Color empty;

  const _HeatmapPainter({
    required this.days,
    required this.counts,
    required this.selected,
    required this.active,
    required this.empty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    const columns = 53;
    const rows = 7;
    final cellW = size.width / columns;
    final cellH = size.height / rows;
    final inset = cellW < 6 ? 0.5 : 1.5;
    final max = counts.values.fold<int>(1, (a, b) => a > b ? a : b);

    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      final col = i ~/ rows;
      final row = i % rows;
      final count = counts[day] ?? 0;
      final intensity = count == 0 ? 0.0 : (0.25 + 0.75 * count / max);
      final color = count == 0
          ? empty
          : active.withValues(alpha: intensity.clamp(0.0, 1.0));
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          col * cellW + inset,
          row * cellH + inset,
          (cellW - inset * 2).clamp(0.0, cellW),
          (cellH - inset * 2).clamp(0.0, cellH),
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      if (selected != null && day == selected) {
        canvas.drawRRect(
          rect,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter old) =>
      old.days != days ||
      old.counts != counts ||
      old.selected != selected ||
      old.active != active ||
      old.empty != empty;
}
