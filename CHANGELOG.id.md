# Changelog

## v3.0.2

UI/UX dan optimasi setelah review v3.0.0–v3.0.1. Tidak ada perubahan
format penyimpanan, jadi semua cadangan tetap kompatibel.

### Ditingkatkan
- **Design system bersama.** `AppKit` di `lib/widgets/kit.dart`
  mengkonsolidasikan spasi, radius, kartu, tombol, dan kartu metrik
  yang sebelumnya dicopy-paste antar layar. Tidak ada lagi angka ajaib
  yang berserak.
- **Home lebih rapi.** Tombol utama "Misi Bosan" dan "Acak
  Sebebasnya" sekarang lebar penuh dengan warna yang membedakan.
  Toggle Quick Wins dan Mode Chaos berbentuk bar yang konsisten.
- **Mission Sheet lebih bersih.** Header tombol 4x, judul dan deskripsi
  di tengah, serta grid hasil yang terbaca di layar kecil dan teks besar.
- **Stats & Achievements pakai kartu metrik yang sama**, dan
  Achievements sekarang pakai `SliverGrid` yang lebih efisien daripada
  `GridView(shrinkWrap: true)`.
- **History lookup O(1).** Resolusi judul dan kategori riwayat
  sebelumnya memindai katalog (55 entri) per baris per build — sekarang
  pakai `Map` langsung.
- **Weekly Insights refresh saat hari berganti** melalui
  `context.watch` provider, bukan hanya saat ada penyelesaian baru.
- **Tidak ada spasi kosong mati** di bawah Home untuk pemain baru (spasi
  dipindah ke dalam WeeklyInsights).

### Diperbaiki
- **Toast "+0 XP" untuk misi yang dilewati** — sekarang bilang dengan
  jujur bahwa tidak ada XP dan streak tidak berubah.
- **Ketuk ganda pada quest chain membayar dua kali** — langkah sekarang
  diklaim sebelum proses async, dengan guard in-flight.
- **Timer tengah malam tidak lagi menumpuk** setiap kali aplikasi
  dibuka kembali (tidak ada lagi N timer hidup setelah N resume).
- **ID tantangan harian dari cadangan divalidasi** — ID yang tidak ada
  dalam katalog build ini dibuang alih-alih diam-diam menimpa arc lain.
- **Riwayat di memori sekarang ikut mematuhi batas 1000 entri** seperti
  penyimpanan, jadi laporan "menampilkan N dari M" tidak lagi melanggar.
- **Filter riwayat dipindah ke modul murni** (`history_filter.dart`)
  dengan 16 test — sebelumnya method privat di widget yang mustahil
  diuji.

### Optimasi
- **Analyze bersih, 0 warning/error.** Semua perbaikan tipe dan
  parameter dari review ulang v3.0.0 diterapkan.
- **174 test hijau** (termasuk 16 test baru history filter).

## v3.0.1

### Diperbaiki
- **Melaporkan misi sebagai "tidak dikerjakan" menghukum dua kali.**
  Kamu tidak dapat XP dan streak tidak bertambah, lalu pengundi
  memperlakukannya sebagai penyelesaian terbaru dan menyembunyikan misi
  itu selama tujuh hari. Menjawab jujur kini hanya harga yang hilang.
- **Misi yang dilewati memunculkan toast hijau "+0 XP"** lengkap dengan
  tombol undo, bertolak belakang dengan jawaban yang baru kamu pilih.
  Sekarang toast-nya terang-tiba mengatakan tidak ada yang diberikan,
  beserta alasannya.
- **Melewati misi buatan melaporkan XP dasarnya sebagai hasil**, persis
  kebalikan dari yang tercatat.
- **Penyelesaian sebagian bisa membayar bonus level hantu.** Batasnya
  dihitung dari nilai misi penuh padahal hanya 60 persen yang dibayar,
  jadi di akhir pekan misi bernilai tinggi bisa mengambil bonus level
  20 lalu tetap berhenti di bawah level 20. Batasnya kini dihitung dari
  jumlah yang benar-benar diberikan.
