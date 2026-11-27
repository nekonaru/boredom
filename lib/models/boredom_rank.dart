/// Cosmetic rank derived from lifetime XP. Ranks are a lens over progress,
/// never stored state, so an old save gains a rank automatically and a
/// future threshold change cannot desync a persisted field.
enum BoredomRank { bronze, silver, gold, diamond, mythic }

class RankTier {
  final BoredomRank id;
  final int minXp;
  final String emoji;
  final String titleEn;
  final String titleId;

  const RankTier({
    required this.id,
    required this.minXp,
    required this.emoji,
    required this.titleEn,
    required this.titleId,
  });
}

class BoredomRanks {
  BoredomRanks._();

  /// Thresholds chosen so an engaged player reaches each tier in roughly a
  /// week, a month, a season, and a long run. New players start at bronze.
  static const List<RankTier> tiers = [
    RankTier(
      id: BoredomRank.bronze,
      minXp: 0,
      emoji: '🥉',
      titleEn: 'Bronze',
      titleId: 'Perunggu',
    ),
    RankTier(
      id: BoredomRank.silver,
      minXp: 500,
      emoji: '🥈',
      titleEn: 'Silver',
      titleId: 'Perak',
    ),
    RankTier(
      id: BoredomRank.gold,
      minXp: 2000,
      emoji: '🥇',
      titleEn: 'Gold',
      titleId: 'Emas',
    ),
    RankTier(
      id: BoredomRank.diamond,
      minXp: 6000,
      emoji: '💎',
      titleEn: 'Diamond',
      titleId: 'Berlian',
    ),
    RankTier(
      id: BoredomRank.mythic,
      minXp: 15000,
      emoji: '👑',
      titleEn: 'Mythic',
      titleId: 'Mitik',
    ),
  ];

  static RankTier forXp(int totalXp) {
    for (var i = tiers.length - 1; i >= 0; i--) {
      if (totalXp >= tiers[i].minXp) return tiers[i];
    }
    return tiers.first;
  }

  /// XP needed before the next rank, or null at the final tier.
  static int? xpToNext(int totalXp) {
    final current = forXp(totalXp);
    final index = tiers.indexOf(current);
    if (index >= tiers.length - 1) return null;
    return tiers[index + 1].minXp - totalXp;
  }

  static String title(int totalXp, {String code = 'en'}) {
    final tier = forXp(totalXp);
    return code == 'id' ? tier.titleId : tier.titleEn;
  }
}
