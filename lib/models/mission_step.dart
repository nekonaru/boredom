/// One small, actionable step inside a mission.
///
/// Steps make the mission interactive instead of a single binary accept.
/// Every step is a tiny, concrete task the player can actually tap off.
/// English fields are canonical; the *Id fields hold the Indonesian
/// translation and fall back to English when missing.
class MissionStep {
  final String emoji;
  final String title;
  final String? titleId;

  const MissionStep({
    required this.emoji,
    required this.title,
    this.titleId,
  });
}