- **Ketuk dua kali "selesaikan langkah" di quest chain membayar dua
  kali.** Langkah baru ditandai selesai beberapa await kemudian, jadi
  ketukan kedua lolos dan menulis baris riwayat ganda. Langkah kini
  diklaim sebelum await apa pun, seperti menerima misi sejak dulu.
- **Setiap kali aplikasi dibuka kembali, timer tengah malam menumpuk.**
  Tiap resume memasang rantai baru tanpa membatalkan yang lama, jadi
  setelah N kali buka-tutup ada N timer aktif dan N penulisan tengah
  malam yang sia-sia.

### Ditingkatkan
- **Riwayat di memori sekarang mengikuti batas yang sama dengan
  penyimpanan.** Keduanya sebelumnya berbeda: penyimpanan memangkas
  sampai batas, memori tumbuh terus, sehingga layar Riwayat melaporkan
  total yang tidak benar-benar ada di perangkat dan angka hasil
  menurun setelah restart.
- **Insight diperbarui saat hari berganti**, tidak menampilkan
  perbandingan kemarin sampai ada penyelesaian berikutnya.
- **"Jam terbaik" kini mengabaikan upaya yang dilewati**, sama dengan
  semua angka lain di layar itu.
- **Label filter riwayat sudah type-check.** Sempat dicocokkan lewat
  `toString()` dengan cabang `default:`, jadi mengganti nama enum akan
  diam-diam mengganti semua label chip tanpa error build.
- **Sheet hasil misi buatan tidak lagi terpotong** di layar pendek atau
  ukuran teks besar.
- **Pemain baru tidak lagi mendapat ruang kosong** di Beranda.
- **Penyaringan riwayat dipindah ke modul murni yang bisa diuji.**
  Sempat jadi method privat di dalam widget, sehingga mustahil diuji.

## v3.0.0

Retensi dan kejujuran. Aplikasi sekarang memberi tahu apa yang
katakan riwayatmu tentangmu, dan berhenti menampilkan angka basi saat
hari berganti sementara kamu masih memegang HP.

### Ditambahkan
- **Insight mingguan di Beranda.** Pengamatan dari riwayatmu: apakah
  kamu mengerjakan lebih banyak atau lebih sedikit dari minggu lalu, jam
  saat kamu benar-benar menyelesaikan sesuatu, kategori yang paling sering
  kamu tinggalkan, dan rata-rata XP per misi minggu ini.
- **Insight menolak menebak.** Tidak ada kartu sama sekali di bawah lima
  penyelesaian, tidak ada "jam terbaik" kecuali puncaknya mencakup
  seperempat datamu, tidak ada persentase mingguan kalau tidak ada
  minggu sebelumnya untuk dibandingkan, dan tidak ada "pelarian" untuk
  satu-satunya kegagalan yang terisolasi. Semua kasus itu sebelumnya akan
  menghasilkan angka yang yakin padahal tidak berdasar.
- **Ulangi intro dari Profil.** Pemain lama bisa menonton ulang
  perkenalan tanpa ditandai belum pernah melihat, jadi menutup aplikasi
  di tengah pengulangan tidak mengembalikan gerbang startup.
- **Aksen bernama untuk pembaca layar.** Lima lingkaran warna
  sebelumnya lima tombol tanpa nama dan tanpa status aktif.

### Ditingkatkan
- **Beranda sekarang berganti hari sendiri.** Membiarkan aplikasi
  terbuka melewati tengah malam membuat peringatan streak, jatah
  reroll, dan tantangan harian kemarin tetap tampil sampai kamu
  memindahkan aplikasi lalu membukanya lagi.
- **Perhitungan insight adalah fungsi murni** atas daftar riwayat dengan
  jam yang di-inject, jadi bisa diuji tanpa provider, pohon widget, atau
  timer palsu.

### Diperbaiki
- **Quest chain yang sudah tidak ada di build ini tidak lagi diam-diam
  diganti dengan yang lain.** Id chain yang tidak dikenal dulu jatuh ke
  arc pertama, diam-diam mengubah "Arc Kreator" yang sedang kamu
  kerjakan jadi "Arc Keluar Rumah". Id yang tidak dikenal sekarang
  mengembalikan null, dan yang tersimpan dibuang saat impor.
