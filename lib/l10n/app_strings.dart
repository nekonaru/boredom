import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
import '../providers/language_provider.dart';

/// Hand-written EN/ID string table (English is the source of truth).
///
/// This mirrors the Swara pattern (English default, Bahasa Indonesia
/// optional, persisted language choice) but without flutter_gen codegen or
/// the intl package, so the APK stays small. To add a new user-facing
/// string: add an EN/ID pair here, then use it via `context.str`.
class AppStrings {
  final String code;
  const AppStrings(this.code);

  bool get isId => code == 'id';

  String _pick(String en, String id) => isId ? id : en;

  // Navigation
  String get navHome => _pick('Home', 'Beranda');
  String get navMissions => _pick('Missions', 'Misi');
  String get navStats => _pick('Stats', 'Statistik');
  String get navAchievements => _pick('Achievements', 'Pencapaian');
  String get navProfile => _pick('Profile', 'Profil');

  // Home
  String get brand => 'B O R E D O M';
  String get headline => _pick('YOU ARE BORED.', 'KAMU LAGI BOSAN.');
  String get subhead => _pick('So... what now?', 'Jadi... mau ngapain?');
  String streak(int days) => isId ? 'STREAK $days HARI' : '$days DAY STREAK';
  String get secMood => 'MOOD';
  String get secTime => _pick('TIME AVAILABLE', 'WAKTU LUANG');
  String get secLocation => _pick('LOCATION', 'LOKASI');
  String get secEnergy => _pick('ENERGY', 'ENERGI');
  String get chaosTitle => 'CHAOS MODE';
  String get chaosDesc => _pick(
        'Ignore all preferences. Anything can come out.',
        'Abaikan semua preferensi. Misi apa pun bisa keluar.',
      );
  String get boredButton => "I'M BORED";
  String get chaosButton => 'CHAOS ME';
  String rerollsLeft(int n) => isId
      ? '$n reroll tersisa hari ini'
      : '$n reroll${n == 1 ? '' : 's'} left today';

  // Time budget labels
  String timeLabel(TimeBudget t) {
    switch (t) {
      case TimeBudget.fiveMin:
        return '5 min';
      case TimeBudget.fifteenMin:
        return '15 min';
      case TimeBudget.thirtyMin:
        return '30 min';
      case TimeBudget.oneHour:
        return _pick('1 hour', '1 jam');
      case TimeBudget.twoHourPlus:
        return _pick('2 hours+', '2 jam+');
    }
  }

  String minutesShort(int minutes) => '$minutes min';

  // Daily challenge
  String get todayChallenge =>
      _pick("TODAY'S CHALLENGE", 'TANTANGAN HARI INI');
  String challengeDone(int xp) => _pick(
        'Challenge complete! +$xp XP',
        'Tantangan selesai! +$xp XP',
      );

  // Mission sheet
  String missionNo(int n) => 'MISSION #${n.toString().padLeft(3, '0')}';
  String rerollBtn(int n) => 'REROLL ($n)';
  String get rerollEmpty => _pick(
        'Daily rerolls are used up. Try again tomorrow.',
        'Reroll harian sudah habis. Coba lagi besok.',
      );
  String get acceptBtn => _pick('ACCEPT & COMPLETE', 'TERIMA & SELESAIKAN');
  String get skipBtn => _pick('Skip for now', 'Lewati dulu');
  String xpSnack(int xp) =>
      _pick('Nice! +$xp XP', 'Mantap! +$xp XP');
  String get achievementSnack => _pick(
        'Achievement unlocked:',
        'Pencapaian terbuka:',
      );

  // Missions tab
  String get missionsTitle => _pick('Missions', 'Misi');
  String get historyTitle => _pick('History', 'Riwayat');
  String get historyEmpty => _pick(
        "No completed missions yet.\nGo back to Home and tap \"I'M BORED\".",
        'Belum ada misi yang selesai.\nKembali ke Beranda dan tekan "I\'M BORED".',
      );

