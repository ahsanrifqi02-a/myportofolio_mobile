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
   Untuk menguji pada browser Chrome:
   ```bash
   flutter run -d chrome
   ```

---

## Progres Mingguan

| Minggu | Tonggak Pencapaian | Ringkasan Fitur |
| :--- | :--- | :--- |
| **Tutorial 08 & Tugas 7** | Dasar Flutter & Tata Letak | Inisialisasi proyek Flutter, `MyHomePage`, 3 `InfoCard` identitas pemilik portofolio, serta 7 `ItemCard` berwarna unik dengan umpan balik `SnackBar`. |
| **Tutorial 09** | Navigasi, Drawer, & Form Proyek | Pemisahan struktur ke `lib/screens/` dan `lib/widgets/`, pembuatan `LeftDrawer` (`Home`, `Add Project`), serta `ProjectFormPage` lengkap dengan validasi dan `AlertDialog`. |
| **Tugas 8** | Form Experience, Date Picker, & Validasi Modular | Pembuatan `ExperienceFormPage` (`lib/screens/experience_form.dart`), pemisahan validator ke `lib/utils/experience_validators.dart`, penambahan kartu `Tambah Experience` dan opsi `Add Experience` di `LeftDrawer`, penyelarasan tema global, perbaikan *overflow* layar ponsel, serta *unit* & *widget tests*. |

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

### Tugas 8

1. **Perbedaan `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`, metode untuk membuka formulir dari kartu aksi, serta alur opsi *Home* di *drawer*:**

   | Metode | Efek pada *Navigation Stack* | Pengaruh pada Tombol Kembali (*Back*) | Penggunaan pada Proyek |
   | :--- | :--- | :--- | :--- |
   | `Navigator.push()` | Menambahkan (*push*) *route* halaman baru ke puncak *stack* tanpa menghapus halaman sebelumnya. | Pengguna dapat menekan tombol *back* bawaan perangkat/browser untuk kembali ke halaman sebelumnya. | Membuka `ProjectFormPage` dan `ExperienceFormPage` dari `ItemCard` (`Tambah Proyek`, `Tambah Experience`) di `lib/widgets/project_card.dart`. |
   | `Navigator.pushReplacement()` | Mengganti (*replace*) *route* teratas saat ini dengan *route* baru sehingga halaman lama dihapus dari *stack*. | Halaman sebelumnya tidak lagi berada di bawah halaman baru pada *stack*, mencegah penumpukan *stack* tak terbatas saat berpindah menu. | Perpindahan menu utama di `LeftDrawer` (`Home`, `Add Project`, `Add Experience`) pada `lib/widgets/left_drawer.dart`. |
   | `Navigator.pop()` | Menghapus (*pop*) *route* teratas dari *stack* dan mengembalikan pengguna ke *route* tepat di bawahnya. | Sama seperti aksi tombol kembali; juga dipakai untuk menutup *overlay* seperti `AlertDialog`. | Menutup `AlertDialog` ringkasan isian saat tombol `OK` ditekan pada `ExperienceFormPage` dan `ProjectFormPage`. |

   - **Metode dari kartu aksi:** Kartu `Tambah Experience` pada `MyHomePage` menggunakan **`Navigator.push()`** agar `ExperienceFormPage` ditumpuk di atas `MyHomePage`, sehingga pengguna dapat kembali ke halaman utama memakai tombol *back* bawaan perangkat.
   - **Cara kerja opsi *Home* di *drawer*:** Ketika pengguna mengetuk `Home` di `LeftDrawer`, aplikasi memanggil `Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()))`. Rute formulir aktif digantikan langsung oleh `MyHomePage`, sehingga pengguna kembali ke halaman utama dengan bersih tanpa menumpuk riwayat navigasi (sangat berguna saat menguji alur kembali di Chrome).

