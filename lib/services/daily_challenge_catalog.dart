import '../models/daily_challenge.dart';
import '../models/mission.dart';

class DailyChallengeCatalog {
  static const List<DailyChallenge> all = [
    DailyChallenge(
      id: 'dc_01',
      title: 'Go Somewhere New',
      titleId: 'Pergi ke Tempat Baru',
      emoji: '🗺️',
      description: 'Go somewhere you have never been before.',
      descriptionId: 'Pergi ke satu tempat yang belum pernah kamu datangi sebelumnya.',
      rewardXp: 150,
      category: MissionCategory.outdoor,
    ),
    DailyChallenge(
      id: 'dc_02',
      title: 'Digital Sunset',
      titleId: 'Matahari Terbenam Digital',
      emoji: '🌇',
      description: 'Stay off social media for 2 hours straight today.',
      descriptionId: 'Nggak buka media sosial selama 2 jam berturut-turut hari ini.',
      rewardXp: 120,
      category: MissionCategory.selfImprovement,
    ),
    DailyChallenge(
      id: 'dc_03',
      title: 'Random Act of Kindness',
      titleId: 'Kebaikan Acak',
      emoji: '💌',
      description: 'Do one kind thing for someone without being asked.',
      descriptionId: 'Lakuin satu hal baik buat orang lain tanpa mereka minta.',
      rewardXp: 100,
      category: MissionCategory.social,
    ),
    DailyChallenge(
      id: 'dc_04',
      title: 'Learn & Teach',
      titleId: 'Belajar dan Mengajar',
      emoji: '📚',
      description: 'Learn one new thing, then explain it to someone else today.',
      descriptionId: 'Pelajari satu hal baru, terus jelasin ke satu orang lain hari ini.',
      rewardXp: 130,
      category: MissionCategory.learning,
    ),
    DailyChallenge(
      id: 'dc_05',
      title: 'Full Send Cleanup',
      titleId: 'Beres-Beres Total',
      emoji: '🧹',
      description: 'Clean one entire room (not just one corner) until it is truly tidy.',
      descriptionId: 'Beresin satu ruangan penuh (bukan cuma satu sudut) sampai bener-bener rapi.',
      rewardXp: 140,
      category: MissionCategory.creative,
    ),
    DailyChallenge(
      id: 'dc_06',
      title: 'Cold Outreach',
      titleId: 'Telepon Dingin',
      emoji: '📞',
      description: 'Call (not chat) one person you have not contacted in ages.',
      descriptionId: 'Telepon (bukan chat) satu orang yang udah lama nggak kamu hubungin.',
      rewardXp: 110,
      category: MissionCategory.social,
    ),
    DailyChallenge(
      id: 'dc_07',
      title: 'No Excuses Workout',
      titleId: 'Olahraga Tanpa Alasan',
      emoji: '💪',
      description: 'Work out for at least 20 minutes, any form counts.',
      descriptionId: 'Olahraga minimal 20 menit, apapun bentuknya.',
      rewardXp: 130,
      category: MissionCategory.outdoor,
    ),
    DailyChallenge(
      id: 'dc_08',
      title: 'Create Something',
      titleId: 'Bikin Sesuatu',
      emoji: '🎨',
      description: 'Make one thing (writing, drawing, music, code) from scratch today.',
      descriptionId: 'Bikin satu karya (tulisan, gambar, musik, kode) dari nol hari ini.',
      rewardXp: 150,
      category: MissionCategory.creative,
    ),
    DailyChallenge(
      id: 'dc_09',
      title: 'Money Audit',
      titleId: 'Audit Keuangan',
      emoji: '💸',
      description: 'Review this week spending and note one thing to save on.',
      descriptionId: 'Review semua pengeluaran minggu ini dan catat satu hal yang bisa dihemat.',
      rewardXp: 100,
      category: MissionCategory.learning,
    ),
    DailyChallenge(
      id: 'dc_10',
      title: 'Silent Hour',
      titleId: 'Satu Jam Hening',
      emoji: '🤫',
      description: 'Spend 1 hour with no music, video, or sound. Just you and your thoughts.',
      descriptionId: 'Habiskan 1 jam tanpa musik, video, atau suara apapun. Cuma kamu dan pikiranmu.',
      rewardXp: 120,
      category: MissionCategory.selfImprovement,
    ),
  ];

  /// Deterministic per date: everyone on the same date gets the same
  /// challenge, and reopening the app on the same day keeps it stable.
  static DailyChallenge forDate(DateTime date) {
    final dayOfYear = int.parse(
      '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
    );
    final index = dayOfYear % all.length;
    return all[index];
  }

  /// orElse falls back to the first entry, so an old stored challenge id
  /// never crashes the app when the catalog changes.
  static DailyChallenge byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);

  /// True when [id] still resolves to a real catalog entry. Used to
  /// validate stored ids instead of trusting them, matching the stricter
  /// handling quest chains get.
  static bool idExists(String id) {
    for (final c in all) {
      if (c.id == id) return true;
    }
    return false;
  }
}
