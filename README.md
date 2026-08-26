<div align="center">

# 🎲 Boredom

Game kecil buat kehidupan sehari-hari. Klik satu tombol, dapet satu misi nyata, dapet XP, naik level.

[![Flutter](https://img.shields.io/badge/Flutter-3.35-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)]()

</div>

---

## Konsep

Boredom bukan aplikasi produktivitas. Ini game kecil buat kehidupan sehari-hari:

1. Pilih **mood**, **waktu luang**, **lokasi**, dan **energi** kamu sekarang.
2. Klik **🎲 I'M BORED**.
3. Dapet satu misi nyata yang bisa langsung dikerjain (bukan saran generik).
4. **ACCEPT** buat dapat XP, atau **REROLL** (maks 3x/hari) kalau nggak cocok.
5. XP naikin level. Level punya nama absurd, dari "Bored" sampai "The Final Boss of Boredom".

Ada juga **☢️ Chaos Mode** — matiin semua filter, misi apapun bisa keluar.

## Fitur (Phase 1 - MVP)

- Mood / waktu / lokasi / energi selector
- Random mission generator dengan fallback pintar (kalau kombinasi filter kosong, filter dilonggarkan otomatis biar tetap dapat misi)
- Accept / Reroll dengan limit harian
- XP & level system dengan kurva progresif + judul level
- Streak harian
- Riwayat misi yang sudah diselesaikan
- Chaos Mode
- Semua data tersimpan lokal di HP (tidak ada server/API eksternal)

## Roadmap (Phase 2+)

- Daily Challenge dengan reward khusus
- Achievement tersembunyi
- Quest Chains (rantai misi bertahap)
- Statistik & grafik per kategori misi
- Sound effect & animasi tambahan

## Tech Stack

| Kategori | Package |
|---|---|
| State management | provider |
| Penyimpanan lokal | shared_preferences |
| Format tanggal | intl |

Nggak ada dependency ke API eksternal — seluruh katalog misi ada di `lib/services/mission_catalog.dart`, tinggal edit/tambah di situ.

## Build APK

Push ke branch `main` (atau jalankan workflow secara manual dari tab **Actions**) — GitHub Actions otomatis build APK release dan upload sebagai artifact, sama seperti workflow di project Swara.

## Struktur Project

```
lib/
  models/       # Mission, UserProgress, CompletedMission
  services/     # Mission catalog, generator, local storage
  providers/    # BoredomProvider (state management)
  screens/      # Home, History, Profile
  widgets/      # Selector chips, mission sheet, XP bar
  utils/        # Tema warna
```

---

<div align="center">
Dibuat oleh Nicolas Dwi Dharma
</div>
