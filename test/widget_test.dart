import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
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

    // Verifikasi 7 tombol aksi ItemCard.
    const List<String> buttonNames = [
      'Lihat Proyek',
      'Tambah Proyek',
      'Lihat Education',
      'Tambah Education',
      'Lihat Skills',
      'Tambah Skills',
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

  testWidgets('LeftDrawer navigates between Home and Add Project Form',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Buka drawer melalui ikon menu di AppBar.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('My Portfolio'), findsOneWidget);
    expect(find.text('Explore personal projects and experiences!'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);

    // Navigasi ke ProjectFormPage melalui drawer.
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsOneWidget);

    // Kembali ke halaman utama melalui drawer.
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
}
