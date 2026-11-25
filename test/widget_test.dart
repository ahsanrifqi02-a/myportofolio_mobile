import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/experience_validators.dart';

ApiClient _createMockApiClient({
  List<Map<String, dynamic>>? projects,
  bool failGetProjects = false,
  bool failLogin = false,
  bool failLogout = false,
}) {
  final sampleProjects =
      projects ??
      [
        {
          'id': '11111111-1111-1111-1111-111111111111',
          'title': 'MyPortfolio',
          'description': 'Full-stack Django and Flutter portfolio app.',
          'tech_stack': 'Flutter, Django',
          'project_url': 'https://example.com/myportfolio',
          'project_image_url': '',
        },
      ];

  return ApiClient(
    baseUrl: 'http://localhost:8000',
    client: MockClient((request) async {
      if (request.url.path == '/api/v1/projects/' && request.method == 'GET') {
        if (failGetProjects) {
          return http.Response('Internal Server Error', 500);
        }
        return http.Response(jsonEncode(sampleProjects), 200);
      }

      if (request.url.path == '/api/v1/projects/' && request.method == 'POST') {
        if (request.headers['Authorization'] != 'Token test-token') {
          return http.Response('{"detail": "Unauthorized"}', 401);
        }
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({'id': '22222222-2222-2222-2222-222222222222', ...body}),
          201,
        );
      }

      if (request.url.path == '/api/v1/auth/token/' &&
          request.method == 'POST') {
        if (failLogin) {
          return http.Response('{"non_field_errors": ["Invalid"]}', 400);
        }
        return http.Response(jsonEncode({'token': 'test-token'}), 200);
      }

      if (request.url.path == '/api/v1/auth/logout/' &&
          request.method == 'POST') {
        if (failLogout) {
          return http.Response('{"detail": "Invalid token"}', 401);
        }
        return http.Response('', 204);
      }

      return http.Response('Not Found', 404);
    }),
  );
}