  // Quest chains
  String get chainsTitle => 'Quest Chains';
  String get chainsDesc => _pick(
        'Step-by-step chains with a big XP reward at the end.',
        'Rantai misi bertahap dengan hadiah XP besar di akhir.',
      );
  String stepOf(int i, int n) =>
      isId ? 'Langkah $i/$n' : 'Step $i/$n';
  String get chainCancel => _pick('Cancel', 'Batalkan');
  String get chainStepDone => _pick('COMPLETE STEP', 'SELESAIKAN LANGKAH');
  String get chainFinish => _pick('FINISH CHAIN', 'SELESAIKAN RANTAI');
  String get abandonTitle => _pick(
        'Abandon this quest chain?',
        'Batalkan rantai misi ini?',
      );
  String get abandonBody => _pick(
        'Progress on this chain will be lost.',
        'Progres rantai ini akan hilang.',
      );
  String get abandonKeep => _pick('Keep going', 'Lanjutkan');
  String get abandonConfirm => _pick('Abandon', 'Batalkan');
  String chainComplete(String name, int xp) => _pick(
        '$name complete! +$xp XP',
        '$name tuntas! +$xp XP',
      );
  String get chainStepNext => _pick(
        'Step done, on to the next one!',
        'Langkah selesai, lanjut ke berikutnya!',
      );

  // Stats
  String get statsTitle => _pick('Statistics', 'Statistik');
  String get mTotalMissions => _pick('Total Missions', 'Total Misi');
  String get mLongestStreak => _pick('Longest Streak', 'Streak Terpanjang');
  String get mTotalRerolls => _pick('Total Rerolls', 'Total Reroll');
  String get mChaos => _pick('Chaos Missions', 'Misi Chaos');
  String days(int n) => isId ? '$n hari' : '$n day${n == 1 ? '' : 's'}';
  String get perCategory => _pick(
        'Missions per Category',
        'Misi per Kategori',
      );
  String get statsEmpty => _pick(
        'No data yet. Complete a few missions first.',
        'Belum ada data. Selesaikan beberapa misi dulu.',
      );

  // Achievements
  String get achievementsTitle => _pick('Achievements', 'Pencapaian');
  String get lockedName => '???';
  String get lockedDesc =>
      _pick('Not unlocked yet', 'Belum terbuka');

  // Profile
  String get profileTitle => _pick('Profile', 'Profil');
  String get mActiveStreak => _pick('Active Streak', 'Streak Aktif');
  String get mTotalXp => 'Total XP';
  String get mRerollsToday => _pick('Rerolls Today', 'Reroll Hari Ini');
  String get aboutTitle => _pick('About Boredom', 'Tentang Boredom');
  String get aboutBody => _pick(
        'All your progress (level, XP, streak, achievements, history) is stored locally on this phone. No account, no server.',
        'Semua progresmu (level, XP, streak, pencapaian, riwayat) tersimpan lokal di HP ini. Tanpa akun, tanpa server.',
      );
  String get languageTitle => _pick('Language', 'Bahasa');
  String get languageEnglish => 'English';
  String get languageIndonesian => 'Bahasa Indonesia';
  String get resetBtn => _pick('Reset Progress', 'Hapus Progres');
  String get resetTitle => _pick(
        'Reset all progress?',
        'Hapus semua progres?',
      );
  String get resetBody => _pick(
        'Level, XP, streak, achievements, quest chains, and mission history will all be deleted. This cannot be undone.',
        'Level, XP, streak, pencapaian, rantai misi, dan riwayat akan terhapus semua. Tidak bisa dikembalikan.',
      );
  String get dialogCancel => _pick('Cancel', 'Batal');
  String get resetConfirm => _pick('Reset', 'Hapus');
  String versionFooter(String v) => 'Boredom v$v';

  // History search (v1.3)
  String get searchHint => _pick('Search history...', 'Cari riwayat...');
  String get searchEmpty => _pick(
        'Nothing matches your search.',
        'Tidak ada yang cocok dengan pencarian.',
      );

