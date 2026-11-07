import '../models/mission.dart';
import '../models/mission_step.dart';

/// Interactive step sequences for each mission.
///
/// Missions are not just accept/reward buttons: users see a short, concrete
/// checklist that matches what the mission actually asks. Steps are ordered
/// easiest-first so progress builds on every tap.
class MissionGuide {
  MissionGuide._();

  static MissionStep s(String emoji, String en, [String? id]) =>
      MissionStep(emoji: emoji, title: en, titleId: id);

  static final Map<String, List<MissionStep>> _steps = {
    // HOME / LAZY
    'home_01': [
      s('🎯', 'Pick the messiest corner', 'Pilih satu sudut paling berantakan'),
      s('🧹', 'Gather 10 items not needed there', 'Kumpulkan 10 barang yang tidak perlu'),
      s('✨', 'Dust/wipe and put 3 things back', 'Lap/pel dan kembalikan 3 barang ke tempatnya'),
    ],
    'home_02': [
      s('📚', 'Open your library', 'Buka library musikmu'),
      s('🎧', 'Find an old favorite album or playlist', 'Cari album/playlist lama favoritmu'),
      s('🔁', 'Listen through to the end', 'Dengarkan sampai habis'),
    ],
    'home_03': [
      s('🪑', 'Sit or stand with a tall spine', 'Duduk/berdiri dengan punggung tegak'),
      s('🙆', 'Roll neck and shoulders, then back 3x', 'Putar leher & pundak, lalu punggung 3x'),
      s('🫁', 'Three slow deep breaths', 'Tiga napas dalam perlahan'),
    ],
    'home_04': [
      s('👀', 'Open the fridge/kitchen', 'Buka kulkas atau dapur'),
      s('🥕', 'Pick 3 random ingredients', 'Pilih 3 bahan acak'),
      s('🍳', 'Cook or mix them into something', 'Olah jadi makanan/minuman'),
    ],
    'home_05': [
      s('📂', 'Open your gallery', 'Buka galeri foto'),
      s('🗑️', 'Mark 20 useless shots', 'Tandai 20 foto/screenshot tak berguna'),
      s('✅', 'Delete them all', 'Hapus semuanya'),
    ],

    // GAMES
    'game_01': [
      s('🎮', 'Open your game library', 'Buka library gamemu'),
      s('🕹️', 'Pick one you barely play', 'Pilih yang jarang kamu mainkan'),
      s('⏱️', 'Play at least 20 minutes', 'Main minimal 20 menit'),
    ],
    'game_02': [
      s('😈', 'Pick a hard difficulty quest or level', 'Pilih quest/level tersulit yang biasa kamu hindari'),
      s('⚔️', 'Play a full focused session', 'Main satu sesi penuh fokus'),
      s('🏳️', 'Finish it, or honestly note what blocked you', 'Selesaikan, atau catat jujur apa yang menghalangi'),
    ],
    'game_03': [
      s('📱', 'Open one light mobile game', 'Buka satu game ringan di ponsel'),
      s('🏆', 'Play until you earn an achievement or level up', 'Main sampai dapat achievement/naik level'),
    ],

    // CODE
    'code_01': [
      s('💭', 'Pick one small annoyance to fix', 'Pilih satu kendala kecilmu'),
      s('⌨️', 'Write the tiniest script or tool', 'Tulis script/tool sekecil mungkin'),
      s('🧪', 'Run it and see it work', 'Jalankan dan lihat berhasil'),
    ],
    'code_02': [
      s('📂', 'Open an old project', 'Buka proyek lama'),
      s('🐛', 'Find one postponed bug or TODO', 'Temukan 1 bug/TODO tertunda'),
      s('🔧', 'Fix it and commit', 'Perbaiki dan commit'),
    ],
    'code_03': [
      s('📖', 'Open a repo README', 'Buka README repo'),
      s('✏️', 'Refresh install steps or structure', 'Perbarui instruksi atau struktur'),
      s('💾', 'Save the changes', 'Simpan perubahannya'),
    ],
    'code_04': [
      s('🔍', 'Find one new language/library feature', 'Temukan 1 fitur bahasa/library baru'),
      s('🧪', 'Write a minimal example', 'Tulis contoh minimal'),
      s('▶️', 'Run the example', 'Jalankan contohnya'),
    ],

    // LEARNING
    'learn_01': [
      s('🎲', 'Open a random Wikipedia topic', 'Buka topik acak Wikipedia'),
      s('🔗', 'Follow 5 links in a row', 'Ikuti 5 link berturut-turut'),
      s('📝', 'Note one surprising fact', 'Catat 1 fakta mengejutkan'),
    ],
    'learn_02': [
      s('📚', 'Pick a language to learn', 'Pilih bahasa yang ingin dikuasai'),
      s('🔤', 'Look up 3 new words', 'Cari 3 kosakata baru'),
      s('🗣️', 'Say them out loud', 'Ucapkan dengan suara'),
    ],
    'learn_03': [
      s('🎥', 'Pick an educational video', 'Pilih video/dokumenter edukatif'),
      s('📺', 'Watch it without touching anything else', 'Tonton tanpa gangguan'),
      s('💡', 'Write one takeaway', 'Tulis 1 hal yang dipetik'),
    ],

    // CREATIVE
    'creative_01': [
      s('✏️', 'Get any pen and paper', 'Siapkan pena dan kertas'),
      s('👀', 'Look at something around you', 'Lihat satu benda di sekitarmu'),
      s('🖌️', 'Draw it, 10 minutes, no judgment', 'Gambar selama 10 menit, tanpa menghakimi'),
    ],
    'creative_02': [
      s('💭', 'Recall one moment from today', 'Ingat satu momen hari ini'),
      s('📝', 'Write 1 to 3 sentences about it', 'Tulis 1-3 kalimat tentang itu'),
      s('✅', 'Save it somewhere', 'Simpan di mana pun'),
    ],
    'creative_03': [
      s('🎲', 'Pick a random playlist theme', 'Pilih tema playlist acak'),
      s('🎵', 'Add 8 to 10 fitting songs', 'Tambahkan 8-10 lagu yang cocok'),
      s('💾', 'Name and save the playlist', 'Beri nama dan simpan'),
    ],

    // PHOTO
    'photo_01': [
      s('🔍', 'Scan for red objects', 'Cari benda berwarna merah'),
      s('📸', 'Frame and shoot all 3', 'Foto ketiganya'),
      s('✅', 'Check the shots', 'Periksa hasilnya'),
    ],
    'photo_02': [
      s('🔬', 'Pick one tiny object', 'Pilih satu objek kecil'),
      s('📷', 'Get as close as possible', 'Ambil se-dekat mungkin'),
      s('🧐', 'See how much detail appears', 'Lihat seberapa detail hasilnya'),
    ],
    'photo_03': [
      s('🌆', 'Check when the sky will be busiest', 'Cek kapan langit paling cantik'),
      s('🌤️', 'Face the best part of the sky', 'Bidik bagian terbaik langit'),
      s('🖼️', 'Keep the best one', 'Simpan yang paling bagus'),
    ],

    // OUTDOOR
    'outdoor_01': [
      s('👟', 'Step outside', 'Keluar rumah'),
      s('🚶', 'Walk aimlessly for 10 minutes', 'Jalan bebas arah 10 menit'),
      s('🌳', 'Notice three things you usually ignore', 'Perhatikan 3 hal yang biasa kamu abaikan'),
    ],
    'outdoor_02': [
      s('🗺️', 'Pick one nearby place you never visited', 'Pilih 1 tempat dekat rumah belum pernah kamu kunjungi'),
      s('📍', 'Go there now', 'Pergi ke sana sekarang'),
      s('👀', 'Spend 5 minutes looking around', 'Amati sekeliling 5 menit'),
    ],
    'outdoor_03': [
      s('🚶', 'Walk to the nearest shop', 'Jalan ke warung terdekat'),
      s('🥤', 'Buy one thing you have never tried', 'Beli 1 hal yang belum pernah kamu coba'),
      s('😋', 'Try it now', 'Coba sekarang'),
    ],
    'outdoor_04': [
      s('🪑', 'Sit somewhere outside', 'Duduk di luar'),
      s('📵', 'Put your phone away', 'Simpan ponsel jauh-jauh'),
      s('🌤️', 'Sit for 10 minutes fully present', 'Duduk 10 menit dengan sepenuhnya hadir'),
    ],

    // SOCIAL
    'social_01': [
      s('👤', 'Pick an old friend', 'Pilih satu teman lama'),
      s('💬', 'Send a short honest hello', 'Kirim sapaan singkat yang jujur'),
      s('⏱️', 'Wait for a reply, or accept the silence', 'Tunggu balasan, atau terima diamnya'),
    ],
    'social_02': [
      s('🎯', 'Pick one person to compliment', 'Pilih satu orang untuk dipuji'),
      s('💌', 'Send one genuine, specific compliment', 'Kirim 1 pujian tulus & spesifik'),
    ],
    'social_03': [
      s('💬', 'Open a quiet group chat', 'Buka grup chat yang sunyi'),
      s('😄', 'Drop something funny or interesting', 'Kirim sesuatu lucu atau menarik'),
      s('👀', 'See if it sparks a reply', 'Lihat apakah ada reaksi'),
    ],

    // SELF
    'self_01': [
      s('📝', 'Get any paper or note app', 'Siapkan kertas atau notes'),
      s('🗓️', 'Write to yourself one year from now', 'Tulis untuk dirimu 1 tahun ke depan'),
      s('✉️', 'Seal it somewhere you will find it', 'Simpan di tempat yang mudah ditemukan'),
    ],
    'self_02': [
      s('📊', 'Open last 3 days of spending', 'Buka catatan pengeluaran 3 hari terakhir'),
      s('💸', 'Spot one thing you can cut', 'Temukan 1 hal yang bisa dihemat'),
      s('✍️', 'Write down your commitment', 'Tulis komitmenmu'),
    ],
    'self_03': [
      s('📋', 'Pick one postponed task', 'Pilih satu tugas tertunda'),
      s('⏱️', 'Set a 25-minute timer', 'Setel timer 25 menit'),
      s('🎯', 'Work on it, zero distractions', 'Kerjakan, nol distraksi'),
    ],
    'self_04': [
      s('🔔', 'Open your notifications or inbox', 'Buka notifikasi atau inbox'),
      s('✅', 'Clear 10 items', 'Bersihkan 10 item'),
      s('🗑️', 'Archive the rest without guilt', 'Arsipkan sisanya tanpa rasa bersalah'),
    ],

    // ENTERTAINMENT
    'ent_01': [
      s('🎲', 'Pick a genre you avoid', 'Pilih genre yang biasa kamu hindari'),
      s('🎬', 'Watch a trailer or first episode', 'Tonton trailer atau episode pertama'),
      s('🤔', 'Decide: give it one full watch or drop it', 'Putuskan: beri satu kesempatan atau lepas'),
    ],
    'ent_02': [
      s('🕰️', 'Dig for old classics', 'Cari meme jadul'),
      s('😂', 'Pick the 5 funniest', 'Pilih 5 yang paling lucu'),
      s('📤', 'Send them to one person', 'Kirim ke satu orang'),
    ],

    // SEASONAL
    'seas_01': [
      s('🧹', 'Write 3 things you want to leave behind', 'Tulis 3 hal yang ingin kamu lepaskan'),
      s('✨', 'Write 1 thing you want to carry forward', 'Tulis 1 hal yang ingin kamu bawa'),
      s('📅', 'Review them after the season ends', 'Tinjau ulang setelah musim berlalu'),
    ],
    'seas_02': [
      s('📍', 'Find the closest public landmark', 'Temukan landmark terdekat'),
      s('🚶', 'Go visit it', 'Kunjungi'),
      s('📖', 'Learn one fact about it', 'Pelajari 1 fakta tentangnya'),
    ],
    'seas_03': [
      s('🎵', 'Assemble a 5-song rainy-day playlist', 'Kumpulkan 5 lagu suasana hujan'),
      s('🌧️', 'Listen by the window', 'Dengarkan dekat jendela'),
      s('☕', 'Let it carry you through the rain', 'Biarkan hujan lewat dari luar'),
    ],
    'seas_04': [
      s('👤', 'Pick one person who shaped you', 'Pilih satu orang yang membentukmu'),
      s('✍️', 'Write a raw thank-you note', 'Tulis ucapan terima kasih yang jujur'),
      s('💌', 'Deliver it if you can, keep it if you cannot', 'Kirim jika bisa, simpan jika tidak'),
    ],

    // EXTRA
    'extra_01': [
      s('📺', 'Find a 10-minute tutorial for a tool you use daily', 'Cari tutorial 10 menit untuk tool yang kamu pakai'),
      s('🔤', 'Write down one shortcut from it', 'Catat 1 shortcut dari sana'),
      s('💪', 'Use it today', 'Pakai hari ini juga'),
    ],
    'extra_02': [
      s('💬', 'Open one unread chat', 'Buka satu chat yang belum dibaca'),
      s('✏️', 'Draw a doodle instead of replying with words', 'Balas dengan doodle, bukan kata-kata'),
      s('📤', 'Send the doodle', 'Kirim doodlenya'),
    ],
    'extra_03': [
      s('🎮', 'Pick one boss or level that beat you', 'Pilih boss/level yang pernah mengalahkanmu'),
      s('⚔️', 'Fight until you win', 'Ulangi sampai menang'),
      s('🏅', 'Let yourself feel it', 'Rasakan kemenangan itu'),
    ],
    'extra_04': [
      s('👀', 'Pick someone you see every day but never talk to', 'Pilih orang yang sering kamu lihat tapi belum pernah diajak bicara'),
      s('🔎', 'Learn one genuine fact about them', 'Cari/pelajari 1 fakta tentang mereka'),
      s('🤝', 'Or say hello next time you pass', 'Atau sapa dia saat bertemu'),
    ],
    'extra_05': [
      s('🎵', 'Pick one song you love', 'Pilih satu lagu favorit'),
      s('🎤', 'Record 30 seconds', 'Rekam 30 detik'),
      s('💾', 'Keep the take', 'Simpan hasilnya'),
    ],
    'extra_06': [
      s('📱', 'Open your most-used app', 'Buka aplikasi paling sering kamu pakai'),
      s('🔤', 'Find 3 shortcuts you never use', 'Temukan 3 shortcut yang belum pernah kamu pakai'),
      s('✅', 'Use one of them right now', 'Coba salah satunya sekarang'),
    ],
    'extra_07': [
      s('🪑', 'Sit in silence for 5 minutes', 'Duduk tenang 5 menit'),
      s('🧠', 'Silently name 3 things that went well this week', 'Sebut dalam hati 3 hal baik minggu ini'),
      s('🙏', 'Feel grateful for them', 'Rasakan syukurnya'),
    ],
    'extra_08': [
      s('🌙', 'Choose a safe familiar route', 'Pilih rute aman yang sudah dikenal'),
      s('🚶', 'Walk for 15 minutes after dark', 'Jalan 15 menit setelah gelap'),
      s('⭐', 'Notice the stars or city lights', 'Perhatikan bintang atau lampu kota'),
    ],
    'extra_09': [
      s('👤', 'Pick one friend', 'Pilih satu teman'),
      s('🎬', 'Trade one trailer each', 'Tukar satu trailer masing-masing'),
      s('🎞️', 'Watch theirs, they watch yours', 'Tonton punya dia, dia tonton punyamu'),
    ],
    'extra_10': [
      s('🎯', 'Choose one thing you know well', 'Pilih satu hal yang kamu kuasai'),
      s('🗣️', 'Explain it to someone in under 5 minutes', 'Jelaskan ke seseorang dalam 5 menit'),
      s('✅', 'Check that they understood', 'Pastikan mereka paham'),
    ],
    'extra_11': [
      s('💭', 'Pick the smallest app idea', 'Pilih ide aplikasi sekecil mungkin'),
      s('⌨️', 'Prototype the core in 30 minutes', 'Prototype intinya dalam 30 menit'),
      s('👀', 'Show someone the thing you made', 'Tunjukkan ke orang'),
    ],
    'extra_12': [
      s('👤', 'Pick one person working toward something', 'Pilih satu orang yang sedang berjuang'),
      s('🔥', 'Send a short hype message', 'Kirim pesan semangat singkat'),
      s('💬', 'Tell them exactly why', 'Beritahu tepatnya kenapa'),
    ],

    // CHAOS
    'chaos_01': [
      s('🗺️', 'Open Maps', 'Buka Maps'),
      s('🎲', 'Pick a random point within 5 km', 'Pilih titik acak dalam 5 km'),
      s('🤔', 'Figure out how to get there', 'Pikirkan cara ke sana'),
    ],
    'chaos_02': [
      s('🧂', 'Close your eyes and point at 3 spices', 'Tutup mata, tunjuk 3 bumbu'),
      s('🍳', 'Use every one of them in one dish', 'Masukkan ketiganya dalam satu hidangan'),
      s('😋', 'Taste it, honestly', 'Cicipi, dengan jujur'),
    ],
    'chaos_03': [
      s('🌐', 'Find a stranger\'s post you genuinely like', 'Temukan post orang asing yang kamu sukai'),
      s('💬', 'Leave an honest positive comment', 'Tinggalkan komentar positif yang jujur'),
      s('🚫', 'No advice, no criticism', 'Tanpa nasihat, tanpa kritik'),
    ],
    'chaos_04': [
      s('👀', 'Notice your usual posture right now', 'Sadari posturmu sekarang'),
      s('🔄', 'Do the opposite for 10 minutes', 'Lakukan kebalikannya 10 menit'),
      s('🧘', 'Notice how different it feels', 'Rasakan bedanya'),
    ],
    'chaos_05': [
      s('🔠', 'A: round the room left to right', 'A ke J: sekeliling ruangan'),
      s('🔤', 'B through J: one object per letter', 'B sampai J: satu benda per huruf'),
      s('🗣️', 'Say them out loud', 'Ucapkan dengan suara'),
    ],

    // WELLNESS / PRO / SOCIAL
    'well_01': [
      s('🪑', 'Sit comfortably', 'Duduk dengan nyaman'),
      s('🫁', 'Five slow deep breaths', 'Lima napas dalam perlahan'),
      s('✨', 'Notice one calm sensation', 'Rasakan satu sensasi tenang'),
    ],
    'well_02': [
      s('📝', 'Open notes or paper', 'Buka notes atau kertas'),
      s('😊', 'Write 3 small things that went well today', 'Tulis 3 hal kecil baik hari ini'),
      s('🙏', 'Read them once, slowly', 'Baca sekali dengan pelan'),
    ],
    'well_03': [
      s('🥛', 'Fill one glass of water', 'Isi satu gelas air'),
      s('💧', 'Drink it all', 'Minum sampai habis'),
      s('💦', 'Notice how your body thanks you', 'Rasakan tubuhmu berterima kasih'),
    ],
    'prod_01': [
      s('📝', 'Write 3 things for tomorrow', 'Tulis 3 hal untuk besok'),
      s('🎯', 'Mark the most important one', 'Tandai yang paling penting'),
      s('👁️', 'Put it where you will see it first thing', 'Letakkan di tempat yang pertama kamu lihat besok'),
    ],
    'social_04': [
      s('👤', 'Pick one family member you have not talked to in a while', 'Pilih satu anggota keluarga'),
      s('📞', 'Call or message them', 'Hubungi mereka'),
      s('💬', 'Actually exchange real words', 'Benar-benar ngobrol, bukan sekadar sapa'),
    ],
    'photo_04': [
      s('🌿', 'Step outside', 'Keluar rumah'),
      s('📷', 'Photograph three green things', 'Foto 3 benda berwarna hijau'),
      s('🖼️', 'Keep the best one', 'Simpan yang paling bagus'),
    ],
    'learn_04': [
      s('📖', 'Pick any book', 'Ambil buku apa pun'),
      s('📃', 'Read exactly one page', 'Baca persis satu halaman'),
      s('✅', 'Close the book satisfied', 'Tutup bukunya dengan puas'),
    ],
    'outdoor_05': [
      s('🪑', 'Go sit somewhere outside', 'Duduk di luar'),
      s('👀', 'Watch people, birds, anything', 'Amati manusia, burung, apa pun'),
      s('📵', 'No screen for 10 minutes', 'Tanpa layar 10 menit'),
    ],
    'home_06': [
      s('🪴', 'Find the thirstiest plant', 'Temukan tanaman yang paling haus'),
      s('💧', 'Give it water', 'Siram dengan air'),
      s('🧹', 'Wipe the leaf dust if any', 'Lap debu daun jika ada'),
    ],
  };

