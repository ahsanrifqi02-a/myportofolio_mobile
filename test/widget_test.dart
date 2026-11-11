import 'package:flutter_test/flutter_test.dart';
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
}

