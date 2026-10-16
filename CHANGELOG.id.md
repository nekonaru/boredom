# Changelog

## v2.2.0

Rilis personalisasi dan insight. Murni Dart, tanpa plugin atau izin
baru.

### Ditambahkan
- Tema terang plus 5 warna aksen, diganti di Profil bagian Tampilan.
  Setiap layar kini membaca palet semantik, bukan warna gelap yang
  di-hardcode.
- Haptic feedback saat ketuk dan selesai, dengan toggle di Profil.
- Statistik bulanan: grafik 30 hari terakhir, rata-rata XP per hari
  aktif, dan hari tersibuk.
- Tombol dislike di mission sheet: misi yang di-dislike berhenti keluar
  dari generator, dan dislike ikut dalam cadangan.

### Ditingkatkan
- Pill info, chip, dan batang grafik kini mengikuti tema aktif,
  bukan mengasumsikan latar gelap.

## v2.1.0

Rilis build dan kesan pertama. APK lebih kecil, branding sendiri, dan
sambutan yang layak untuk user baru.

### Ditambahkan
- Onboarding 3 halaman yang tampil sekali saat pertama buka (bisa
  dilewati), dalam English dan Bahasa Indonesia.
- Icon launcher custom (gambar dadu) dan latar splash gelap,
  menggantikan branding default Flutter. Murni vektor, tanpa dependency
  baru.

### Ditingkatkan
- Build rilis kini obfuscated dengan debug info terpisah, dan slice
  x86_64 yang tak terpakai dibuang, sehingga unduhan lebih kecil.
- Pembacaan data saat startup jalan bersamaan, bukan satu per satu.

## v2.0.2

Memperbaiki bug CI yang sudah ada sejak lama: step pencari APK menyalin
`app-release.apk` ke dirinya sendiri sehingga build gagal padahal
`flutter analyze`, `flutter test`, dan build APK sendiri semuanya lolos.
Tidak ada perubahan di aplikasi.

## v2.0.1

Hotfix untuk temuan CI (`flutter analyze`): path import yang salah di
`lib/l10n/app_strings.dart`, `throw` `FormatException` yang tidak
konstan, variabel lokal tak terpakai di `exportBackup`, dan dua `const`
yang kurang di test. Tidak ada perubahan perilaku.

## v2.0.0

Rilis polish: visibilitas progres dan keamanan streak, tetap tanpa
plugin native dan tanpa izin baru.

### Ditambahkan
- Grafik aktivitas mingguan di tab Statistik, digambar dengan
  CustomPainter tanpa dependency (tanpa package chart, tanpa bobot APK
  tambahan).
- Hari toleransi streak: streak kini selamat dari satu hari yang
  terlewat dan baru reset setelah dua hari. Banner peringatan muncul di
  Beranda saat streak terancam.
- Bagikan: salin misi apa pun sebagai teks dari mission sheet dan tempel
  di mana saja.
- Rilis GitHub per-tag dengan APK split-per-ABI
  (`.github/workflows/release.yml`), sehingga tiap versi otomatis punya
  artefak yang bisa diinstal.

### Ditingkatkan
- README ditulis ulang memakai template Swara, dalam English
  (`README.md`) dan Bahasa Indonesia (`README.id.md`).

## v1.3.0

Rilis fitur, dibangun di atas fondasi v1.2.0. Tidak ada penambahan
plugin native, jadi APK tetap ringan dan tidak perlu izin baru.

### Ditambahkan
- Misi buatan sendiri: buat misimu dengan judul, deskripsi, dan hadiah
  XP (5 sampai 200), selesaikan untuk XP seperti misi katalog, hapus
  kapan saja. Tersimpan lokal, ikut dalam cadangan.
- Favorit: ketuk hati di mission sheet untuk menyematkan misi katalog
  ke bagian Favorit di tab Misi.
- Pencarian riwayat: saring misi yang selesai berdasarkan judul atau
  kategori.
- Urungkan: menyelesaikan misi kini menawarkan aksi Urungkan 5 menit
  yang mengembalikan XP, streak, dan riwayat.
- Cadangan: ekspor semua data lokal sebagai teks (disalin ke clipboard)
  dan impor kembali untuk pulihkan, berguna sebelum ganti HP. Tetap
  sepenuhnya lokal, tanpa akun atau server.

