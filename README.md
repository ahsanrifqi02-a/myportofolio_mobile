# MyPortfolio Mobile

Aplikasi mobile berbasis **Flutter** untuk menampilkan dan mengelola portofolio pribadi sebagai bagian dari mata kuliah **Pemrograman Berbasis Platform (CSGE602022)**, Fakultas Ilmu Komputer Universitas Indonesia.

| Atribut | Informasi |
| :--- | :--- |
| **Nama** | Ahsan Rifqi Prasetyo |
| **NPM** | 2506624266 |
| **Kelas** | PBP F |

---

## Cara Menjalankan Proyek

1. Pastikan Flutter SDK sudah terpasang (`flutter doctor`).
2. Clone repositori dan masuk ke folder proyek:
   ```bash
   git clone https://github.com/ahsanrifqi02-a/myportofolio_mobile.git
   cd myportofolio_mobile
   ```
3. Pasang dependensi:
   ```bash
   flutter pub get
   ```
4. Jalankan analisis kode dan *widget test*:
   ```bash
   flutter analyze
   flutter test
   ```
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

---

### Tugas 7

1. **Apa yang dimaksud dengan *widget tree* pada Flutter dan bagaimana hubungan induk-anak (*parent-child*) bekerja?**

   ***Widget tree*** adalah struktur hierarki berbentuk pohon yang menyusun seluruh elemen antarmuka (UI) pada Flutter, dari *root widget* hingga komponen terkecil seperti teks dan ikon.

   Cara kerja hubungan **parent-child**:
   - **Parent → Child:** *Parent* meneruskan batasan ukuran (*constraints*), tema, dan konteks tata letak ke *child*.
   - **Child → Parent:** *Child* menentukan ukurannya sendiri sesuai *constraints* dari *parent*, lalu *parent* mengatur posisi *child* di layar.
   - **Akses Konteks:** *Child* dapat mengambil data dari *ancestor* (seperti `Theme` atau `MediaQuery`) melalui `BuildContext`.

2. **Daftar seluruh *widget* yang digunakan dalam proyek ini dan fungsinya:**

   **A. Custom Widgets**

   | Widget | Berkas | Fungsi |
   | :--- | :--- | :--- |
   | `MyApp` | `lib/main.dart` | *Root widget* yang membungkus aplikasi dengan `MaterialApp` dan tema. |
   | `MyHomePage` | `lib/menu.dart` | Halaman utama yang menampilkan `InfoCard` dan grid `ItemCard`. |
   | `InfoCard` | `lib/menu.dart` | Kartu informasi profil pemilik portofolio (`NPM`, `Name`, `Class`). |
   | `ItemCard` | `lib/menu.dart` | Kartu tombol aksi interaktif berwarna unik yang memicu `SnackBar`. |

   **B. Built-in Flutter Widgets**

   | Widget | Fungsi |
   | :--- | :--- |
   | `MaterialApp` | Konfigurasi dasar Material Design (tema, judul, halaman awal, *navigator*). |
   | `Scaffold` | Kerangka struktur halaman (`appBar`, `body`, dan dukungan `SnackBar`). |
   | `AppBar` | Bilah judul di bagian atas halaman (`MyPortfolio`). |
   | `SingleChildScrollView` | Membuat `body` dapat digulir vertikal agar tidak terjadi *overflow*. |
   | `Padding` | Memberikan jarak ruang (*inset*) di sekeliling *widget*. |
   | `Column` | Menyusun *children* secara vertikal. |
   | `Row` | Menyusun 3 `InfoCard` secara horizontal. |
   | `SizedBox` | Memberikan jarak kosong tetap antar-elemen. |
   | `Center` | Memusatkan *child widget* di tengah ruang yang tersedia. |
   | `Text` | Menampilkan teks pada judul, pesan sambutan, kartu, dan `SnackBar`. |
   | `GridView.count` | Menyusun 7 tombol `ItemCard` dalam tata letak kisi 3 kolom. |
   | `Card` | Wadah kartu dengan bayangan (*elevation*) untuk `InfoCard`. |
   | `Container` | Mengatur ukuran lebar proporsional (`MediaQuery`) dan `padding`. |
   | `Material` | Memberikan permukaan Material (warna `item.color` dan `borderRadius`) untuk `InkWell`. |
   | `InkWell` | Menangani sentuhan (`onTap`) beserta efek *ripple*. |
   | `Icon` | Menampilkan ikon Material pada setiap `ItemCard`. |
   | `SnackBar` | Menampilkan pesan umpan balik sementara melalui `ScaffoldMessenger` saat tombol ditekan. |

