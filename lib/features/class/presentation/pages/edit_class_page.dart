import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/class_provider.dart';
import '../../domain/entities/class_entity.dart';
import '../../../../core/constants/app_colors.dart';

class EditClassPage extends StatefulWidget {
  final ClassEntity classEntity;

  const EditClassPage({super.key, required this.classEntity});

  @override
  State<EditClassPage> createState() => _EditClassPageState();
}

class _EditClassPageState extends State<EditClassPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _maxStudentsController;
  int? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classEntity.name);
    _descController = TextEditingController(
      text: widget.classEntity.description,
    );
    _maxStudentsController = TextEditingController(
      text: widget.classEntity.maxStudents.toString(),
    );
    _selectedSubjectId = widget.classEntity.subjectId;

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
        title: const Text('Edit Kelas'),
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
              // Kode Kelas (Read-only)
              if (widget.classEntity.classCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.key, color: accentBlue),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kode Kelas',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            widget.classEntity.classCode!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: accentBlue,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

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
                  onPressed: isLoading ? null : _handleUpdate,
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
                          'Simpan Perubahan',
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

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final classProvider = context.read<ClassProvider>();
    final success = await classProvider.updateClass(
      classId: widget.classEntity.id,
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
          content: Text('Kelas berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            classProvider.errorMessage ?? 'Gagal memperbarui kelas',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
