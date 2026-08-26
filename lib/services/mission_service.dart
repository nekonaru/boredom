import 'dart:math';
import '../models/mission.dart';
import 'mission_catalog.dart';

/// Filter yang dipilih user sebelum generate misi.
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

  /// Generate satu misi random sesuai filter.
  /// Kalau kombinasi filter terlalu ketat dan nggak ada yang cocok,
  /// filter dilonggarkan bertahap (energy -> mood -> waktu) supaya user
  /// tetap selalu dapat misi, bukan layar kosong.
  static Mission generate(MissionFilter filter, {bool chaosMode = false}) {
    if (chaosMode) {
      final pool = MissionCatalog.all;
      return pool[_random.nextInt(pool.length)];
    }

    final nonChaosPool =
        MissionCatalog.all.where((m) => !m.chaosOnly).toList();

    // Level 0: semua filter ketat.
    var candidates = _filterMissions(
      nonChaosPool,
      mood: filter.mood,
      timeBudget: filter.timeBudget,
      location: filter.location,
      energy: filter.energy,
    );
    if (candidates.isNotEmpty) return _pick(candidates);

    // Level 1: abaikan energy.
    candidates = _filterMissions(
      nonChaosPool,
      mood: filter.mood,
      timeBudget: filter.timeBudget,
      location: filter.location,
    );
    if (candidates.isNotEmpty) return _pick(candidates);

    // Level 2: abaikan energy & mood.
    candidates = _filterMissions(
      nonChaosPool,
      timeBudget: filter.timeBudget,
      location: filter.location,
    );
    if (candidates.isNotEmpty) return _pick(candidates);

    // Level 3: abaikan semua kecuali waktu (biar durasinya tetap masuk akal).
    candidates = _filterMissions(nonChaosPool, timeBudget: filter.timeBudget);
    if (candidates.isNotEmpty) return _pick(candidates);

    // Fallback terakhir: full random dari seluruh katalog non-chaos.
    return _pick(nonChaosPool);
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

  static Mission _pick(List<Mission> candidates) {
    return candidates[_random.nextInt(candidates.length)];
  }
}