2. **Peran susunan `Scaffold`, `AppBar`, dan `Drawer` dalam menjaga konsistensi halaman, serta contoh penggunaan warna tema portofolio di lebih dari satu halaman:**

   - **`Scaffold`** menyediakan kerangka tata letak standar Material Design (`appBar`, `drawer`, `body`, dukungan `SnackBar`) pada setiap halaman sehingga posisi bilah judul, ikon menu *drawer*, dan area konten selalu konsisten.
   - **`AppBar`** menjaga identitas visual bagian atas halaman (judul halaman, warna latar, serta tombol hamburger *drawer* atau tombol kembali) tetap seragam.
   - **`Drawer` (`const LeftDrawer()`)** digunakan ulang sebagai komponen tunggal yang sama pada `MyHomePage`, `ProjectFormPage`, dan `ExperienceFormPage`. Dengan demikian, setiap perubahan menu navigasi langsung tercermin seragam di seluruh halaman tanpa duplikasi kode.
   - **Contoh penggunaan warna tema portofolio di lebih dari satu halaman:** Warna primer `Theme.of(context).colorScheme.primary` (yang dikonfigurasi terpusat melalui `ColorScheme.fromSeed(seedColor: Colors.indigo)` di `lib/main.dart`) digunakan secara konsisten pada:
     - `backgroundColor` dari `AppBar` di `MyHomePage` (`lib/screens/menu.dart`),
     - `BoxDecoration(color: primaryColor)` pada `DrawerHeader` di `LeftDrawer` (`lib/widgets/left_drawer.dart`), serta
     - `AppBar` dan tombol `Simpan` / `Save` pada `ExperienceFormPage` (`lib/screens/experience_form.dart`) dan `ProjectFormPage` (`lib/screens/project_form.dart`).

3. **Alasan pemilihan tata letak formulir serta peran *widget* pengatur jarak dan penggulir ketika ruang layar terbatas:**

   - **Mengapa tata letak ini dipilih:** Formulir `ExperienceFormPage` disusun secara vertikal (`Column` dengan `crossAxisAlignment: CrossAxisAlignment.stretch`) di dalam `SafeArea` dan `SingleChildScrollView`. Pola satu kolom vertikal memudahkan pengguna memindai alur input dari atas ke bawah (Judul → Kategori → Deskripsi → Tanggal Mulai → Toggle *Ongoing* → Tanggal Selesai → Tombol Aksi) dan otomatis beradaptasi pada berbagai lebar layar tanpa memotong label atau tombol.
   - **Peran *widget* pengatur jarak (`Padding`, `SizedBox`):** `Padding(padding: EdgeInsets.all(16.0))` memberi ruang napas di tepi layar agar input tidak menempel ke pinggir perangkat, sementara `SizedBox(height: ...)` dan `SizedBox(width: 12.0)` memisahkan antar-kolom input serta tombol `Reset` dan `Simpan` sehingga setiap elemen tetap nyaman dibaca dan memiliki area sentuh (*tap target*) yang jelas.
   - **Peran *widget* penggulir (`SingleChildScrollView`):** Saat aplikasi dibuka pada layar sempit (seperti ponsel 390px) atau ketika papan ketik virtual (*soft keyboard*) muncul dan mengambil separuh tinggi layar, `SingleChildScrollView` memungkinkan seluruh konten formulir digulir vertikal sehingga tidak terjadi *RenderFlex overflow* dan tombol **Simpan** tetap dapat dijangkau.

4. **Peran `GlobalKey<FormState>`, `validator`, dan `validate()` saat tombol *Simpan* ditekan, contoh nilai yang ditolak, dan alasan memilih jenis input saja belum cukup:**

   - **`GlobalKey<FormState>` (`_formKey`):** Berfungsi sebagai pengenal unik untuk mengakses objek `FormState` dari dalam *callback* tombol `Simpan` (yang berada di dalam maupun di luar subtree `Form`).
   - **`validate()`:** Saat tombol `Simpan` ditekan, `_formKey.currentState!.validate()` mengeksekusi seluruh fungsi `validator` milik setiap `TextFormField` dan `FormField<DateTime>` di dalam `Form` secara bersamaan. Jika semua mengembalikan `null`, `validate()` mengembalikan `true` dan `showDialog()` dijalankan; jika ada minimal satu yang mengembalikan pesan *error*, dialog ditahan dan pesan kesalahan ditampilkan tepat di bawah kolom terkait.
   - **`validator`:** Fungsi per-kolom (dimodularisasi di `lib/utils/experience_validators.dart`) yang memeriksa aturan bisnis model `Experience` dan mengembalikan pesan kesalahan jika tidak valid atau `null` jika valid.
   - **Contoh nilai yang ditolak oleh validasi:**
     - Judul atau deskripsi yang hanya berisi spasi (`"   "`) → ditolak karena `value.trim().isEmpty` bernilai `true`.
     - Judul melebihi 255 karakter (`maxTitleLength = 255`) → ditolak agar sesuai batas `CharField(max_length=255)` pada model Django.
     - Tanggal selesai lebih awal dari tanggal mulai (misalnya `started_at = 15 Nov 2026` dan `ended_at = 10 Nov 2026` saat toggle *ongoing* nonaktif) → ditolak dengan pesan `"Tanggal selesai tidak boleh sebelum tanggal mulai!"`.
   - **Mengapa memilih jenis input atau papan ketik saja belum cukup:** Pemilihan widget input atau `TextInputType` hanya membantu kenyamanan pengisian di sisi antarmuka, tetapi tidak menjamin keabsahan aturan domain. Pengguna tetap dapat membiarkan kolom wajib kosong, menempelkan (*paste*) teks spasi kosong atau terlalu panjang, maupun memilih dua tanggal yang masing-masing sah secara format kalender (`DateTime`) namun melanggar logika urutan waktu (`ended_at < started_at`).