- **Langkah chain dari arc yang hilang selesai dengan aman** tanpa
  membayar hadiah arc yang salah.

## v2.8.0

Data yang bisa dipercaya. Setiap angka yang ditampilkan aplikasi kini
menyatakan apa yang sebenarnya diukur, dan memulihkan cadangan tidak
lagi membuang sebagian pengaturanmu.

### Ditambahkan
- **Saring riwayat berdasarkan tanggal.** Hari ini, 7 hari, 30 hari,
  atau semua waktu.
- **Saring riwayat berdasarkan hasil.** Selesai, sebagian, dilewati,
  atau entri dari sebelum pelacakan hasil ada, yang diberi label "Tanpa
  nilai" alih-alih diam-diam dihitung sebagai keberhasilan.
- **Daftar riwayat menyebutkan angkanya sendiri**, menampilkan berapa
  banyak entri yang tersimpan dan berapa yang sedang kamu lihat, dan
  mengatakannya terus terang begitu batasnya tercapai.
- **Bersihkan favorit yang menunjuk misi yang hilang.** Sempat
  menghilang dari daftar tapi tetap tersimpan di data, tanpa cara melihat
  atau menghapusnya.

### Ditingkatkan
- **Cadangan sekarang ikut menyimpan pengaturan pengingat.** Memulihkan
  di HP baru dulu kembali dengan pengingat mati dan jam pilihanmu
  dibuang. Cadangan sebelum versi ini tidak punya bagian pengingat dan
  tetap membersihkan jadwal, supaya pemulihan versi lama tidak
  meninggalkan notifikasi yang tidak terlihat.
- **Jam pengingat dari cadangan dikunci** ke jam dan menit yang nyata,
  bukan dipercaya buta.
- **Riwayat menyimpan 1000 entri, bukan 200.** Batasnya jadi konstanta
  bernama, bukan angka yang tertanam di dua tempat.

### Diperbaiki
- **Tanggal riwayat sekarang menampilkan tahun** kalau bukan tahun
  berjalan, supaya penyelesaian tahun lalu tidak terbaca sebagai hari
  ini.
- **"Rata-rata XP / Hari" jadi "XP / Hari Aktif".** Pembaginya dari
  awal selalu hari kamu aktif, bukan hari kalender, jadi label lama
  menggambarkan angka yang memang tidak pernah dihitung aplikasi.

## v2.7.0

Pelacakan hasil misi. Sampai sekarang setiap penyelesaian terlihat
sama: aplikasi tidak bisa tahu apakah kamu benar-benar mengerjakan atau
cuma menekan tombol, jadi streak mengukur tekanan tombol, bukan
aktivitas. Format penyimpanan bersifat aditif, jadi riwayat lama tetap
terbaca.

### Ditambahkan
- **Bilang apakah kamu benar-benar mengerjakannya.** Sheet misi kini
  menampilkan "Selesai", "Dikerjakan sebagian", dan "Tidak dikerjakan"
  di sebelah tombol terima yang sudah ada. Satu baris tambahan, tanpa
  ketukan ekstra, dan tanpa dialog lanjutan yang bisa ditutup dan
  membuat penyelesaian hilang.
- **Misi yang dilewati menguras streak kamu.** Tetap ditulis ke
  riwayat supaya upanya terlihat, tapi tidak memberi XP dan tidak
  menambah streak. Berpura-pura hadir tidak lagi menjaga streak tetap
  hidup.
- **Poin parsial.** Misi yang dikerjakan sebagian membayar 60 persen XP
  dan tetap terhitung sebagai hari aktif.
- **Statistik tuntas** di tab Statistik, menampilkan porsi penyelesaian
  yang benar-benar kamu kerjakan. Tampilkan tanda hubung, bukan 0
  persen, sampai ada data, supaya ketiadaan data tidak terlihat seperti
  gagal.
- **Lencana hasil di Riwayat**, supaya kamu bisa sekilas melihat yang
  benar-benar selesai dan yang ditinggalkan.
- **Empat achievement baru**, termasuk satu untuk misi yang dilaporkan
  jujur tidak dikerjakan.
- **Misi buatan menanyakan hal yang sama** sebelum membayar.