### Ditingkatkan
- Roll misi melewati misi yang diselesaikan 7 hari terakhir selama masih
  ada alternatif, supaya tidak terasa berulang. Fallback dengan anggun
  saat semuanya baru saja diselesaikan.

## v1.2.0

Rilis fondasi: English sebagai default dengan opsi Indonesia, plus
optimisasi bobot dan rebuild. Tidak ada perubahan format data
tersimpan, jadi progres yang sudah ada di HP tetap terbaca setelah
update.

### Ditambahkan
- UI English sebagai default dengan switch Bahasa Indonesia di Profil
  (`lib/l10n/app_strings.dart`, `lib/providers/language_provider.dart`).
  Pola yang sama seperti Swara: English sebagai acuan, pilihan yang
  diingat, tabel tulis-tangan alih-alih codegen supaya APK tetap kecil.
- Setiap katalog (misi, pencapaian, tantangan harian, quest chain) kini
  membawa teks Inggris plus terjemahan Indonesia dengan fallback ke
  Inggris, sehingga tidak ada yang tampil kosong.
- Unit test: kurva level (`test/user_progress_test.dart`), fallback dan
  filter generator misi (`test/mission_service_test.dart`), cakupan
  string dan kewarasan katalog (`test/localization_test.dart`).

### Ditingkatkan
- Menghapus dependency `intl` (dipakai tepat satu kali). Label tanggal
  kini memakai `lib/utils/date_format.dart`, formatter 30 baris yang
  sadar locale.
- Menghapus dependency `cupertino_icons` yang tidak terpakai.
- `StorageService` memakai cache instance SharedPreferences alih-alih
  memintanya di setiap baca dan tulis.
- Layar kini rebuild selektif (`context.select` untuk baca,
  `context.read` untuk aksi) sehingga mengetuk satu chip tidak
  me-rebuild seluruh halaman.
- Daftar riwayat memakai lazy sliver builder, tetap murah walau 200
  entri.
- Semua komentar kode kini English agar selaras dengan repo lain.

### Diperbaiki
- Label budget waktu yang masih Indonesia dalam mode English
  ("1 jam", "2 jam+").

## v1.1.0

Audit menyeluruh terhadap codebase (models, providers, services,
screens, widgets). Hasilnya: arsitektur sudah solid, dengan satu bug
fungsional nyata plus beberapa item polish.

### Diperbaiki
- **Bug: XP bar menampilkan angka negatif untuk user baru.** Kurva level
  (`UserProgress.xpNeededForLevel`) punya off-by-one: level 1 dianggap
  butuh 50 XP untuk "dicapai", padahal user baru langsung start di
  level 1 dengan 0 XP. Sebelum total XP melewati 50 (yaitu sebelum
  menyelesaikan misi pertama, karena XP misi terkecil di katalog cuma
  15), XP bar menampilkan angka seperti "-50/100 XP". Terlihat di layar
  pertama yang dibuka semua user baru. Diperbaiki dengan menggeser basis
  kurva supaya level 1 mulai dari 0 XP.
- Tombol **REROLL** sekarang benar-benar ter-disable (bukan cuma
  nongolin snackbar) begitu jatah reroll harian habis.
- `flutter_lints` sudah ada di `pubspec.yaml` sejak awal tapi belum
  pernah aktif karena `analysis_options.yaml` belum ada. Ditambahkan.

### Ditingkatkan
- Achievement yang sudah unlock sekarang tampil duluan di grid
  Achievements (diurut dari yang paling baru di-unlock).
- Riwayat misi di tab Missions sekarang pakai `ListView.builder`
  (lazy-build), bukan `ListView` biasa, lebih ringan kalau riwayat
  sudah ratusan entri.
- Haptic feedback ringan pas ACCEPT dan COMPLETE misi serta pas reroll.
- Footer versi app plus link repo di tab Profile.

### Ditambahkan
- `LICENSE` (MIT).
- `analysis_options.yaml`.
- Roadmap lanjutan di README.

Tidak ada perubahan format data tersimpan, jadi progres yang sudah ada
di HP tetap terbaca normal setelah update.
