# Presensi Digital (Attendance App)

Aplikasi mobile Android untuk mencatat kehadiran pribadi menggunakan Flutter. Pengguna dapat mendaftar/masuk akun, melakukan presensi **Masuk** saat tiba dan **Pulang** saat selesai bekerja (keduanya wajib menyertakan foto selfie/kamera), serta melihat riwayat presensi miliknya sendiri.

Repositori ini merupakan repositori awal pembelajaran (versi lokal yang siap dihubungkan ke Firebase Firestore pada sesi berikutnya).

---

## Informasi Aplikasi

- **Nama Paket:** `attendance_app`
- **Nama Tampilan:** Presensi Digital
- **Android Application ID (`applicationId`):** `com.example.attendance_app`
- **Target Platform:** Android (Material 3)

---

## Cara Menjalankan

1. **Periksa kesiapan lingkungan:**
   ```bash
   flutter doctor
   ```

2. **Unduh dependensi proyek:**
   ```bash
   flutter pub get
   ```

3. **Periksa perangkat/emulator yang terhubung:**
   ```bash
   flutter devices
   ```

4. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```

---

## Konfigurasi Firebase

Repositori ini secara sengaja **tidak menyertakan kredensial Firebase**. Saat pertama kali dijalankan, aplikasi akan menampilkan layar **"Firebase belum dikonfigurasi"** (`ConfigErrorScreen`) yang memandu siswa untuk menghubungkan aplikasi ke Firebase project masing-masing.

Untuk menghubungkan ke Firebase:
1. Pastikan Firebase CLI terpasang dan login:
   ```bash
   firebase login
   ```
2. Pasang FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. Konfigurasikan project Firebase:
   ```bash
   flutterfire configure --project=ID_PROJECT_ANDA
   ```
   *(Perintah ini akan menimpa stub `lib/firebase_options.dart` dengan konfigurasi nyata).*
4. Jalankan ulang aplikasi (`flutter run`).

---

## Peta Struktur Folder

```
lib/
  main.dart                                # Titik masuk utama, inisialisasi Firebase & locale id_ID
  firebase_options.dart                    # Placeholder/stub awal (ditimpa oleh flutterfire configure)
  models/
    attendance_record.dart                 # Model immutable catatan presensi harian
    user_profile.dart                      # Model profil pengguna
  services/
    auth_services.dart                     # Pembungkus Firebase Authentication
    attendance_service.dart                # Layanan presensi (cache memori + SharedPreferences)
    firestore_service.dart                 # Adapter tipis ke AttendanceService
    storage_services.dart                  # Layanan kompresi & penyimpanan foto lokal (PhotoStorage)
    permission_service.dart                # Pengelola izin kamera
  wrapper/
    auth_wrapper.dart                      # Pengarah rute berdasarkan authStateChanges
  screens/
    config_error/
      config_error_screen.dart             # Layar panduan saat Firebase belum dikonfigurasi
    auth/
      login_screen.dart                    # Layar masuk akun
      register_screen.dart                 # Layar pendaftaran akun
      widgets/
        auth_text_field.dart               # Komponen input form autentikasi
    home/
      home_screen.dart                     # Layar beranda (status presensi harian)
      widgets/
        action_button.dart                 # Tombol aksi Masuk / Pulang
        attendance_card.dart               # Kartu status presensi harian
        camera_button.dart                 # Pengendali pengambilan foto kamera & izin
        logout_dialog.dart                 # Dialog konfirmasi keluar
        photo_viewer.dart                  # Penampil foto layar penuh (zoom)
        profile_card.dart                  # Kartu identitas akun aktif
    history/
      history_screen.dart                  # Layar riwayat presensi
      widgets/
        record_card.dart                   # Kartu entri riwayat presensi
test/
  models/
    attendance_record_test.dart            # Unit test model presensi & durasi kerja
    user_profile_test.dart                 # Unit test model profil pengguna
  widgets/
    logout_dialog_test.dart                # Widget test dialog konfirmasi keluar
```

---

## Penyimpanan Foto & Data Presensi

- **Penyimpanan Lokal:** Pada versi ini, foto dikompresi (JPEG kualitas 75) dan disimpan secara lokal pada folder internal aplikasi (`attendance_photos`). Data presensi disimpan di cache memori dan `SharedPreferences` dengan kunci `local_attendance_records_v1`.
- **Catatan Penting:** Karena foto tersimpan lokal di penyimpanan aplikasi, foto bukti presensi akan terhapus apabila data atau cache aplikasi dihapus (Clear Data/Uninstall). Penyimpanan cloud (Cloud Storage / Firestore) akan diimplementasikan pada modul lanjutan.

---

## Batasan (Di Luar Cakupan Proyek Ini)

Fitur-fitur berikut sengaja **tidak dibuat** pada fase ini dan menjadi latihan modul pengembangan berikutnya:
- Dashboard admin & rekapitulasi seluruh pengguna
- Pelacakan GPS / Geofencing lokasi
- Verifikasi pengenalan wajah (Face recognition)
- Sistem penggajian & shift kerja
- Pengajuan & persetujuan izin/cuti
- Form pengisian lokasi manual / catatan tambahan (`notes`)
- Profil pengguna di Firestore
- Sinkronisasi antrean offline ke cloud & push notification
- Mode gelap kustom & multi-bahasa
