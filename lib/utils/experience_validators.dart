/// Utilitas validasi dan pemformatan tanggal/durasi untuk formulir Experience.
///
/// Seluruh aturan validasi diselaraskan dengan model `Experience` pada backend
/// Django (`myportofolio/main/models.py`):
/// - `title`: wajib diisi, maksimal 255 karakter.
/// - `description`: wajib diisi, tidak boleh hanya berisi spasi.
/// - `category`: salah satu dari 6 opsi `EXPERIENCE_CHOICES`.
/// - `started_at`: wajib dipilih melalui pemilih tanggal.
/// - `ended_at`: opsional; jika tidak berlangsung (*ongoing*) dan diisi,
///   harus sama dengan atau setelah `started_at`.
class ExperienceValidators {
  ExperienceValidators._();

  /// Batas maksimum karakter judul sesuai `CharField(max_length=255)`.
  static const int maxTitleLength = 255;

  /// Pilihan kategori pengalaman sesuai `EXPERIENCE_CHOICES` pada model Django.
  static const List<String> categories = [
    'Full-Time',
    'Part-Time',
    'Internship',
    'Research',
    'Volunteer',
    'Freelance',
  ];

  /// Daftar singkatan nama bulan dalam bahasa Indonesia untuk format tanggal.
  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Memvalidasi judul pengalaman: menolak nilai kosong, hanya spasi,
  /// atau melebihi [maxTitleLength] karakter.
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Judul pengalaman tidak boleh kosong!';
    }
    if (value.trim().length > maxTitleLength) {
      return 'Judul pengalaman maksimal $maxTitleLength karakter!';
    }
    return null;
  }

  /// Memvalidasi deskripsi pengalaman: menolak nilai kosong atau hanya spasi.
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi pengalaman tidak boleh kosong!';
    }
    return null;
  }

  /// Memvalidasi tanggal mulai: wajib dipilih oleh pengguna.
  static String? validateStartDate(DateTime? startDate) {
    if (startDate == null) {
      return 'Tanggal mulai wajib dipilih!';
    }
    return null;
  }

  /// Memvalidasi tanggal selesai terhadap [startDate] dan status [isOngoing].
  ///
  /// Jika [isOngoing] bernilai `true` atau [endDate] belum diisi, validasi
  /// lulus. Jika [startDate] dan [endDate] keduanya ada, [endDate] tidak boleh
  /// lebih awal daripada [startDate].
  static String? validateEndDate(
    DateTime? endDate, {
    required DateTime? startDate,
    required bool isOngoing,
  }) {
    if (isOngoing || endDate == null) {
      return null;
    }
    if (startDate != null &&
        _dateOnly(endDate).isBefore(_dateOnly(startDate))) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
    }
    return null;
  }

  /// Memformat [DateTime] menjadi teks yang mudah dibaca, mis. `23 Nov 2026`.
  static String formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = _monthNames[date.month - 1];
    return '$day $month ${date.year}';
  }

  /// Menghitung dan memformat ringkasan durasi pengalaman secara otomatis.
  static String formatDuration(
    DateTime startDate,
    DateTime? endDate, {
    required bool isOngoing,
  }) {
    if (isOngoing) {
      return 'Sedang berlangsung sejak ${formatDate(startDate)}';
    }
    if (endDate == null) {
      return 'Tanggal selesai belum ditentukan';
    }

    final DateTime start = _dateOnly(startDate);
    final DateTime end = _dateOnly(endDate);
    final int totalMonths =
        (end.year - start.year) * 12 + (end.month - start.month);

    if (totalMonths <= 0) {
      final int days = end.difference(start).inDays;
      if (days <= 0) {
        return '1 hari';
      }
      return '${days + 1} hari';
    }

    final int years = totalMonths ~/ 12;
    final int months = totalMonths % 12;

    if (years > 0 && months > 0) {
      return '$years tahun $months bulan';
    } else if (years > 0) {
      return '$years tahun';
    }
    return '$months bulan';
  }

  /// Menormalkan [DateTime] ke komponen tanggal saja (jam 00:00:00) agar
  /// perbandingan tanggal akurat.
  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