---

## AI Disclosure

### Tugas 7
- **Tools:** Antigravity (asisten AI berbasis LLM di IDE).
- **Strategi *Prompting*:** Meminta asisten membaca proyek Tutorial 08 terlebih dahulu, menyusun rencana implementasi bertahap untuk 7 tombol aksi (*Proyek*, *Education*, *Skills*, *Logout*), lalu menerapkan perubahan per langkah agar selaras dengan *Conventional Commits*.
- **Bagian yang Dibantu AI:**
  - Penambahan properti `color` pada `ItemHomepage` dan penyusunan 7 tombol di `lib/menu.dart`.
  - Penambahan `SingleChildScrollView` untuk mencegah *overflow* dan pembaruan `test/widget_test.dart`.
  - Penyusunan draf penjelasan konsep Flutter pada `README.md`.
- **Evaluasi & Perbaikan Manual:** Meninjau langsung pilihan ikon dan kontras warna tombol, memverifikasi identitas profil (`NPM`, `Name`, `Class`), memastikan `flutter analyze` (`No issues found!`) dan `flutter test` lulus, serta menyusun dan melakukan *commit* `README.md` secara mandiri sebelum `git push`.

### Tugas 8
- **Tools:** Antigravity (asisten AI berbasis LLM di IDE).
- **Strategi *Prompting*:** Menggunakan alur perencanaan (`/plan`) dan sesi klarifikasi keputusan desain satu per satu (`/grill-me`) agar AI terlebih dahulu membaca kode Flutter eksisting dan model Django `myportofolio/main/models.py`, menyepakati pilihan model `Experience`, aturan validasi tanggal & *ongoing*, modularisasi validator, serta *commit roadmap* sebelum menulis kode.
- **Bagian yang Dibantu AI:**
  - Pembuatan utilitas validasi & durasi di `lib/utils/experience_validators.dart` serta halaman `ExperienceFormPage` di `lib/screens/experience_form.dart`.
  - Integrasi navigasi kartu `Tambah Experience` (`Navigator.push()`) dan opsi drawer `Add Experience` (`Navigator.pushReplacement()`).
  - Penulisan *unit* dan *widget tests* pada `test/widget_test.dart` serta draf jawaban reflektif Tugas 8 di `README.md`.
- **Analisis Kritis Keterbatasan AI & Perbaikan Manual:**
  - **Kesadaran versi SDK & API depresiasi:** Tanpa pemeriksaan berkas proyek terlebih dahulu, model AI cenderung menghasilkan impor `package:flutter/material.dart` atau parameter `value:` yang sudah *deprecated* pada `DropdownButtonFormField`; pada proyek ini (Flutter 3.50), seluruh berkas telah diverifikasi memakai `package:material_ui/material_ui.dart` dan `initialValue:` sehingga `flutter analyze` bersih.
  - **Deteksi *overflow* layar ponsel lewat pengujian nyata:** Meskipun tata letak awal tampak normal di ukuran layar desktop/default, penambahan simulasi *viewport* ponsel (`390×740`) pada `widget_test.dart` mengungkap *RenderFlex overflow* pada `InfoCard` (`0.286 px`) dan `ItemCard` (`13–33 px`) di `MyHomePage`, yang kemudian diperbaiki menggunakan `Expanded` dan `Flexible` hingga seluruh 8 pengujian lulus tanpa *overflow*.
  - **Verifikasi manual:** Meninjau langsung seluruh alur navigasi, validasi input, `flutter analyze`, `flutter test`, isi jawaban reflektif `README.md`, serta urutan *commit* sebelum `git push` ke GitHub.