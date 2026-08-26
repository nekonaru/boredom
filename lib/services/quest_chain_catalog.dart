import '../models/quest_chain.dart';

class QuestChainCatalog {
  static const List<QuestChain> all = [
    QuestChain(
      id: 'qc_touch_grass',
      title: 'Touch Grass Arc',
      emoji: '🌆',
      description: 'Rantai misi buat maksa diri kamu keluar dari kamar.',
      rewardXp: 500,
      steps: [
        QuestStep(title: 'Keluar Rumah', description: 'Keluar rumah selama minimal 10 menit.'),
        QuestStep(
          title: 'Tempat Baru',
          description: 'Cari tempat di sekitar kamu yang belum pernah kamu kunjungi.',
        ),
        QuestStep(title: 'Abadikan', description: 'Ambil satu foto di tempat itu.'),
        QuestStep(
          title: 'Diam Sejenak',
          description: 'Duduk di sana selama 15 menit tanpa membuka HP.',
        ),
        QuestStep(
          title: 'Refleksi',
          description: 'Tulis satu kalimat tentang pengalaman kamu barusan.',
        ),
      ],
    ),
    QuestChain(
      id: 'qc_creator_arc',
      title: 'Creator Arc',
      emoji: '🎬',
      description: 'Dari ide receh sampai jadi sesuatu yang beneran selesai.',
      rewardXp: 450,
      steps: [
        QuestStep(title: 'Cari Ide', description: 'Tulis 3 ide random buat sesuatu yang mau kamu buat.'),
        QuestStep(title: 'Pilih Satu', description: 'Pilih satu ide yang paling nyata buat dikerjain hari ini.'),
        QuestStep(title: 'Kerjain Draft', description: 'Bikin draft/kerangka kasar dari ide itu.'),
        QuestStep(title: 'Selesaikan', description: 'Selesaikan versi paling sederhana dari ide itu sampai bisa ditunjukin.'),
        QuestStep(title: 'Share', description: 'Tunjukin hasilnya ke minimal satu orang.'),
      ],
    ),
    QuestChain(
      id: 'qc_reset_arc',
      title: 'Reset Arc',
      emoji: '🔄',
      description: 'Buat hari-hari yang berasa berantakan dan butuh restart.',
      rewardXp: 400,
      steps: [
        QuestStep(title: 'Beresin Fisik', description: 'Rapihin satu ruangan/area yang paling berantakan.'),
        QuestStep(title: 'Beresin Digital', description: 'Hapus/arsipkan notifikasi dan file yang numpuk.'),
        QuestStep(title: 'Gerak Badan', description: 'Olahraga ringan atau jalan kaki minimal 15 menit.'),
        QuestStep(title: 'Rencana Besok', description: 'Tulis 3 hal yang mau kamu selesaikan besok.'),
      ],
    ),
  ];

  /// orElse fallback ke entri pertama - jaga-jaga kalau id chain lama
  /// (tersimpan di device user) nggak ketemu lagi di katalog saat ini.
  static QuestChain byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);
}
