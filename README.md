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

## Fitur

- Mood / waktu / lokasi / energi selector
- Random mission generator dengan fallback pintar (kalau kombinasi filter kosong, filter dilonggarkan otomatis biar tetap dapat misi)
- Accept / Reroll dengan limit harian
- XP & level system dengan kurva progresif + judul level
- Streak harian + longest streak
- Riwayat misi yang sudah diselesaikan
- **Daily Challenge** — satu tantangan spesial per hari (sama untuk semua orang di tanggal yang sama), reward XP besar
- **Achievement system** — 21 achievement tersembunyi (progress-based & event-based seperti "Night Owl")
- **Quest Chains** — 3 rantai misi bertahap ("Touch Grass Arc", "Creator Arc", "Reset Arc"), reward besar di step terakhir
- **Statistics** — distribusi misi per kategori, total reroll, total misi Chaos Mode
- Chaos Mode — abaikan semua filter
- Semua data tersimpan lokal di HP (tidak ada server/API eksternal)

## Tech Stack

| Kategori | Package |
|---|---|
| State management | provider |
| Penyimpanan lokal | shared_preferences |
| Format tanggal | intl |

Nggak ada dependency ke API eksternal — seluruh katalog misi/achievement/challenge/chain ada di `lib/services/`, tinggal edit/tambah di situ.

## Build APK

Push ke branch `main` (atau jalankan workflow secara manual dari tab **Actions**) — GitHub Actions otomatis build APK release dan upload sebagai artifact, sama seperti workflow di project Swara.

## Struktur Project

```
lib/
  models/       # Mission, UserProgress, Achievement, DailyChallenge, QuestChain
  services/     # Katalog misi/achievement/challenge/chain + generator + local storage
  providers/    # BoredomProvider (state management)
  screens/      # Home, Missions, Stats, Achievements, Profile
  widgets/      # Selector chips, mission sheet, XP bar, daily challenge card, quest chain section, achievement badge
  utils/        # Tema warna
```

## Yang belum dibuat

Sound effect & animasi tambahan (polish murni, nggak mempengaruhi fungsi) — satu-satunya item di roadmap awal yang sengaja dilewatin karena butuh aset audio/animasi custom yang di luar scope kode.

---

<div align="center">
Dibuat oleh Nicolas Dwi Dharma
</div>