  /// Steps for a mission; falls back to a category-aware sequence.
  static List<MissionStep> stepsFor(Mission mission) {
    final custom = _steps[mission.id];
    if (custom != null) return custom;
    return _categorySteps(mission.category);
  }

  static List<MissionStep> _categorySteps(MissionCategory category) {
    switch (category) {
      case MissionCategory.coding:
        return [
          s('💻', 'Open your project', 'Buka proyekmu'),
          s('⌨️', 'Do one small thing', 'Kerjakan satu hal kecil'),
          s('✅', 'Save it', 'Simpan'),
        ];
      case MissionCategory.learning:
        return [
          s('📚', 'Open one thing to study', 'Buka satu bahan belajar'),
          s('🧠', 'Spend 10 minutes with it', 'Luangkan 10 menit'),
          s('💡', 'Jot down one takeaway', 'Catat satu hal yang didapat'),
        ];
      case MissionCategory.creative:
        return [
          s('✨', 'Pick your creative tool', 'Pilih alat kreasi-mu'),
          s('✏️', 'Make something in 10 minutes', 'Buat sesuatu selama 10 menit'),
          s('👀', 'Look at what you made', 'Lihat karyamu'),
        ];
      case MissionCategory.social:
        return [
          s('👤', 'Pick one person', 'Pilih satu orang'),
          s('💬', 'Reach out', 'Hubungi'),
          s('🤝', 'Make a real connection', 'Jalin koneksi nyata'),
        ];
      case MissionCategory.outdoor:
        return [
          s('👟', 'Step outside', 'Keluar rumah'),
          s('🚶', 'Move for 10 minutes', 'Bergerak 10 menit'),
          s('🌤️', 'Notice your surroundings', 'Perhatikan sekeliling'),
        ];
      case MissionCategory.photography:
        return [
          s('📷', 'Get your camera', 'Ambil kamera'),
          s('🔍', 'Find your subject', 'Temukan subjeknya'),
          s('🎞️', 'Take the shot', 'Ambil fotonya'),
        ];
      case MissionCategory.gaming:
        return [
          s('🎮', 'Open your game', 'Buka gamemu'),
          s('⏱️', 'Set a timer for 20 minutes', 'Setel timer 20 menit'),
          s('🏆', 'Play focused', 'Main fokus'),
        ];
      case MissionCategory.entertainment:
        return [
          s('🎧', 'Sit down somewhere comfortable', 'Duduk nyaman'),
          s('📺', 'Enjoy for 15 minutes', 'Nikmati 15 menit'),
          s('✅', 'Close it when done', 'Tutup setelah selesai'),
        ];
      case MissionCategory.selfImprovement:
        return [
          s('🧭', 'Pick one tiny step', 'Pilih satu langkah kecil'),
          s('⏱️', 'Do it for 10 minutes', 'Lakukan 10 menit'),
          s('✅', 'Mark it complete', 'Tandai selesai'),
        ];
      case MissionCategory.custom:
      case MissionCategory.chaos:
        return [
          s('🎲', 'Read the mission once', 'Baca misi sekali'),
          s('✅', 'Do it', 'Lakukan'),
          s('🎉', 'Enjoy the result', 'Nikmati hasilnya'),
        ];
    }
  }
}
