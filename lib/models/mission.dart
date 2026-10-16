/// Mission category. Used for filtering and statistics.
enum MissionCategory {
  gaming,
  entertainment,
  creative,
  coding,
  learning,
  photography,
  outdoor,
  social,
  selfImprovement,
  custom,
  chaos,
}

extension MissionCategoryX on MissionCategory {
  String get label {
    switch (this) {
      case MissionCategory.gaming:
        return 'Gaming';
      case MissionCategory.entertainment:
        return 'Entertainment';
      case MissionCategory.creative:
        return 'Creative';
      case MissionCategory.coding:
        return 'Coding';
      case MissionCategory.learning:
        return 'Learning';
      case MissionCategory.photography:
        return 'Photography';
      case MissionCategory.outdoor:
        return 'Outdoor';
      case MissionCategory.social:
        return 'Social';
      case MissionCategory.selfImprovement:
        return 'Self-Improvement';
      case MissionCategory.custom:
        return 'Custom';
      case MissionCategory.chaos:
        return 'Chaos';
    }
  }

  String labelFor(String code) {
    if (code != 'id') return label;
    switch (this) {
      case MissionCategory.selfImprovement:
        return 'Pengembangan Diri';
      case MissionCategory.custom:
        return 'Buatanmu';
      case MissionCategory.chaos:
        return 'Chaos';
      default:
        return label;
    }
  }
}

enum Mood { lazy, bored, normal, energetic, curious }

extension MoodX on Mood {
  String get emoji {
    switch (this) {
      case Mood.lazy:
        return '😴';
      case Mood.bored:
        return '😐';
      case Mood.normal:
        return '🙂';
      case Mood.energetic:
        return '🔥';
      case Mood.curious:
        return '🧠';
    }
  }

  String get label {
    switch (this) {
      case Mood.lazy:
        return 'Lazy';
      case Mood.bored:
        return 'Bored';
      case Mood.normal:
        return 'Normal';
      case Mood.energetic:
        return 'Energetic';
      case Mood.curious:
        return 'Curious';
    }
  }
}

enum TimeBudget { fiveMin, fifteenMin, thirtyMin, oneHour, twoHourPlus }

extension TimeBudgetX on TimeBudget {
  int get minutes {
    switch (this) {
      case TimeBudget.fiveMin:
        return 5;
      case TimeBudget.fifteenMin:
        return 15;
      case TimeBudget.thirtyMin:
        return 30;
      case TimeBudget.oneHour:
        return 60;
      case TimeBudget.twoHourPlus:
        return 120;
    }
  }

  String get label {
    switch (this) {
      case TimeBudget.fiveMin:
        return '5 min';
      case TimeBudget.fifteenMin:
        return '15 min';
      case TimeBudget.thirtyMin:
        return '30 min';
      case TimeBudget.oneHour:
        return '1 hour';
      case TimeBudget.twoHourPlus:
        return '2 hours+';
    }
  }
}

enum LocationType { home, outside, computer, anywhere }

extension LocationTypeX on LocationType {
  String get emoji {
    switch (this) {
      case LocationType.home:
        return '🏠';
      case LocationType.outside:
        return '🌆';
      case LocationType.computer:
        return '💻';
      case LocationType.anywhere:
        return '📱';
    }
  }

  String get label {
    switch (this) {
      case LocationType.home:
        return 'Home';
      case LocationType.outside:
        return 'Outside';
      case LocationType.computer:
        return 'Computer';
      case LocationType.anywhere:
        return 'Anywhere';
    }
  }
}

enum EnergyLevel { low, medium, high }

extension EnergyLevelX on EnergyLevel {
  String get emoji {
    switch (this) {
      case EnergyLevel.low:
        return '🪫';
      case EnergyLevel.medium:
        return '🔋';
      case EnergyLevel.high:
        return '⚡';
    }
  }

  String get label {
    switch (this) {
      case EnergyLevel.low:
        return 'Low';
      case EnergyLevel.medium:
        return 'Medium';
      case EnergyLevel.high:
        return 'High';
    }
  }
}

/// One entry in the mission catalog (a static definition, not a user-facing
/// instance). English fields are canonical; the *Id fields hold the
/// Indonesian translation and fall back to English when empty.
class Mission {
  final String id;
  final String title;
  final String description;
  final String? titleId;
  final String? descriptionId;
  final String emoji;
  final MissionCategory category;
  final int difficulty; // 1-5
  final int baseXp;
  final TimeBudget maxTime; // mission takes at most this long
  final Set<Mood> moods;
  final Set<LocationType> locations;
  final Set<EnergyLevel> energyLevels;
  final bool chaosOnly; // only shows up in Chaos Mode
  final Set<int> months; // 1-12, empty means available all year

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    this.titleId,
    this.descriptionId,
    required this.emoji,
    required this.category,
    required this.difficulty,
    required this.baseXp,
    required this.maxTime,
    required this.moods,
    required this.locations,
    required this.energyLevels,
    this.chaosOnly = false,
    this.months = const {},
  });

  String get difficultyStars => '⭐' * difficulty + '☆' * (5 - difficulty);
}

/// A generated mission for this session, wrapped with a running number
/// so it feels like a game.
class MissionInstance {
  final Mission mission;
  final int missionNumber;
  final bool isChaos;

  MissionInstance({
    required this.mission,
    required this.missionNumber,
    this.isChaos = false,
  });
}
