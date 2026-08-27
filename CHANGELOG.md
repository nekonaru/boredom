# Changelog

## v1.1.0

Audit menyeluruh terhadap codebase (models, providers, services, screens, widgets). Hasilnya: arsitektur sudah solid, cuma satu bug fungsional nyata + beberapa titik polish.

### Fixed
- **Bug: XP bar nampilin angka negatif buat user baru.** Kurva level (`UserProgress.xpNeededForLevel`) punya off-by-one: level 1 dianggap butuh 50 XP buat "dicapai", padahal user baru langsung start di level 1 dengan 0 XP. Akibatnya, sebelum total XP tembus 50 (yaitu sebelum menyelesaikan misi pertama — XP misi terkecil di katalog cuma 15), XP bar nampilin angka seperti `-50/100 XP`. Ini kelihatan di layar pertama yang dibuka semua user baru. Sudah diperbaiki dengan menggeser basis kurva biar level 1 mulai dari 0 XP.
- Tombol **REROLL** sekarang benar-benar ter-disable (bukan cuma nongolin snackbar) begitu jatah reroll harian habis.
- `flutter_lints` sudah ada di `pubspec.yaml` sejak awal tapi belum pernah aktif karena nggak ada `analysis_options.yaml`. Sudah ditambahkan.

### Improved
- Achievement yang sudah unlock sekarang tampil duluan di grid Achievements (diurut dari yang paling baru di-unlock).
- Riwayat misi di tab Missions sekarang pakai `ListView.builder` (lazy-build), bukan `ListView` biasa — lebih ringan kalau riwayat sudah ratusan entri.
- Haptic feedback ringan pas ACCEPT & COMPLETE misi dan pas reroll.
- Footer versi app + link repo di tab Profile.

### Added
- `LICENSE` (MIT).
- `analysis_options.yaml`.
- Roadmap lanjutan di README.

Nggak ada perubahan pada model data / format penyimpanan lokal — progress yang udah ada di HP tetap kebaca normal setelah update.
