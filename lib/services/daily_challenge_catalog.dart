import '../models/daily_challenge.dart';

class DailyChallengeCatalog {
  static const List<DailyChallenge> all = [
    DailyChallenge(
      id: 'dc_01',
      title: 'Go Somewhere New',
      emoji: '🗺️',
      description: 'Pergi ke satu tempat yang belum pernah kamu datangi sebelumnya.',
      rewardXp: 150,
    ),
    DailyChallenge(
      id: 'dc_02',
      title: 'Digital Sunset',
      emoji: '🌇',
      description: 'Nggak buka media sosial selama 2 jam berturut-turut hari ini.',
      rewardXp: 120,
    ),
    DailyChallenge(
      id: 'dc_03',
      title: 'Random Act of Kindness',
      emoji: '💌',
      description: 'Lakuin satu hal baik buat orang lain tanpa mereka minta.',
      rewardXp: 100,
    ),
    DailyChallenge(
      id: 'dc_04',
      title: 'Learn & Teach',
      emoji: '📚',
      description: 'Pelajari satu hal baru, terus jelasin ke satu orang lain hari ini.',
      rewardXp: 130,
    ),
    DailyChallenge(
      id: 'dc_05',
      title: 'Full Send Cleanup',
      emoji: '🧹',
      description: 'Beresin satu ruangan penuh (bukan cuma satu sudut) sampai bener-bener rapi.',
      rewardXp: 140,
    ),
    DailyChallenge(
      id: 'dc_06',
      title: 'Cold Outreach',
      emoji: '📞',
      description: 'Telepon (bukan chat) satu orang yang udah lama nggak kamu hubungin.',
      rewardXp: 110,
    ),
    DailyChallenge(
      id: 'dc_07',
      title: 'No Excuses Workout',
      emoji: '💪',
      description: 'Olahraga minimal 20 menit, apapun bentuknya.',
      rewardXp: 130,
    ),
    DailyChallenge(
      id: 'dc_08',
      title: 'Create Something',
      emoji: '🎨',
      description: 'Bikin satu karya (tulisan, gambar, musik, kode) dari nol hari ini.',
      rewardXp: 150,
    ),
    DailyChallenge(
      id: 'dc_09',
      title: 'Money Audit',
      emoji: '💸',
      description: 'Review semua pengeluaran minggu ini dan catat satu hal yang bisa dihemat.',
      rewardXp: 100,
    ),
    DailyChallenge(
      id: 'dc_10',
      title: 'Silent Hour',
      emoji: '🤫',
      description: 'Habiskan 1 jam tanpa musik, video, atau suara apapun. Cuma kamu dan pikiranmu.',
      rewardXp: 120,
    ),
  ];

  /// Deterministik per tanggal - semua orang di tanggal yang sama dapat
  /// challenge yang sama, dan kalau app dibuka ulang di hari yang sama
  /// challenge-nya konsisten (nggak berubah-ubah).
  static DailyChallenge forDate(DateTime date) {
    final dayOfYear = int.parse(
      '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
    );
    final index = dayOfYear % all.length;
    return all[index];
  }

  static DailyChallenge byId(String id) => all.firstWhere((c) => c.id == id);
}
