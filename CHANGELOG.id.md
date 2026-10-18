# Changelog

## v2.5.0

Menutup empat masalah lama yang masih tersisa dari audit sebelumnya.
Format penyimpanan tidak berubah, jadi semua simpanan dan cadangan lama
tetap terbaca.

### Ditambahkan
- **Riwayat sekarang mengikuti bahasa aktif.** Entri dulu menampilkan
  judul dan kategori versi Inggris yang dibekukan saat misi diselesaikan,
  jadi pengguna Bahasa Indonesia mendapat daftar berbahasa Inggris. Judul
  dan kategori kini diambil dari katalog sesuai bahasa aktif.
- **Pencarian riwayat sesuai dengan yang tampil.** Sempat mencari teks
  Inggris yang tersimpan, sehingga mencari kata berbahasa Indonesia tidak
  menemukan apa pun yang terlihat di layar.

### Ditingkatkan
- **Misi buatan kini muncul di rincian statistik.** Sempat selalu
  terhitung di total dan terekam per kategori, tapi barisnya disembunyikan,
  sehingga jumlah batangnya tidak sama dengan angka "misi selesai" di atas
  sana.
- **Grafik aktivitas mewarnai ulang saat tema atau aksen diganti.**
  Sempat hanya membandingkan jumlah batangnya, sehingga mengganti terang/
  gelap atau aksen menyisakan warna lama di layar. Daftar juga dibandingkan
  berdasarkan identitas, sehingga data yang identik tetap dianggap berubah.

### Diperbaiki
- **Kartu berbagi menampilkan XP akhir pekan yang terlalu kecil.** Misi
  terbuka sebelum misi diterima, jadi kartu menampilkan nilai dasar:
  separuh dari yang sebenarnya bernilai di akhir pekan.

## v2.4.3

Audit ketiga, difokuskan pada sistem undo dan penghitung inbox.


### Diperbaiki
- **Undo bisa membuat penghitung misi tersimpan rusak secara
  permanen.** Snapshot progress membawa `missionsSaved`, tetapi daftar
  inbox tidak ikut tersimpan. Simpan misi setelah menyelesaikan satu,
  lalu undo, dan penghitungnya mundur sementara daftarnya tetap berisi.
  Setiap penghapusan berikutnya memperbesar selisihnya, dan achievement
  berbasis jumlah simpanan bisa berhenti muncul. Keduanya kini berjalan
  bersama.
- **Achievement jumlah simpanan terbuka tanpa pemberitahuan.** Sempat
  tersimpan tapi tidak pernah ditampilkan ke pengguna, berbeda dengan
  semua achievement lain.
- **Percobaan ulang saat startup gagal bisa menghitung pembukaan
  aplikasi lebih dari sekali**, cukup untuk membuka achievement streak 7
  hari tanpa bantuan apa pun. Pembukaan kini dihitung paling banyak satu
  kali per hari.
- **Undo bisa meninggalkan quest chain di penyimpanan** padahal aplikasi
  sudah membuangnya dari memori. Nilai kosong kini ikut ditulis.

## v2.4.2

Audit kedua, difokuskan pada perbaikan di v2.4.1 sendiri. Format
penyimpanan tetap aditif, jadi semua simpanan dan cadangan lama tetap
terbaca.

### Diperbaiki
- **Pengingat harian hanya berbunyi sekali.** `zonedSchedule` dipakai
  tanpa `matchDateTimeComponents`, yang membuatnya sekali jalan. Kini
  dijadwalkan dengan `DateTimeComponents.time`, jadi benar-benar
  berulang setiap hari seperti yang dijanjikan pengaturan.
- **Bonus milestone tidak pernah berlaku untuk tantangan harian dan
  quest chain.** Dua pemanggilan itu mengirim nilai dasar 0, sehingga
  perbandingan level sebelum dan sesudah selalu sama.
- **"Mulai kerjakan" di Kotak Masuk bisa menimpa misi yang masih
  menunggu diterima.** Pemulihan kini ditolak dan entri inbox
  dipertahankan, jadi tidak ada yang hilang.
- **Saat aplikasi dibuka bisa macet di spinner tanpa akhir** jika data
  lokal tidak terbaca. Kini ada layar error dengan tombol coba lagi.
- **Ekspor cadangan menghasilkan JSON tidak valid** ketika misi buatan
  memuat tab atau carriage return, karena hanya backslash, kutip, dan
  newline yang di-escape.
- **Impor cadangan bisa dihancurkan oleh input tempelan.** Ukuran dan
  kedalaman nesting kini dibatasi, serta escape unicode dan angka rusak
  ditolak alih-alih melempar keluar dari parser.

## v2.4.1

Rilis perbaikan bug dari audit kode menyeluruh terhadap v2.4.0. Tidak ada
perubahan format, jadi semua simpanan dan cadangan lama tetap terbaca.

### Diperbaiki
- **Misi yang selesai bisa tidak muncul di tab Misi.** Riwayat dimutasi
  in-place, sedangkan `context.select` membandingkan dengan
  `DeepCollectionEquality` yang menganggap mutasi in-place sebagai
  "tidak berubah", jadi layarnya tidak pernah rebuild. Kini riwayat
  membuat list baru. Akar masalah yang sama diperbaiki untuk Favorit dan
  Kategori yang dimatikan, yang tombolnya sebelumnya tampak mati.
