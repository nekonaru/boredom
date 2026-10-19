import '../models/user_progress.dart';

/// Date windows offered above the history list.
enum HistoryRange { today, week, month, all }

/// Outcome filters offered above the history list.
enum HistoryFilter { all, done, partial, skipped, untracked }

/// Pure predicates behind the History screen filters.
///
/// Extracted out of the widget on purpose: as private methods on a
/// StatefulWidget they were untestable, and these are exactly the rules
/// most likely to be got wrong, since they decide what a user believes
/// about their own record.
class HistoryFilters {
  const HistoryFilters._();

  static bool matchesRange(
    CompletedMission entry,
    HistoryRange range, {
    required DateTime now,
  }) {
    final day = DateTime(
      entry.completedAt.year,
      entry.completedAt.month,
      entry.completedAt.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    // Calendar days, not elapsed hours.
    final diff = today.difference(day).inDays;
    // Negative means the row is stamped in the future, which only happens
    // when a device clock was wrong. Every other statistic in the app
    // rejects those, so the list must not display them either, not even
    // under "All time".
    if (diff < 0) return false;
    return switch (range) {
      HistoryRange.today => diff == 0,
      HistoryRange.week => diff < 7,
      HistoryRange.month => diff < 30,
      HistoryRange.all => true,
    };
  }

  static bool matchesOutcome(
    CompletedMission entry,
    HistoryFilter filter,
  ) {
    return switch (filter) {
      HistoryFilter.all => true,
      // Rows with no recorded outcome predate the feature, so they are
      // neither shown as successes nor hidden as failures.
      HistoryFilter.done => entry.outcome == MissionOutcome.done,
      HistoryFilter.partial => entry.outcome == MissionOutcome.partial,
      HistoryFilter.skipped => entry.outcome == MissionOutcome.skipped,
      HistoryFilter.untracked => entry.outcome == null,
    };
  }

  /// Applies the search text, date window and outcome filter together.
  ///
  /// [matches] supplies the localized text a row actually renders, so a
  /// search can never disagree with what the user can see on screen.
  static List<CompletedMission> apply(
    List<CompletedMission> history, {
    required String query,
    required HistoryRange range,
    required HistoryFilter outcome,
    required DateTime now,
    required String Function(CompletedMission entry) titleOf,
    required String Function(CompletedMission entry) categoryOf,
  }) {
    final q = query.trim().toLowerCase();
    return history
        .where((e) => matchesRange(e, range, now: now))
        .where((e) => matchesOutcome(e, outcome))
        .where(
          (e) =>
              q.isEmpty ||
              titleOf(e).toLowerCase().contains(q) ||
              categoryOf(e).toLowerCase().contains(q),
        )
        .toList();
  }

  /// True when no narrowing is active, used to pick the empty-state copy.
  static bool isUnfiltered({
    required String query,
    required HistoryRange range,
    required HistoryFilter outcome,
  }) =>
      query.trim().isEmpty &&
      range == HistoryRange.all &&
      outcome == HistoryFilter.all;
}