### Ditingkatkan
- **Upaya yang dilewati dikeluarkan dari "misi selesai".** Grafik
  mingguan dan 30 hari, rata-rata hari aktif, hari tersibuk, dan
  ringkasan di Beranda semuanya hanya menghitung aktivitas nyata,
  supaya tetap konsisten dengan total di atasnya.
- **Baris yang disimpan sebelum fitur ini tetap terhitung sebagai
  aktivitas**, persis seperti sebelumnya, dan dikeluarkan dari angka
  tingkat tuntas alih-alih diam-diam dihitung sebagai keberhasilan.

## v2.6.0

Audit seluruh aplikasi: 20 temuan, sebagian besar membuat angka di
layar salah, bukan cuma tidak rapi. Format penyimpanan tidak berubah,
jadi semua simpanan dan cadangan lama tetap terbaca.

### Ditambahkan
- **Bahasa Indonesia sekarang lengkap.** Chip suasana, lokasi, dan
  energi, tombol utama "Misi Bosan" dan "Acak Sebebasnya", judul
  section Mood dan Mode Chaos, 10 label kategori, judul level, serta isi
  notifikasi pengingat semuanya diterjemahkan. Pengingat adalah kasus
  terburuk: satu-satunya tampilan yang sampai ke user setelah aplikasi
  ditutup, dan tidak ada cara mengubahnya ke Bahasa Indonesia.
- **Dialog dari sistem ikut bahasa aplikasi.** Time picker, date picker,
  dan toolbar pilihan teks terkunci ke Inggris, sehingga aplikasi
  Bahasa Indonesia menampilkan tombol Indonesia di sekeliling picker
  berbahasa Inggris.

### Ditingkatkan
- **Setiap penyelesaian sekarang terhitung sebagai satu hari.**
  Menyelesaikan tantangan harian atau quest chain memberi XP tapi tidak
  menulis riwayat, tidak menambah streak, dan tidak memperbarui
  statistik. Hari yang benar kamu habiskan terlihat kosong di grafik
  mingguan, angka rata-rata XP, statistik hari tersibuk, dan streak.
- **Bar progres achievement langsung diperbarui.** Layar itu hanya
  melacak 2 dari 8 metrik yang ditampilkan, jadi reroll atau simpan ke
  inbox mengubah angka tanpa mengubah nilai terpilih: perbandingan
  hasilnya sama, tidak ada rebuild, dan batarnya tetap beku sampai
  kebetulan kamu menyelesaikan misi.
- **Grafik 30 hari jadi terbaca.** Jarak tetap 8px antarbatang memakan
  sebagian besar kanvas di 30 batang, menyisakan lebar di bawah 2px,
  dan menjadi negatif di layar sempit. Jaraknya kini menyesuaikan
  jumlah batang.
- **Pencarian judul level tidak lagi bergantung pada urutan insert map.**

### Diperbaiki
- **Rincian statistik sekarang jumlahnya pas.** Misi chaos dibuang dari
  grafik kategori padahal Mode Chaos bisa memunculkannya dan sudah
  dihitung, sehingga batang tidak cocok dengan total "misi
  selesai" di atasnya.
- **Pulihkan cadangan tidak lagi meninggalkan tantangan harian
  kemarin** di penyimpanan kalau payload-nya tidak membawa satu pun.
- **Membuka dialog impor dua kali tidak lagi bisa menutup aplikasi.**
  Dialog ditutup lewat navigator layarnya sendiri, jadi pop kedua bisa
  mencabut route satu-satunya aplikasi.
- **Input misi buatan yang tidak valid kini menampilkan pesannya.**
  Dialog tetap terbuka di belakang pesan, jadi menekan Save terlihat
  seperti tidak terjadi apa-apa.
- **Reroll disimpan sebelum misi baru diundi**, jadi aplikasi yang
  langsung mati setelah reroll tidak mengembalikan jatah gratis.
- **Dislike menerbitkan koleksi baru** seperti favorit, supaya kedua
  toggle tidak berbeda cara.
- **Saat aplikasi dibuka tidak lagi berebut dengan pilihan bahasa atau
  tema**; keduanya dibaca ulang dari penyimpanan setiap rebuild.

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