  // Favorites (v1.3)
  String get favoritesTitle => _pick('Favorites', 'Favorit');
  String get favoritesEmpty => _pick(
        'No favorites yet. Tap the heart on a mission to pin it here.',
        'Belum ada favorit. Ketuk ikon hati pada misi untuk menyimpan di sini.',
      );
  String get sharedCopied => _pick(
        'Mission text copied. Paste it anywhere to share.',
        'Teks misi disalin. Tempel di mana saja untuk dibagikan.',
      );
  String get deleteTitle => _pick('Delete this mission?', 'Hapus misi ini?');
  String get deleteConfirm => _pick('Delete', 'Hapus');

  // Custom missions (v1.3)
  String get customTitle => _pick('Custom Missions', 'Misi Buatanmu');
  String get customDesc => _pick(
        'Missions you created yourself. Complete them for XP like normal ones.',
        'Misi yang kamu buat sendiri. Selesaikan untuk XP seperti misi biasa.',
      );
  String get customAdd => _pick('Add custom mission', 'Tambah misi sendiri');
  String get customNameHint => _pick('Mission title', 'Judul misi');
  String get customDescHint => _pick('What should you do?', 'Apa yang harus dilakukan?');
  String get customXp => _pick('XP reward', 'Hadiah XP');
  String get customSave => _pick('Save mission', 'Simpan misi');
  String get customEmpty => _pick(
        'No custom missions yet.',
        'Belum ada misi buatanmu.',
      );
  String get customInvalid => _pick(
        'Fill in a title and description first.',
        'Isi judul dan deskripsi dulu.',
      );
  String customDone(String name, int xp) => _pick(
        '$name done! +$xp XP',
        '$name selesai! +$xp XP',
      );

  // Backup (v1.3)
  String get backupTitle => _pick('Backup', 'Cadangan');
  String get backupDesc => _pick(
        'Copy your data as text, or paste it back to restore. Useful before switching phones.',
        'Salin datamu sebagai teks, atau tempel kembali untuk memulihkan. Berguna sebelum ganti HP.',
      );
  String get backupExport => _pick('Export data', 'Ekspor data');
  String get backupImport => _pick('Import data', 'Impor data');
  String get backupCopied => _pick(
        'Backup text copied. Keep it somewhere safe.',
        'Teks cadangan disalin. Simpan di tempat yang aman.',
      );
  String get backupPasteHint => _pick(
        'Paste backup text here',
        'Tempel teks cadangan di sini',
      );
  String get backupInvalid => _pick(
        'That text is not a valid Boredom backup.',
        'Teks itu bukan cadangan Boredom yang valid.',
      );
  String get backupRestored => _pick(
        'Backup restored. Welcome back!',
        'Cadangan dipulihkan. Selamat datang kembali!',
      );

  // Undo (v1.3)
  String get undoAction => _pick('Undo', 'Urungkan');
  String get undoDone => _pick(
        'Last mission restored.',
        'Misi terakhir dikembalikan.',
      );

  // Weekly chart + streak (v2.0)
  String get weekTitle => _pick('This Week', 'Minggu Ini');
  String get streakRisk => _pick(
        'Streak at risk: complete a mission today to keep it alive.',
        'Streak terancam: selesaikan satu misi hari ini agar tidak putus.',
      );
  String get shareBtn => _pick('Share', 'Bagikan');
  String shareText(String title, int xp, int level) => isId
      ? 'Aku baru saja menyelesaikan "$title" (+$xp XP) dan mencapai level $level di Boredom!'
      : 'I just completed "$title" (+$xp XP) and reached level $level on Boredom!';
}

/// Shortcut: grabs the strings for the active language.
/// Subscribes to LanguageProvider, so widgets rebuild on language switch.
extension StringsX on BuildContext {
  AppStrings get str {
    final code = Provider.of<LanguageProvider>(this, listen: true).code;
    return AppStrings(code);
  }
}

/// Picks the display title/description of catalog content by language.
/// English fields are canonical; Indonesian fields fall back to English
/// when missing so old or partial translations never render blank.
String localizedTitle({
  required String en,
  required String? id,
  required String code,
}) =>
    (code == 'id' && (id != null && id.isNotEmpty)) ? id : en;
