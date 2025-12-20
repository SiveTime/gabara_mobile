import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/class_provider.dart';
import '../../../../core/constants/app_colors.dart';

class CreateClassPage extends StatefulWidget {
  const CreateClassPage({super.key});

  @override
  State<CreateClassPage> createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _maxStudentsController = TextEditingController(
    text: '30',
  );
  int? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ClassProvider>(context, listen: false).fetchSubjects(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final isLoading = classProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Kelas Baru'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: accentBlue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kode kelas akan dibuat otomatis setelah kelas berhasil dibuat.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nama Kelas
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kelas',
                  hintText: 'Contoh: Matematika Dasar XII',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama kelas wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // Mata Pelajaran
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Mata Pelajaran',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                initialValue: _selectedSubjectId,
                items: classProvider.subjects.map((subject) {
                  return DropdownMenuItem<int>(
                    value: subject['id'] as int,
                    child: Text(subject['name']),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSubjectId = value),
                validator: (value) =>
                    value == null ? 'Pilih mata pelajaran' : null,
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Singkat',
                  hintText: 'Jelaskan tujuan pembelajaran kelas ini...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // Kuota Siswa
              TextFormField(
                controller: _maxStudentsController,
                decoration: const InputDecoration(
                  labelText: 'Kuota Siswa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                  helperText: 'Maksimal jumlah siswa dalam kelas',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kuota wajib diisi';
                  }
                  if (int.tryParse(value) == null) return 'Harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Tombol Simpan
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Buat Kelas',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    final classProvider = context.read<ClassProvider>();
    final success = await classProvider.createClass(
      name: _nameController.text,
      description: _descController.text,
      subjectId: _selectedSubjectId!,
      maxStudents: int.parse(_maxStudentsController.text),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kelas berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(classProvider.errorMessage ?? 'Gagal membuat kelas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
