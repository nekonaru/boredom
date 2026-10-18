import '../models/quest_chain.dart';
import '../models/mission.dart';

class QuestChainCatalog {
  static const List<QuestChain> all = [
    QuestChain(
      id: 'qc_touch_grass',
      title: 'Touch Grass Arc',
      titleId: 'Arc Keluar Rumah',
      emoji: '🌆',
      description: 'A chain of missions to force yourself out of your room.',
      descriptionId: 'Rantai misi buat maksa diri kamu keluar dari kamar.',
      rewardXp: 500,
      category: MissionCategory.outdoor,
      steps: [
        QuestStep(
          title: 'Leave the House',
          titleId: 'Keluar Rumah',
          description: 'Go outside for at least 10 minutes.',
          descriptionId: 'Keluar rumah selama minimal 10 menit.',
        ),
        QuestStep(
          title: 'Somewhere New',
          titleId: 'Tempat Baru',
          description: 'Find a place near you that you have never visited.',
          descriptionId: 'Cari tempat di sekitar kamu yang belum pernah kamu kunjungi.',
        ),
        QuestStep(
          title: 'Capture It',
          titleId: 'Abadikan',
          description: 'Take one photo at that place.',
          descriptionId: 'Ambil satu foto di tempat itu.',
        ),
        QuestStep(
          title: 'Sit Still',
          titleId: 'Diam Sejenak',
          description: 'Sit there for 15 minutes without opening your phone.',
          descriptionId: 'Duduk di sana selama 15 menit tanpa membuka HP.',
        ),
        QuestStep(
          title: 'Reflect',
          titleId: 'Refleksi',
          description: 'Write one sentence about the experience.',
          descriptionId: 'Tulis satu kalimat tentang pengalaman kamu barusan.',
        ),
      ],
    ),
    QuestChain(
      id: 'qc_creator_arc',
      title: 'Creator Arc',
      titleId: 'Arc Kreator',
      emoji: '🎬',
      description: 'From a random idea to something actually finished.',
      descriptionId: 'Dari ide receh sampai jadi sesuatu yang beneran selesai.',
      rewardXp: 450,
      category: MissionCategory.creative,
      steps: [
        QuestStep(
          title: 'Find Ideas',
          titleId: 'Cari Ide',
          description: 'Write down 3 random ideas for something to make.',
          descriptionId: 'Tulis 3 ide random buat sesuatu yang mau kamu buat.',
        ),
        QuestStep(
          title: 'Pick One',
          titleId: 'Pilih Satu',
          description: 'Pick the one idea most realistic to finish today.',
          descriptionId: 'Pilih satu ide yang paling nyata buat dikerjain hari ini.',
        ),
        QuestStep(
          title: 'Draft It',
          titleId: 'Kerjain Draft',
          description: 'Make a rough draft or skeleton of that idea.',
          descriptionId: 'Bikin draft/kerangka kasar dari ide itu.',
        ),
        QuestStep(
          title: 'Finish It',
          titleId: 'Selesaikan',
          description: 'Finish the simplest version of the idea so it can be shown.',
          descriptionId: 'Selesaikan versi paling sederhana dari ide itu sampai bisa ditunjukin.',
        ),
        QuestStep(
          title: 'Share It',
          titleId: 'Bagikan',
          description: 'Show the result to at least one person.',
          descriptionId: 'Tunjukin hasilnya ke minimal satu orang.',
        ),
      ],
    ),
    QuestChain(
      id: 'qc_reset_arc',
      title: 'Reset Arc',
      titleId: 'Arc Reset',
      emoji: '🔄',
      description: 'For messy days that need a restart.',
      descriptionId: 'Buat hari-hari yang berasa berantakan dan butuh restart.',
      rewardXp: 400,
      category: MissionCategory.selfImprovement,
      steps: [
        QuestStep(
          title: 'Tidy Physically',
          titleId: 'Beresin Fisik',
          description: 'Tidy the messiest room or area.',
          descriptionId: 'Rapihin satu ruangan/area yang paling berantakan.',
        ),
        QuestStep(
          title: 'Tidy Digitally',
          titleId: 'Beresin Digital',
          description: 'Delete or archive piled-up notifications and files.',
          descriptionId: 'Hapus/arsipkan notifikasi dan file yang numpuk.',
        ),
        QuestStep(
          title: 'Move Your Body',
          titleId: 'Gerak Badan',
          description: 'Light exercise or a walk, at least 15 minutes.',
          descriptionId: 'Olahraga ringan atau jalan kaki minimal 15 menit.',
        ),
        QuestStep(
          title: 'Plan Tomorrow',
          titleId: 'Rencana Besok',
          description: 'Write 3 things to get done tomorrow.',
          descriptionId: 'Tulis 3 hal yang mau kamu selesaikan besok.',
        ),
      ],
    ),
    QuestChain(
      id: 'qc_deep_work',
      title: 'Deep Work Arc',
      titleId: 'Arc Kerja Fokus',
      emoji: '🎯',
      description: 'From scattered attention to one finished piece of work.',
      descriptionId: 'Dari perhatian yang buyar sampai satu pekerjaan yang selesai.',
      rewardXp: 450,
      category: MissionCategory.learning,
      steps: [
        QuestStep(
          title: 'Pick the One Thing',
          titleId: 'Pilih Satu Hal',
          description: 'Write the single task that matters most today.',
          descriptionId: 'Tulis satu tugas yang paling penting hari ini.',
        ),
        QuestStep(
          title: 'Clear the Deck',
          titleId: 'Bersihkan Arena',
          description: 'Silence notifications and close every unrelated tab.',
          descriptionId: 'Matikan notifikasi dan tutup semua tab yang tidak berkaitan.',
        ),
        QuestStep(
          title: 'One Pomodoro',
          titleId: 'Satu Pomodoro',
          description: 'Work on it for 25 minutes with a timer running.',
          descriptionId: 'Kerjakan selama 25 menit dengan timer menyala.',
        ),
        QuestStep(
          title: 'Ship It',
          titleId: 'Kirim',
          description: 'Finish or hand off the smallest shippable version.',
          descriptionId: 'Selesaikan atau serahkan versi terkecil yang bisa dikirim.',
        ),
      ],
    ),
  ];

  /// orElse falls back to the first entry, so an old stored chain id
  /// never crashes the app when the catalog changes.
  static QuestChain byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);
}
