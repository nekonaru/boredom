import '../models/mission.dart';
import '../models/user_progress.dart';
import 'mission_catalog.dart';

/// One observation about how the player actually behaves.
class Insight {
  final String emoji;
  final String titleEn;
  final String titleId;
  final String detailEn;
  final String detailId;

  const Insight({
    required this.emoji,
    required this.titleEn,
    required this.titleId,
    required this.detailEn,
    required this.detailId,
  });

  String title(String code) => code == 'id' ? titleId : titleEn;
  String detail(String code) => code == 'id' ? detailId : detailEn;
}

/// Derived observations about the player's completion history.
///
/// Every function here is pure and takes the history explicitly, so the
/// whole module is unit-testable without a provider or a clock. [now] is
/// injected for the same reason.
class Insights {
  const Insights._();

  /// Busiest hour of day, or null when there is not enough spread to be
  /// worth claiming a pattern. Requires at least 5 completions so a single
  /// lucky roll does not become "you are a morning person".
  static int? bestHour(List<CompletedMission> history) {
    // Scoped to real activity like every other metric here. Counting
    // skipped rows would let a user whose only clustered activity is
    // bailing out be told when they finish things.
    final rows = _active(history).toList();
    if (rows.length < 5) return null;
    final counts = List<int>.filled(24, 0);
    for (final e in rows) {
      counts[e.completedAt.hour]++;
    }
    // The peak must hold at least a quarter of all completions, otherwise
    // the "best" hour is just noise inside a flat distribution.
    var best = 0;
    for (var i = 1; i < 24; i++) {
      if (counts[i] > counts[best]) best = i;
    }
    if (counts[best] * 4 < rows.length) return null;
    return best;
  }

  /// Category the player bails out of most often. Only considers skipped
  /// outcomes, and only reports when there is at least one, so it never
  /// implies a problem the player does not have.
  static MissionCategory? mostSkippedCategory(List<CompletedMission> history) {
    final counts = <MissionCategory, int>{};
    for (final e in history) {
      if (e.outcome != MissionOutcome.skipped) continue;
      final category = _categoryOf(e);
      if (category == null) continue;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    var best = counts.keys.first;
    for (final c in counts.keys) {
      if ((counts[c] ?? 0) > (counts[best] ?? 0)) best = c;
    }
    return counts[best] == 1 && counts.length == 1 ? null : best;
  }

  /// Missions completed in the last 7 calendar days, ending today.
  ///
  /// Bounded on both sides. Without the upper bound a clock skew that left
  /// a future timestamp in the history would be counted as "this week",
  /// which the rest of the statistics already reject.
  static int inLastWeek(List<CompletedMission> history, DateTime now) {
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    return _active(history).where((e) => _within(e, start, now)).length;
  }

  /// Missions completed in the 7 calendar days before that.
  static int inPreviousWeek(List<CompletedMission> history, DateTime now) {
    final end = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 7));
    final start = end.subtract(const Duration(days: 6));
    return _active(history)
        .where((e) => !e.completedAt.isBefore(start) && e.completedAt.isBefore(end))
        .length;
  }

  /// Percent change between this week and last.
  ///
  /// Null when there is no baseline to compare against, which is the
  /// honest answer for a player's very first week rather than an
  /// invented +100 percent.
  static double? weekOverWeekChange(List<CompletedMission> history, DateTime now) {
    final current = inLastWeek(history, now);
    final previous = inPreviousWeek(history, now);
    if (previous == 0) return null;
    return (current - previous) / previous * 100;
  }

  /// Average XP earned per completion in the last 7 days.
  static int avgXpLastWeek(List<CompletedMission> history, DateTime now) {
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final rows =
        _active(history).where((e) => _within(e, start, now)).toList();
    if (rows.isEmpty) return 0;
    return rows.fold<int>(0, (sum, e) => sum + e.xpEarned) ~/ rows.length;
  }

  /// Inclusive lower bound, and nothing later than [now].
  static bool _within(
    CompletedMission e,
    DateTime start,
    DateTime now,
  ) =>
      !e.completedAt.isBefore(start) && !e.completedAt.isAfter(now);

  /// Builds the insight cards to show, in a stable order. Returns fewer
  /// than [max] when there is not enough history to justify them.
  static List<Insight> build(
    List<CompletedMission> history,
    DateTime now, {
    int max = 4,
  }) {
    final out = <Insight>[];

    final change = weekOverWeekChange(history, now);
    if (change != null) {
      final up = change >= 0;
      final magnitude = change.abs().round();
      out.add(
        Insight(
          emoji: up ? '📈' : '📉',
          titleEn: up ? 'Going up' : 'Slowing down',
          titleId: up ? 'Naik' : 'Melambat',
          detailEn: up
              ? '$magnitude percent more missions than last week.'
              : '$magnitude percent fewer missions than last week.',
          detailId: up
              ? '$magnitude persen lebih banyak misi dari minggu lalu.'
              : '$magnitude persen lebih sedikit misi dari minggu lalu.',
        ),
      );
    }

    final hour = bestHour(history);
    if (hour != null) {
      final label = '${hour.toString().padLeft(2, '0')}:00';
      out.add(
        Insight(
          emoji: '🕒',
          titleEn: 'Your hour',
          titleId: 'Jam favoritmu',
          detailEn: 'You finish most missions around $label.',
          detailId: 'Kamu menyelesaikan kebanyakan misi sekitar $label.',
        ),
      );
    }

    final skipped = mostSkippedCategory(history);
    if (skipped != null) {
      out.add(
        Insight(
          emoji: '🛋️',
          titleEn: 'Your escape hatch',
          titleId: 'Pelarianmu',
          detailEn:
              'You most often walk away from ${skipped.label} missions.',
          detailId:
              'Kamu paling sering meninggalkan misi ${skipped.labelFor('id')}.',
        ),
      );
    }

    final avg = avgXpLastWeek(history, now);
    if (avg > 0) {
      out.add(
        Insight(
          emoji: '⚡',
          titleEn: 'This week in XP',
          titleId: 'Minggu ini dalam XP',
          detailEn: 'About $avg XP per mission you finished.',
          detailId: 'Sekitar $avg XP per misi yang kamu selesaikan.',
        ),
      );
    }

    return out.take(max).toList();
  }

  static Iterable<CompletedMission> _active(List<CompletedMission> history) =>
      history.where((e) => e.outcome == null || e.outcome!.countsAsActivity);

  /// Resolves a history row back to its catalog category. Null for custom
  /// missions, daily challenges, and finished quest chains, whose rows
  /// carry ids that are not in the mission catalog.
  static MissionCategory? _categoryOf(CompletedMission entry) {
    final id = entry.missionId;
    if (id.startsWith('custom_') || id.startsWith('chain_')) return null;
    if (id.startsWith('dc_')) return MissionCategory.selfImprovement;
    for (final m in MissionCatalog.all) {
      if (m.id == id) return m.category;
    }
    return null;
  }
}