3. **Fungsi `MaterialApp` dan alasan penggunaannya sebagai *root widget*:**

   `MaterialApp` menyediakan fondasi aplikasi Material Design, mulai dari `theme` (`ThemeData`/`ColorScheme`), `title`, halaman awal (`home`), sistem *routing* (`Navigator`), hingga layanan UI seperti `ScaffoldMessenger` dan `Overlay`.

   `MaterialApp` dijadikan *root widget* karena hampir seluruh *widget* Material (`Scaffold`, `AppBar`, `InkWell`, `SnackBar`) bergantung pada konteks tema, navigasi, dan `MediaQuery` yang disediakan dari puncak *widget tree*.

4. **Perbedaan `StatelessWidget` vs `StatefulWidget` dan kapan memilihnya:**

   | Aspek | `StatelessWidget` | `StatefulWidget` |
   | :--- | :--- | :--- |
   | **Sifat Data** | *Immutable* (tidak punya *state* internal yang berubah). | *Mutable* melalui objek `State` terpisah. |
   | **Rebuild UI** | Hanya jika *parent* membangun ulang dengan parameter baru. | Dapat dipicu kapan saja dengan memanggil `setState()`. |
   | **Kapan Dipakai** | UI statis atau hanya meneruskan data/aksi (mis. `MyHomePage`, `InfoCard`, `ItemCard`). | UI dinamis yang berubah oleh input pengguna, animasi, atau data API (mis. *form*, *counter*). |

5. **Apa itu `BuildContext`, mengapa penting, dan penggunaannya di metode `build`:**

   `BuildContext` adalah referensi (*handle*) yang menunjukkan lokasi sebuah *widget* di dalam *widget tree*. Keberadaannya penting agar *widget* dapat berkomunikasi dan mengambil data dari *ancestor* di atasnya tanpa harus mengoper parameter secara manual di setiap level.

   Contoh penggunaan di metode `build` pada proyek ini:
   - `Theme.of(context).colorScheme.primary` → mengambil warna tema utama pada `MyHomePage`.
   - `MediaQuery.of(context).size.width` → menghitung lebar layar agar `InfoCard` proporsional.
   - `ScaffoldMessenger.of(context)` → mencari `ScaffoldMessenger` terdekat untuk menampilkan `SnackBar`.

6. **Konsep *hot reload* vs *hot restart* (dan *full restart*), serta batasannya:**

   | Mekanisme | Cara Kerja | Kondisi *State* | Kapan Digunakan |
   | :--- | :--- | :--- | :--- |
   | **Hot Reload** | Menyuntikkan perubahan kode Dart ke Dart VM dan me-*rebuild* UI dalam hitungan detik. | **Dipertahankan** | Perubahan UI, teks, warna, tata letak, atau logika di dalam `build()`. |
   | **Hot Restart** | Mengompilasi ulang kode Dart dan menjalankan ulang aplikasi dari `main()`. | **Direset** | Mengubah `initState()`, variabel global/statis, `main()`, atau mengubah `StatelessWidget` ↔ `StatefulWidget`. |
   | **Full Restart** | Menghentikan aplikasi lalu membangun ulang *native code* dan *engine* Flutter. | **Direset total** | Menambah/mengubah dependensi `pubspec.yaml`, aset (gambar/font), atau konfigurasi *native* Android/iOS. |

---

## AI Disclosure

- **Tools:** Antigravity (asisten AI berbasis LLM di IDE).
- **Strategi *Prompting*:** Meminta asisten membaca proyek Tutorial 08 terlebih dahulu, menyusun rencana implementasi bertahap untuk 7 tombol aksi (*Proyek*, *Education*, *Skills*, *Logout*), lalu menerapkan perubahan per langkah agar selaras dengan *Conventional Commits*.
- **Bagian yang Dibantu AI:**
  - Penambahan properti `color` pada `ItemHomepage` dan penyusunan 7 tombol di `lib/menu.dart`.
  - Penambahan `SingleChildScrollView` untuk mencegah *overflow* dan pembaruan `test/widget_test.dart`.
  - Penyusunan draf penjelasan konsep Flutter pada `README.md`.
- **Evaluasi & Perbaikan Manual:** Meninjau langsung pilihan ikon dan kontras warna tombol, memverifikasi identitas profil (`NPM`, `Name`, `Class`), memastikan `flutter analyze` (`No issues found!`) dan `flutter test` lulus, serta menyusun dan melakukan *commit* `README.md` secara mandiri sebelum `git push`.