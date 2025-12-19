# 🏥 Sistem Antrean Poliklinik – Mobile & Web

Sistem Antrean Poliklinik ini merupakan solusi digital yang dirancang untuk membantu proses pelayanan poliklinik agar lebih terstruktur, efisien, dan modern. Sistem ini mengintegrasikan aplikasi mobile dan website untuk mendukung proses registrasi pasien, pengelolaan antrean oleh petugas, hingga tampilan antrean publik.

---

## 🔰 Komponen Sistem
Sistem ini terdiri dari 3 komponen utama:

### 📱 1. Aplikasi Mobile Flutter
Digunakan oleh:
- **Pasien / Kios Mandiri**
- **Petugas Poli**

### 🌐 2. Website CRUD Poliklinik
Digunakan untuk mengelola data poliklinik dan antrean.

### 🖥️ 3. Website Display Antrean
Digunakan sebagai tampilan layar antrean di ruang tunggu.

---

# 📱 Aplikasi Mobile Flutter

## 👤 Role Pengguna & Fitur

### 👥 Pasien / Kios
- Login & Register
- Pendaftaran antrean berdasarkan poli
- Melihat profil
- Edit profil
- Ganti password
- Setting notifikasi
- Menghapus akun
- Melihat riwayat pemeriksaan
- Logout

---

### 🏥 Petugas Poli
- Login menggunakan akun petugas terdaftar
- Mengubah status antrean:
  - **Menunggu → Dilayani**
  - **Dilayani → Selesai**
- Melihat riwayat antrean selesai
- Melihat profil petugas
- Logout

---

## 🛠️ Teknologi Mobile
- Flutter
- Dart
- Terintegrasi dengan backend sistem antrean

---

## 🚀 Instalasi & Menjalankan Mobile App
```bash
1️⃣ Clone Reposity
git clone <url-repository-mobile>
cd <nama-folder-mobile>
2️⃣ Install Dependencies
flutter pub get
3️⃣ Jalankan Aplikasi
flutter run

Jika memilih device tertentu:

flutter devices
flutter run -d <device_id>
```

⚙️ Konfigurasi (Jika Diperlukan)
Jika aplikasi menggunakan:
Base URL API
Firebase
Environment variable
Pastikan dikonfigurasi pada file yang telah disediakan.

🌐 Website CRUD Poliklinik
Website ini digunakan admin/pengelola untuk:
Mengelola data poli
Mengelola antrean pasien
Menghubungkan proses pengelolaan dengan aplikasi mobile & display antrean

🛠️ Teknologi Web Poli
HTML
CSS
JavaScript
Backend sesuai implementasi sistem

🚀 Cara Menjalankan Web Poli
```bash
1️⃣ Clone Repository
git clone <url-repository-web>
2️⃣ Jalankan
Jika frontend saja:
Buka:
web_poli/index.html
Jika membutuhkan server:
Letakkan di:
htdocs (XAMPP) / www (Laragon/WAMP)
Jika tidak membutuhkan server bisa langngsung dijalankan dengan live server

Akses melalui:
http://localhost/web_poli
```

🖥️ Website Display Antrean
Digunakan sebagai tampilan publik untuk memantau antrean pasien di ruang tunggu.

📌 Fitur Display Antrean
Menampilkan nomor antrean aktif
Menampilkan status antrean
Informasi poli tujuan
Tampilan ramah layar besar (monitor/TV)

🚀 Cara Menjalankan Display Antrean
Jika frontend:
web_antrean/index.html

Jika membutuhkan server:
Letakkan pada server lokal dan akses via browser.
Jika tidak membutuhkan server bisa langngsung dijalankan dengan live server
