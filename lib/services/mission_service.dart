import 'dart:math';
import '../models/mission.dart';
import 'mission_catalog.dart';

/// Filter picked by the user before a mission is generated.
class MissionFilter {
  final Mood mood;
  final TimeBudget timeBudget;
  final LocationType location;
  final EnergyLevel energy;

  const MissionFilter({
    required this.mood,
    required this.timeBudget,
    required this.location,
    required this.energy,
  });
}

class MissionService {
  static final Random _random = Random();

  /// Rolls one random mission for the filter.
  /// When a filter combo is too strict and nothing matches, filters are
  /// relaxed step by step (energy, then mood, then location) so the user
  /// always gets a mission instead of an empty screen. Recently completed
  /// ids in [excludeIds] are skipped when possible so rolls feel fresh.
  /// Out-of-season missions are hidden, and picks are weighted toward
  /// least-played categories via [categoryCounts].
  static Mission generate(
    MissionFilter filter, {
    bool chaosMode = false,
    Set<String> excludeIds = const {},
    Map<String, int> categoryCounts = const {},
    DateTime? now,
  }) {
    final month = (now ?? DateTime.now()).month;
    if (chaosMode) {
      final pool = MissionCatalog.all
          .where((m) => m.months.isEmpty || m.months.contains(month))
          .toList();
      final source = pool.isEmpty ? MissionCatalog.all : pool;
      return _pickWeighted(source, categoryCounts);
    }

    final nonChaosPool = MissionCatalog.all
        .where((m) =>
            !m.chaosOnly &&
            (m.months.isEmpty || m.months.contains(month)))
        .toList();

    // Level 0: every filter strict.
    var candidates = _filterMissions(
      nonChaosPool,
      mood: filter.mood,
      timeBudget: filter.timeBudget,
      location: filter.location,
      energy: filter.energy,
    );
    final fresh = _withoutExcluded(candidates, excludeIds);
    if (fresh.isNotEmpty) return _pickWeighted(fresh, categoryCounts);
    if (candidates.isNotEmpty) return _pickWeighted(candidates, categoryCounts);

    // Level 1: ignore energy.
    candidates = _filterMissions(
      nonChaosPool,
      mood: filter.mood,
      timeBudget: filter.timeBudget,
      location: filter.location,
    );
    final fresh1 = _withoutExcluded(candidates, excludeIds);
    if (fresh1.isNotEmpty) return _pickWeighted(fresh1, categoryCounts);
    if (candidates.isNotEmpty) return _pickWeighted(candidates, categoryCounts);

    // Level 2: ignore energy and mood.
    candidates = _filterMissions(
      nonChaosPool,
      timeBudget: filter.timeBudget,
      location: filter.location,
    );
    final fresh2 = _withoutExcluded(candidates, excludeIds);
    if (fresh2.isNotEmpty) return _pickWeighted(fresh2, categoryCounts);
    if (candidates.isNotEmpty) return _pickWeighted(candidates, categoryCounts);

    // Level 3: keep only the time budget so durations stay sane.
    candidates = _filterMissions(nonChaosPool, timeBudget: filter.timeBudget);
    final fresh3 = _withoutExcluded(candidates, excludeIds);
    if (fresh3.isNotEmpty) return _pickWeighted(fresh3, categoryCounts);
    if (candidates.isNotEmpty) return _pickWeighted(candidates, categoryCounts);

    // Last resort: full random from the non-chaos catalog.
    return _pickWeighted(nonChaosPool, categoryCounts);
  }

  /// Higher weight for less-played categories (1/(1+count)), so variety
  /// grows naturally the more the user plays. Pure and unit-testable.
  static double weightFor(Mission mission, Map<String, int> counts) {
    final played = counts[mission.category.name] ?? 0;
    return 1.0 / (1.0 + played);
  }

  static Mission _pickWeighted(
    List<Mission> candidates,
    Map<String, int> counts,
  ) {
    var total = 0.0;
    for (final m in candidates) {
      total += weightFor(m, counts);
    }
    var roll = _random.nextDouble() * total;
    for (final m in candidates) {
      roll -= weightFor(m, counts);
      if (roll <= 0) return m;
    }
    return candidates[_random.nextInt(candidates.length)];
  }

  static List<Mission> _withoutExcluded(
    List<Mission> missions,
    Set<String> excludeIds,
  ) {
    if (excludeIds.isEmpty) return missions;
    return missions.where((m) => !excludeIds.contains(m.id)).toList();
  }

  static List<Mission> _filterMissions(
    List<Mission> pool, {
    Mood? mood,
    TimeBudget? timeBudget,
    LocationType? location,
    EnergyLevel? energy,
  }) {
    return pool.where((m) {
      if (mood != null && !m.moods.contains(mood)) return false;
      if (location != null && !m.locations.contains(location)) return false;
      if (energy != null && !m.energyLevels.contains(energy)) return false;
      if (timeBudget != null && m.maxTime.minutes > timeBudget.minutes) {
        return false;
      }
      return true;
    }).toList();
  }
}
