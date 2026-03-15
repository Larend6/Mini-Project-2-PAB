<img width="1200" height="230" alt="Banner" src="https://github.com/user-attachments/assets/93fbda08-cac3-4725-a809-6e0fc5066bff" />

# TCG Collection App

## Deskripsi Aplikasi

TCG Collection App adalah aplikasi mobile berbasis Flutter untuk mengelola koleksi kartu Trading Card Game (TCG), khususnya kartu Pokémon.
Pengguna dapat masuk menggunakan akun, menyimpan data kartu (nama, series, rarity, harga, jumlah, gambar), lalu menampilkan koleksi dengan berbagai mode tampilan.
Aplikasi terintegrasi dengan Supabase untuk autentikasi pengguna dan penyimpanan data kartu, sehingga koleksi bisa tersimpan per akun dan tidak hilang saat aplikasi ditutup.

---

## Fitur Aplikasi

1. **Autentikasi Pengguna**
   - Register, login, dan logout
   - Auto-login jika session masih aktif
   - Ganti password dari halaman profil

2. **Tambah & Update Kartu**
   - Input nama kartu, series, rarity, harga, dan jumlah
   - Upload gambar kartu
   - Edit data kartu kapan saja

3. **Menampilkan Koleksi**
   - Daftar kartu dalam mode **list**, **grid**, dan **large**
   - Detail kartu lengkap (nama, series, rarity, harga, jumlah, ID kartu)

4. **Pencarian & Filter**
   - Pencarian kartu berdasarkan nama
   - Filter berdasarkan rarity

5. **Statistik Koleksi**
   - Total kartu
   - Total nilai koleksi
   - Rarity yang sedang difilter

6. **Profil Pengguna**
   - Edit nama pengguna
   - Upload foto profil
   - Lencana kolektor berdasarkan jumlah kartu

7. **Tema Aplikasi**
   - Mode terang dan gelap (toggle dari halaman profil)

---

## Widget yang Digunakan

Berikut adalah beberapa widget utama yang digunakan dalam aplikasi:

- `MaterialApp`
- `Scaffold`
- `AppBar`
- `BottomNavigationBar`
- `ListView`, `GridView`, `Wrap`
- `Card`, `ListTile`
- `TextField`, `TextFormField`
- `DropdownButtonFormField`
- `FutureBuilder`, `RefreshIndicator`
- `Image.network`, `CircleAvatar`
- `SwitchListTile`
- `SnackBar`, `AlertDialog`
- `Provider` (State Management)

---

## Teknologi yang Digunakan

- Flutter
- Dart
- Supabase (Auth & Database)
- Provider (State Management)

---

## Screenshot Aplikasi

## Halaman Login



## Halaman Register

### Halaman utama aplikasi

<img width="180" height="420" alt="image" src="https://github.com/user-attachments/assets/fa451522-d466-4f53-bb4a-622c9a1e499d" />

### Halaman Input

<img width="180" height="420" alt="image" src="https://github.com/user-attachments/assets/b58f6408-2767-446b-b970-804acb7e385a" />

## Halaman Detail Kartu

### Halaman Profil

<img width="180" height="420" alt="image" src="https://github.com/user-attachments/assets/526d6749-df7e-4e37-a1f9-99bab9e6e58a" />

## Halaman Ganti Password

