<div align="center">

# 🎲 Boredom: Ubah Rasa Bosan Jadi Misi

**Tekan satu tombol, dapat satu misi nyata, kumpulkan XP, naik level. Game kecil untuk kehidupan sehari-hari, sepenuhnya offline.**

![Flutter](https://img.shields.io/badge/Flutter-3.35-02569B?style=flat-square&logo=flutter&logoColor=white)
![Release](https://img.shields.io/github/v/release/nekonaru/boredom?style=flat-square&color=blue)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)
![CI](https://github.com/nekonaru/boredom/actions/workflows/build-apk.yml/badge.svg)

</div>

[English](README.md) | **Bahasa Indonesia**

## ✨ Tentang

**Boredom** adalah game kecil Flutter untuk kehidupan sehari-hari, bukan aplikasi produktivitas. Pilih **mood**, **waktu luang**, **lokasi**, dan **energi** kamu, tekan **I'M BORED**, dan dapatkan satu misi konkret yang bisa langsung dikerjakan (bukan saran generik). **Terima** misi untuk dapat XP, atau **reroll** (3x sehari) kalau tidak cocok. XP menaikkan level lewat judul absurd, dari "Bored" sampai "The Final Boss of Boredom".

Ada juga **Chaos Mode** yang mengabaikan semua filter, jadi misi apa pun bisa keluar.

> _"Kamu bosan. Jadi... mau ngapain?"_

## 🎯 Fitur

| Fitur | Deskripsi |
|---------|-------------|
| 🎲 **Generator misi** | Misi acak dari 55 katalog, disesuaikan dengan mood, waktu, lokasi, dan energi, dibobot ke kategori yang paling jarang dimainkan, plus misi musiman dan fallback pintar supaya selalu dapat misi |
| ☢️ **Chaos Mode** | Mengabaikan semua filter, membuka misi khusus chaos |
| ✅ **Terima / reroll** | Terima misi untuk XP, reroll sampai 3x sehari |
| ⭐ **XP dan level** | Kurva progresif dengan judul level yang absurd, XP ganda setiap akhir pekan |
| 🔥 **Streak** | Streak harian plus streak terpanjang, dengan toleransi 1 hari libur, token beku, dan peringatan saat terancam putus |
| 📜 **Quest chain** | 4 arc bertahap ("Touch Grass Arc", "Creator Arc", "Reset Arc", "Deep Work Arc") dengan hadiah besar di akhir |
| 🏆 **Pencapaian** | 25 pencapaian, berbasis progres dan event (seperti "Night Owl") |
| 📅 **Tantangan harian** | Satu tantangan spesial per hari, sama untuk semua orang di tanggal yang sama, hadiah XP besar |
| ⭐ **Misi buatanmu** | Buat misi sendiri dengan hadiah XP pilihanmu |
| ❤️ **Favorit** | Tandai misi katalog agar mudah ditemukan lagi |
| 🔍 **Pencarian riwayat** | Saring misi yang selesai berdasarkan judul atau kategori |
| ↩️ **Urungkan** | Jendela 5 menit untuk mengembalikan misi terakhir yang diselesaikan |
| 💾 **Cadangan dan pulihkan** | Ekspor semua data lokal sebagai teks, impor kembali untuk pulihkan (pindah HP jadi mudah, tanpa akun) |
| 📊 **Statistik** | Grafik 7 dan 30 hari terakhir tanpa dependency, rata-rata XP per hari aktif, hari tersibuk, distribusi per kategori, total reroll dan chaos |
| 👎 **Dislike** | Downvote misi supaya generator berhenti mengeluarkannya |
| 🔔 **Pengingat harian** | Satu notifikasi sehari pada waktu pilihanmu, mati secara default |
| 🌍 **UI Inggris dan Indonesia** | Inggris sebagai default, ganti ke Bahasa Indonesia di Profil |
| 🎨 **Tema terang dan gelap** | Gelap sebagai default, mode terang plus 5 warna aksen di Profil |
| 📳 **Haptic feedback** | Getaran kecil saat ketuk dan selesai, bisa dimatikan |
| 📤 **Share card** | Render misi apa pun jadi kartu PNG 1080x1080, atau salin sebagai teks |
| 📥 **Kotak masuk** | Simpan misi untuk nanti dan mulai kerjakan saat siap |
| ⚡ **Misi kilat** | Batasi roll ke misi 15 menit atau kurang |
| 🙈 **Matikan kategori** | Bisukan satu kategori penuh saat kamu tidak tertarik |
| 📊 **Ringkasan mingguan** | Jumlah misi, XP, dan streak langsung di Beranda |
| 🎁 **Bonus milestone** | XP ekstra setiap melewati kelipatan 10 level |
| ↩️ **Urungkan penuh** | Urungkan 5 menit untuk misi, tantangan harian, langkah chain, dan misi buatanmu |

## 📦 Kebutuhan

- **Flutter** 3.47 atau lebih baru (stable channel)
- **JDK** 17
- **Android SDK** (API 34+)
- HP atau emulator Android (minimum Android 8.0 / API 26)

### Belum pernah pakai terminal? Mulai di sini

<details>
<summary><b>Cara membuka terminal di Windows</b></summary>

1. Tekan tombol **Windows**, ketik `PowerShell`, lalu tekan **Enter**
2. Jendela biru akan terbuka. Di situlah perintah diketik
3. Setiap perintah `flutter ...` atau `git ...` di panduan ini diketik di jendela itu, diikuti **Enter**

</details>

## 🚀 Instalasi

### Opsi A: Unduh APK (paling mudah)

1. Buka halaman [Releases](https://github.com/nekonaru/boredom/releases)
2. Unduh APK yang cocok dengan HP (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama)
3. Buka di HP, izinkan instalasi dari sumber tidak dikenal jika diminta

### Opsi B: Build dari source (untuk development / membaca atau mengubah kode)

**1. Ambil kode project**

<details>
<summary><b>Saya sudah punya Git</b></summary>

```bash
git clone https://github.com/nekonaru/boredom.git
cd boredom
```

</details>

<details>
<summary><b>Saya belum punya Git</b></summary>

1. Buka halaman repo di GitHub
2. Klik tombol hijau **`Code`**, pilih **`Download ZIP`**
3. Ekstrak ZIP ke folder pilihanmu
4. Di terminal, masuk ke folder hasil ekstrak, contoh:

```bash
cd Downloads/boredom-main
```

</details>

**2. Instal dependency dan verifikasi**

```bash
flutter pub get
flutter analyze
flutter test
```

`flutter analyze` harus melaporkan **No issues found** dan semua test harus lolos.

**3. Build APK**

```bash
flutter build apk --release --split-per-abi
```

Hasilnya ada di `build/app/outputs/flutter-apk/` (`app-arm64-v8a-release.apk` dan kawan-kawan).

## 🖥️ Cara Pakai

**Pertama kali buka:**
1. Pilih mood, waktu luang, lokasi, dan energi
2. Tekan **I'M BORED**
3. Terima misinya dan kerjakan, atau reroll (3x sehari)

**Pemakaian sehari-hari:**
- Buka **Misi** untuk quest chain, misi buatanmu, favorit, dan riwayat yang bisa dicari
- Cek **Tantangan Harian** di Beranda untuk bonus XP
- Pantau **Statistik** untuk grafik mingguan dan rincian kategori
- Ganti bahasa atau cadangkan data dari **Profil**

## 🌍 Bahasa Tampilan

UI aplikasi (menu, tombol, pesan, dan pengaturan) tersedia dalam **English** (default) dan **Bahasa Indonesia**.

1. Buka **Profil**
2. Di bagian **Bahasa**, pilih **English** atau **Bahasa Indonesia**
3. Pilihan diingat antar sesi

## 🗂️ Struktur Project

```
boredom/
├── lib/
│   ├── main.dart                 # entry point, provider, MaterialApp + locale
│   ├── l10n/
│   │   └── app_strings.dart      # tabel Inggris (acuan) + Indonesia
│   ├── models/                   # Mission, UserProgress, Achievement, DailyChallenge,
│   │                             # QuestChain, CustomMission
│   ├── providers/                # BoredomProvider (state game), LanguageProvider
│   │                             # ThemeProvider (gelap/terang, aksen)
│   ├── screens/                  # Beranda, Misi, Statistik, Pencapaian, Profil, shell
│   │                             # onboarding (tur perkenalan pertama buka)
│   ├── services/                 # katalog, generator, penyimpanan lokal,
│   │                             # pengingat, share card
│   ├── utils/                    # tema, format tanggal yang ringan
│   └── widgets/                  # chip selector, mission sheet, XP bar, grafik,
│                                 # ringkasan mingguan, inbox, ...
├── test/
│   ├── widget_test.dart          # app menyala tanpa crash
│   ├── user_progress_test.dart   # kurva level
│   ├── mission_service_test.dart # fallback generator, filter, pengecualian
│   └── localization_test.dart    # cakupan string, kewarasan katalog
│   ├── stats_theme_test.dart     # statistik bulanan, palet, nama hari
│   ├── events_test.dart          # XP akhir pekan, roll musiman, bobot
│   └── v24_test.dart             # kategori dimatikan, XP milestone, ringkasan
│   └── onboarding_test.dart      # flag onboarding tersimpan
├── android_res_extra/            # icon launcher + splash yang dipasang CI ke APK
├── .github/
│   └── workflows/
│       ├── build-apk.yml         # CI: analyze + build APK tiap push ke main/master
│       └── release.yml           # rilis: test + APK per-ABI di setiap tag v*
├── pubspec.yaml
├── CHANGELOG.md                  # changelog (English)
├── CHANGELOG.id.md               # changelog (Bahasa Indonesia)
├── LICENSE
├── README.md                     # dokumentasi utama (English)
└── README.id.md                  # dokumentasi (Bahasa Indonesia)
```

**Menambah string baru yang tampil ke user:**
1. Tambah pasangan EN/ID di `lib/l10n/app_strings.dart` (Inggris dulu)
2. Kalau konten katalog (misi, pencapaian, tantangan, langkah chain), tambah field `titleId`/`descriptionId` di sebelah field Inggrisnya
3. Pakai lewat `context.str.kuncimu` atau `localizedTitle(en: ..., id: ..., code: ...)`
4. Tidak perlu langkah codegen (`flutter gen-l10n` sengaja tidak dipakai, supaya build tetap ringan)

## 🧪 Testing

Test unit dan widget mencakup kurva level, generator misi, dan lokalisasi:

```bash
flutter test
```

Verifikasi statis sebelum setiap push:

```bash
flutter analyze
```

Harus melaporkan **No issues found** (nol error, nol warning).

## ❓ FAQ

<details>
<summary><b>Apakah dataku dikirim ke mana-mana?</b></summary>

Tidak. Semua (XP, level, streak, riwayat, pencapaian, misi buatan, favorit) tersimpan lokal dengan SharedPreferences. Backup bekerja dengan menyalin teks, bukan mengunggah.

</details>

<details>
<summary><b>Ganti HP. Bagaimana cara memindahkan progres?</b></summary>

Buka **Profil**, ketuk **Ekspor data**, simpan teks yang disalin di tempat aman. Di HP baru, buka **Profil**, ketuk **Impor data**, tempel teksnya.

</details>

<details>
<summary><b>Misi yang keluar itu-itu saja?</b></summary>

Roll melewati misi yang diselesaikan 7 hari terakhir selama masih ada alternatif. Kalau semuanya baru saja diselesaikan, generator fallback dengan anggun alih-alih menampilkan kosong.

</details>

<details>
<summary><b>Bagaimana cara ganti bahasa?</b></summary>

Profil, bagian **Bahasa**, pilih English atau Bahasa Indonesia. English adalah default.

</details>

## 👤 Author

<div align="center">

| [![Nicolas Dwi Dharma](https://github.com/github.png?size=100)](https://github.com/nekonaru) |
|:---:|
| **Nicolas Dwi Dharma** |
| [github.com/nekonaru](https://github.com/nekonaru) |

</div>

## 📄 License

Didistribusikan di bawah **MIT License**. Lihat [`LICENSE`](LICENSE) untuk info lebih lanjut.

<div align="center">

Dibuat oleh **Nicolas Dwi Dharma**

*Star repo ini kalau project ini membantumu!*

</div>