void main() {
  group('Project model JSON serialization', () {
    test('fromJson maps snake_case fields and defaults missing image URL', () {
      final project = Project.fromJson({
        'id': 'abc-123',
        'title': 'Portfolio App',
        'description': 'A mobile app',
        'tech_stack': 'Flutter',
        'project_url': 'https://example.com',
      });

      expect(project.id, 'abc-123');
      expect(project.title, 'Portfolio App');
      expect(project.techStack, 'Flutter');
      expect(project.projectUrl, 'https://example.com');
      expect(project.projectImageUrl, '');
    });

    test('toJson omits id and outputs snake_case keys', () {
      const project = Project(
        id: 'abc-123',
        title: 'Portfolio App',
        description: 'A mobile app',
        techStack: 'Flutter',
        projectUrl: 'https://example.com',
        projectImageUrl: 'https://example.com/img.png',
      );

      final json = project.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json['title'], 'Portfolio App');
      expect(json['tech_stack'], 'Flutter');
      expect(json['project_url'], 'https://example.com');
      expect(json['project_image_url'], 'https://example.com/img.png');
    });
  });

  group('ApiClient and AuthState unit tests', () {
    test(
      'ApiClient fetches projects, obtains token, creates project, logs out',
      () async {
        final api = _createMockApiClient();

        final projects = await api.getProjects();
        expect(projects, hasLength(1));
        expect(projects.first.title, 'MyPortfolio');

        final token = await api.obtainToken('owner', 'secret');
        expect(token, 'test-token');

        final created = await api.createProject(
          const Project(
            title: 'Burhan',
            description: 'Burhanpedia',
            techStack: 'Flutter, Django',
            projectUrl: 'https://example.com',
          ),
          token: token,
        );
        expect(created.id, '22222222-2222-2222-2222-222222222222');
        expect(created.title, 'Burhan');

        await api.logout(token: token);
      },
    );

    test('AuthState clears token even if server logout fails', () async {
      final api = _createMockApiClient(failLogout: true);
      final authState = AuthState(api);

      expect(authState.isLoggedIn, isFalse);
      await authState.login('owner', 'secret');
      expect(authState.isLoggedIn, isTrue);
      expect(authState.token, 'test-token');

      await authState.logout();
      expect(authState.isLoggedIn, isFalse);
      expect(authState.token, isNull);
    });
  });

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

    test(
      'formatDate and formatDuration format dates and durations properly',
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
      },
    );
  });

  testWidgets('MyPortfolio homepage displays profile info and action buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2506624266'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Ahsan Rifqi Prasetyo'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('PBP F'), findsOneWidget);

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

    await tester.tap(find.text('Lihat Education'));
    await tester.pump();
    expect(
      find.text('Kamu telah menekan tombol Lihat Education!'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Lihat Proyek loads public projects and opens ProjectDetailScreen',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

      await tester.tap(find.text('Lihat Proyek'));
      await tester.pumpAndSettle();

      expect(find.text('Achievements: Projects'), findsOneWidget);
      expect(find.text('MyPortfolio'), findsOneWidget);
      expect(find.text('Flutter, Django'), findsOneWidget);

      await tester.tap(find.text('MyPortfolio'));
      await tester.pumpAndSettle();

      expect(find.text('https://example.com/myportfolio'), findsOneWidget);
    },
  );

  testWidgets('ProjectListScreen shows empty state when API returns []', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(apiClient: _createMockApiClient(projects: const [])),
    );

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();

    expect(find.text('No projects found.'), findsOneWidget);
  });

  testWidgets('Tambah Proyek requires login, then validates and submits form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

    // Tapping Tambah Proyek while logged out opens LoginScreen.
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsWidgets);

    // Log in via LoginScreen.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'owner',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // After login, ProjectFormPage opens automatically.
    expect(find.text('Add Project Form'), findsOneWidget);

    // Wait for SnackBar to dismiss before tapping Save.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Submit empty form to trigger validation.
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Title cannot be empty!'), findsOneWidget);
    expect(find.text('Description cannot be empty!'), findsOneWidget);
    expect(find.text('Tech stack cannot be empty!'), findsOneWidget);
    expect(find.text('Project URL cannot be empty!'), findsOneWidget);

    // Fill valid project fields.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Burhan',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Burhanpedia',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tech Stack'),
      'Flutter, Django',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Project URL'),
      'https://example.com',
    );

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Project saved successfully!'), findsOneWidget);
    expect(find.text('Title: Burhan'), findsOneWidget);
    expect(find.text('Description: Burhanpedia'), findsOneWidget);
    expect(find.text('Tech Stack: Flutter, Django'), findsOneWidget);
    expect(find.text('Project URL: https://example.com'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Project saved successfully!'), findsNothing);
  });

  testWidgets(
    'LeftDrawer switches between Login and Logout and guards Add Project',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
      expect(find.text('Add Experience'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Log in from drawer.
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'owner',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Open drawer again: Logout should now appear and Add Project opens directly.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.text('Logout'), findsWidgets);

      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      expect(find.text('Add Project Form'), findsOneWidget);
    },
  );

  testWidgets(
    'Tambah Experience card opens form on phone viewport, validates dates/fields, and displays summary dialog',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

      await tester.ensureVisible(find.text('Tambah Experience'));
      await tester.tap(find.text('Tambah Experience'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Experience'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Judul pengalaman tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Deskripsi pengalaman tidak boleh kosong!'),
        findsOneWidget,
      );
      expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);

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

      await tester.ensureVisible(find.text('Full-Time'));
      await tester.tap(find.text('Full-Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Internship').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Pilih tanggal mulai'));
      await tester.tap(find.text('Pilih tanggal mulai'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Masih berlangsung (Present)'));
      await tester.tap(find.text('Masih berlangsung (Present)'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Experience berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Judul: Software Engineer Intern'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Experience berhasil ditambahkan!'), findsNothing);
    },
  );
}
