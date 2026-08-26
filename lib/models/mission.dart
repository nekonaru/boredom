/// Kategori misi. Dipakai buat filtering & statistik nanti.
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
      case MissionCategory.chaos:
        return 'Chaos';
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
        return '1 jam';
      case TimeBudget.twoHourPlus:
        return '2 jam+';
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

/// Satu entri di katalog misi (definisi statis, bukan instance yang sudah diterima user).
class Mission {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final MissionCategory category;
  final int difficulty; // 1-5
  final int baseXp;
  final TimeBudget maxTime; // misi butuh waktu <= ini
  final Set<Mood> moods;
  final Set<LocationType> locations;
  final Set<EnergyLevel> energyLevels;
  final bool chaosOnly; // hanya muncul di Chaos Mode

  const Mission({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.baseXp,
    required this.maxTime,
    required this.moods,
    required this.locations,
    required this.energyLevels,
    this.chaosOnly = false,
  });

  String get difficultyStars => '⭐' * difficulty + '☆' * (5 - difficulty);
}

/// Misi yang sudah "digenerate" untuk sesi ini - dibungkus nomor urut biar berasa game.
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
