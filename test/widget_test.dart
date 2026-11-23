import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/utils/experience_validators.dart';

void main() {
  group('ExperienceValidators unit tests', () {
    test('validateTitle rejects empty, whitespace, and > 255 characters', () {
      expect(
        ExperienceValidators.validateTitle(null),
        'Judul pengalaman tidak boleh kosong!',
      );
      expect(
        ExperienceValidators.validateTitle('   '),
        'Judul pengalaman tidak boleh kosong!',
      );
      expect(
        ExperienceValidators.validateTitle('a' * 256),
        'Judul pengalaman maksimal 255 karakter!',
      );
      expect(
        ExperienceValidators.validateTitle('Software Engineer Intern'),
        isNull,
      );
    });

    test('validateDescription rejects empty and whitespace-only values', () {
      expect(
        ExperienceValidators.validateDescription(''),
        'Deskripsi pengalaman tidak boleh kosong!',
      );
      expect(
        ExperienceValidators.validateDescription('   \n\t '),
        'Deskripsi pengalaman tidak boleh kosong!',
      );
      expect(
        ExperienceValidators.validateDescription('Membangun API dan UI.'),
        isNull,
      );
    });

    test('validateStartDate and validateEndDate enforce date ordering', () {
      final DateTime start = DateTime(2026, 6, 15);
      final DateTime beforeStart = DateTime(2026, 6, 10);
      final DateTime afterStart = DateTime(2026, 11, 15);

      expect(
        ExperienceValidators.validateStartDate(null),
        'Tanggal mulai wajib dipilih!',
      );
      expect(ExperienceValidators.validateStartDate(start), isNull);

      expect(
        ExperienceValidators.validateEndDate(
          beforeStart,
          startDate: start,
          isOngoing: false,
        ),
        'Tanggal selesai tidak boleh sebelum tanggal mulai!',
      );
      expect(
        ExperienceValidators.validateEndDate(
          beforeStart,
          startDate: start,
          isOngoing: true,
        ),
        isNull,
      );
      expect(
        ExperienceValidators.validateEndDate(
          afterStart,
          startDate: start,
          isOngoing: false,
        ),
        isNull,
      );
    });

    test('formatDate and formatDuration format dates and durations properly',
        () {
      final DateTime start = DateTime(2025, 1, 10);
      final DateTime end = DateTime(2026, 3, 10);

      expect(ExperienceValidators.formatDate(start), '10 Jan 2025');
      expect(
        ExperienceValidators.formatDuration(start, end, isOngoing: false),
        '1 tahun 2 bulan',
      );
      expect(
        ExperienceValidators.formatDuration(start, null, isOngoing: true),
        'Sedang berlangsung sejak 10 Jan 2025',
      );
    });
  });

  testWidgets('MyPortfolio homepage displays profile info and action buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verifikasi 3 InfoCard identitas pemilik portofolio.
    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2506624266'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Ahsan Rifqi Prasetyo'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('PBP F'), findsOneWidget);

    // Verifikasi 8 tombol aksi ItemCard (termasuk Tambah Experience).
    const List<String> buttonNames = [
      'Lihat Proyek',
      'Tambah Proyek',
      'Lihat Education',
      'Tambah Education',
      'Lihat Skills',
      'Tambah Skills',
      'Tambah Experience',
      'Logout',
    ];

    for (final String name in buttonNames) {
      expect(find.text(name), findsOneWidget);
    }

    // Verifikasi SnackBar muncul saat tombol ditekan.
    await tester.tap(find.text('Lihat Education'));
    await tester.pump();
    expect(
      find.text('Kamu telah menekan tombol Lihat Education!'),
      findsOneWidget,
    );
  });

  testWidgets('LeftDrawer navigates between Home, Add Project, and Add Experience',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Buka drawer melalui ikon menu di AppBar.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('My Portfolio'), findsOneWidget);
    expect(
      find.text('Explore personal projects and experiences!'),
      findsOneWidget,
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    expect(find.text('Add Experience'), findsOneWidget);

    // Navigasi ke ProjectFormPage melalui drawer.
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    // Navigasi ke ExperienceFormPage melalui drawer yang sama.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Experience'), findsOneWidget);

    // Kembali ke halaman utama melalui opsi Home di drawer.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Tambah Proyek button opens form, validates, and displays dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tekan kartu Tambah Proyek untuk membuka ProjectFormPage.
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsOneWidget);

    // Tunggu SnackBar selesai agar tidak menutupi tombol Save di bagian bawah layar uji.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Tekan Save saat form kosong untuk memicu validasi.
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);

    // Isi field formulir.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      'Burhan',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
      'Burhanpedia',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Teknologi yang Digunakan'),
      'Flutter, Django',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tautan Proyek'),
      'https://example.com',
    );

    // Simpan formulir dan verifikasi AlertDialog.
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: Burhan'), findsOneWidget);
    expect(find.text('Deskripsi: Burhanpedia'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
    expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
    expect(find.text('Tautan: https://example.com'), findsOneWidget);

    // Tutup dialog dengan tombol OK.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Proyek berhasil ditambahkan!'), findsNothing);
  });

  testWidgets(
      'Tambah Experience card opens form on phone viewport, validates dates/fields, and displays summary dialog',
      (WidgetTester tester) async {
    // Simulasikan layar selebar ponsel untuk memastikan form dapat digulir tanpa overflow.
    tester.view.physicalSize = const Size(390, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());

    // Scroll ke kartu Tambah Experience dan buka via Navigator.push().
    await tester.ensureVisible(find.text('Tambah Experience'));
    await tester.tap(find.text('Tambah Experience'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Experience'), findsOneWidget);

    // Tunggu SnackBar selesai agar tidak menutupi tombol di bagian bawah.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Uji validasi ketika form kosong.
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Judul pengalaman tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi pengalaman tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);

    // Uji validasi menolak input yang hanya berisi spasi.
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'Judul Pengalaman'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul Pengalaman'),
      '   ',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Pengalaman'),
      '   ',
    );
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Judul pengalaman tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi pengalaman tidak boleh kosong!'), findsOneWidget);

    // Isi judul & deskripsi valid.
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, 'Judul Pengalaman'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul Pengalaman'),
      'Software Engineer Intern',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Pengalaman'),
      'Mengembangkan aplikasi Flutter dan REST API Django.',
    );

    // Pilih kategori Internship dari dropdown.
    await tester.ensureVisible(find.text('Full-Time'));
    await tester.tap(find.text('Full-Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Internship').last);
    await tester.pumpAndSettle();

    // Pilih Tanggal Mulai = tanggal 15 pada bulan berjalan.
    await tester.ensureVisible(find.text('Pilih tanggal mulai'));
    await tester.tap(find.text('Pilih tanggal mulai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Pilih Tanggal Selesai lebih awal (tanggal 10) untuk menguji validasi urutan tanggal.
    await tester.ensureVisible(find.text('Pilih tanggal selesai'));
    await tester.tap(find.text('Pilih tanggal selesai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(
      find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
      findsOneWidget,
    );

    // Aktifkan toggle Masih berlangsung (Present), sehingga tanggal selesai diabaikan.
    await tester.ensureVisible(find.text('Masih berlangsung (Present)'));
    await tester.tap(find.text('Masih berlangsung (Present)'));
    await tester.pumpAndSettle();

    // Simpan formulir dan verifikasi AlertDialog muncul dengan seluruh isian.
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Experience berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Judul: Software Engineer Intern'), findsOneWidget);
    expect(find.text('Kategori: Internship'), findsOneWidget);
    expect(
      find.text(
        'Deskripsi: Mengembangkan aplikasi Flutter dan REST API Django.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Tanggal Selesai: Masih berlangsung (Present)'),
      findsOneWidget,
    );

    // Tutup dialog dengan tombol OK dan pastikan dialog tertutup.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Experience berhasil ditambahkan!'), findsNothing);
  });
}