- **Riwayat bisa kehilangan entri terbaru.** `saveHistory` menulis list
  in-memory (terbaru dulu) dengan urutan salah dan memotong ujung yang
  keliru, sehingga setelah undo di batas 200 entri setiap penyelesaian
  berikutnya diam-diam menghapus entri sebelumnya. Kini urutan
  dibalik ke oldest-first dan memotong yang tertua.
- **Impor cadangan tidak pernah menyimpan riwayat**, jadi XP yang
  dipulihkan tidak cocok dengan daftar riwayat setelah aplikasi dibuka
  lagi. Impor kini juga atomik: entri rusak tidak mengubah data kamu.
- **"Mulai kerjakan" di Kotak Masuk membuat misi hilang.** Misi yang
  dipulihkan disimpan di slot yang selalu ditimpa roll berikutnya. Sheet
  kini langsung dibuka untuk misi tersebut.
- **Urungkan setelah menyelesaikan Quest Chain merusak chain.** XP
  dikembalikan tetapi chain-nya hilang. Urungkan kini mengembalikan
  chain dan state tantangan harian juga.
- **Bonus XP milestone berulang di setiap penyelesaian** selama level
  berada di kelipatan sepuluh, memberi ratusan XP gratis di level 20.
  Bonus kini hanya dibayar saat batas benar-benar terlewati.
- **Pencapaian level menampilkan total XP** ("4500/10") bukan level.
- **XP ganda akhir pekan dilaporkan dengan nilai dasar** di toast
  tantangan harian dan misi buatan.
- **Mematikan semua kategori diam-diam mematikan fitur mute.** Mematikan
  kategori terakhir kini ditolak dengan penjelasan.
- **Chaos Mode mengabaikan kategori yang dimatikan**, bertentangan dengan
  pengaturannya.
- **Reset Progress meninggalkan pengingat harian aktif**, sehingga
  notifikasi muncul lagi setelah aplikasi dibuka.
- Reset dan impor cadangan kini membersihkan sisa state toast "+XP" dan
  membatasi jumlah langkah chain terhadap katalog saat ini.
- Peringatan streak terancam kini juga mencakup kasus 3 hari dengan token
  beku, dan tantangan harian berganti hari saat aplikasi dibuka kembali
  setelah tengah malam, bukan lagi menampilkan tantangan kemarin.
- Kegagalan berbagi kini fallback ke berbagi teks, bukan diam saja.
- Mission sheet kini bisa di-scroll dengan batas tinggi, sehingga konten
  panjang dan ukuran teks besar tidak lagi meluber.
- Menghapus kode mati: `inboxRestored`, `sharedCopied`, `weekdaysShort`,
  `shareBtn`.

## v2.4.0

Rilis fitur aditif. Simpanan dan cadangan lama tetap terbaca, dan ini
versi pertama yang meminta izin notifikasi (opt-in, mati secara
default, diminta hanya saat kamu menyalakan pengingat).

### Ditambahkan
- Notifikasi pengingat harian pada waktu pilihanmu, dengan toggle dan
  pemilih waktu di Profil. Izin hanya diminta saat dinyalakan.
- Share card: misi apa pun dirender jadi PNG 1080x1080 (emoji, judul,
  deskripsi, XP, level) memakai dart:ui lalu dikirim ke menu berbagi
  sistem.
- Kotak masuk (Inbox): simpan misi untuk nanti lewat tombol bookmark,
  lalu mulai kerjakan saat siap. Maksimal 50 entri dan ikut dalam
  cadangan.
- Toggle misi kilat: membatasi roll ke misi 15 menit atau kurang.
- Tidak tertarik: matikan satu kategori penuh dari mission sheet, atau
  kelola kategori yang dimatikan di Profil.
- Strip ringkasan mingguan di Beranda: jumlah misi, XP, dan streak
  saat ini.
- Bonus XP milestone saat penyelesaian melewati setiap level kelipatan 10.
- Urungkan kini mencakup tantangan harian, langkah quest chain, dan
  misi buatanmu, bukan hanya misi hasil roll.
- 4 pencapaian baru untuk token beku yang didapat dan misi yang
  disimpan, plus progress bar untuk setiap pencapaian yang dilacak.
- Progress bar pencapaian di bawah grid.

### Ditingkatkan
- CI dinaikkan ke Flutter 3.47.7 agar plugin notifikasi dan share
  terbaru bisa dipakai.

## v2.3.0

Rilis kedalaman game tanpa breaking change: simpanan dan cadangan lama
tetap terbaca, karena semua tambahan bersifat aditif.

### Ditambahkan
- Token beku streak: satu token menutup gap 2 hari, dan setiap streak
  7 hari dapat satu (maks 3 disimpan). Token tampil di Profil.
- XP ganda akhir pekan untuk semua perolehan XP, dengan tag 2x di
  mission sheet.
- 4 misi musiman yang hanya keluar di bulannya, plus 12 misi reguler
  dan quest chain Deep Work Arc yang baru.
- Generator v2: pilihan dibobot ke kategori yang paling jarang
  dimainkan, sehingga variasi tumbuh seiring main.

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
