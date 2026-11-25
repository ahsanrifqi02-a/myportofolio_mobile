import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/experience_validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan data pengalaman (*Experience*) baru.
///
/// Field dan aturan validasi mengikuti model `Experience` pada backend Django:
/// - `title`: wajib diisi, maks. 255 karakter.
/// - `category`: dropdown 6 kategori pengalaman.
/// - `description`: wajib diisi (multiline).
/// - `started_at`: wajib dipilih melalui `showDatePicker()`.
/// - `is_ongoing`: toggle untuk menandai pengalaman masih berlangsung.
/// - `ended_at`: opsional melalui `showDatePicker()`, nonaktif saat *ongoing*,
///   dan harus >= `started_at`.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<DateTime>> _startDateFieldKey =
      GlobalKey<FormFieldState<DateTime>>();
  final GlobalKey<FormFieldState<DateTime>> _endDateFieldKey =
      GlobalKey<FormFieldState<DateTime>>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _category = ExperienceValidators.categories.first;
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _isOngoing = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Membuka pemilih tanggal (`showDatePicker`) untuk menentukan tanggal mulai.
  Future<void> _pickStartDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startedAt ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
      helpText: 'Pilih Tanggal Mulai',
    );
    if (picked != null) {
      setState(() {
        _startedAt = picked;
      });
      _startDateFieldKey.currentState?.didChange(picked);
      // Re-validasi tanggal selesai agar urutan tanggal langsung terverifikasi.
      if (_endedAt != null) {
        _endDateFieldKey.currentState?.validate();
      }
    }
  }

  /// Membuka pemilih tanggal (`showDatePicker`) untuk menentukan tanggal selesai.
  Future<void> _pickEndDate() async {
    if (_isOngoing) return;
    final DateTime initialDate = _endedAt ?? _startedAt ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
      helpText: 'Pilih Tanggal Selesai',
    );
    if (picked != null) {
      setState(() {
        _endedAt = picked;
      });
      _endDateFieldKey.currentState?.didChange(picked);
    }
  }

  /// Mengosongkan seluruh isian formulir ke nilai awal.
  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _category = ExperienceValidators.categories.first;
      _startedAt = null;
      _endedAt = null;
      _isOngoing = false;
      _autovalidateMode = AutovalidateMode.disabled;
    });
    _startDateFieldKey.currentState?.didChange(null);
    _endDateFieldKey.currentState?.didChange(null);
  }

  /// Memvalidasi seluruh input dan menampilkan `AlertDialog` ringkasan jika valid.
  void _submitForm() {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final DateTime startDate = _startedAt!;
    final String startDateText = ExperienceValidators.formatDate(startDate);
    final String endDateText = _isOngoing
        ? 'Masih berlangsung (Present)'
        : (_endedAt != null ? ExperienceValidators.formatDate(_endedAt!) : '-');
    final String durationText = ExperienceValidators.formatDuration(
      startDate,
      _endedAt,
      isOngoing: _isOngoing,
    );

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Experience berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Judul: $title'),
                const SizedBox(height: 4.0),
                Text('Kategori: $_category'),
                const SizedBox(height: 4.0),
                Text('Deskripsi: $description'),
                const SizedBox(height: 4.0),
                Text('Tanggal Mulai: $startDateText'),
                const SizedBox(height: 4.0),
                Text('Tanggal Selesai: $endDateText'),
                const SizedBox(height: 4.0),
                Text('Durasi: $durationText'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetForm();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Experience',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // === Judul Pengalaman ===
                TextFormField(
                  controller: _titleController,
                  maxLength: ExperienceValidators.maxTitleLength,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Software Engineer Intern',
                    labelText: 'Judul Pengalaman',
                    prefixIcon: const Icon(Icons.work_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: ExperienceValidators.validateTitle,
                ),
                const SizedBox(height: 12.0),

                // === Kategori Pengalaman ===
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: InputDecoration(
                    labelText: 'Kategori Pengalaman',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  items: ExperienceValidators.categories
                      .map(
                        (String category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _category = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16.0),

                // === Deskripsi Pengalaman ===
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan peran, tanggung jawab, dan pencapaian',
                    labelText: 'Deskripsi Pengalaman',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: ExperienceValidators.validateDescription,
                ),
                const SizedBox(height: 16.0),

                // === Tanggal Mulai ===
                FormField<DateTime>(
                  key: _startDateFieldKey,
                  initialValue: _startedAt,
                  validator: ExperienceValidators.validateStartDate,
                  builder: (FormFieldState<DateTime> field) {
                    return InkWell(
                      onTap: _pickStartDate,
                      borderRadius: BorderRadius.circular(8.0),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Tanggal Mulai',
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          errorText: field.errorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          _startedAt != null
                              ? ExperienceValidators.formatDate(_startedAt!)
                              : 'Pilih tanggal mulai',
                          style: TextStyle(
                            color: _startedAt != null
                                ? null
                                : Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8.0),

                // === Toggle Masih Berlangsung (is_ongoing) ===
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Masih berlangsung (Present)'),
                  subtitle: const Text(
                    'Aktifkan jika pengalaman ini sedang dijalani saat ini',
                  ),
                  value: _isOngoing,
                  onChanged: (bool value) {
                    setState(() {
                      _isOngoing = value;
                      if (value) {
                        _endedAt = null;
                      }
                    });
                    if (value) {
                      _endDateFieldKey.currentState?.didChange(null);
                      _endDateFieldKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 8.0),

                // === Tanggal Selesai ===
                FormField<DateTime>(
                  key: _endDateFieldKey,
                  initialValue: _endedAt,
                  validator: (DateTime? value) =>
                      ExperienceValidators.validateEndDate(
                        value,
                        startDate: _startedAt,
                        isOngoing: _isOngoing,
                      ),
                  builder: (FormFieldState<DateTime> field) {
                    return InkWell(
                      onTap: _isOngoing ? null : _pickEndDate,
                      borderRadius: BorderRadius.circular(8.0),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Tanggal Selesai (Opsional)',
                          enabled: !_isOngoing,
                          prefixIcon: const Icon(Icons.event_available),
                          suffixIcon: (!_isOngoing && _endedAt != null)
                              ? IconButton(
                                  tooltip: 'Hapus tanggal selesai',
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _endedAt = null;
                                    });
                                    field.didChange(null);
                                  },
                                )
                              : const Icon(Icons.arrow_drop_down),
                          errorText: field.errorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          _isOngoing
                              ? 'Masih berlangsung (Present)'
                              : (_endedAt != null
                                    ? ExperienceValidators.formatDate(_endedAt!)
                                    : 'Pilih tanggal selesai'),
                          style: TextStyle(
                            color: (!_isOngoing && _endedAt != null)
                                ? null
                                : Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24.0),

                // === Baris Tombol Reset dan Simpan ===
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
