import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/class_provider.dart';
import 'package:gabara_mobile/core/widgets/common_button.dart';
import '../../domain/entities/class_entity.dart';

class CreateClassPage extends StatefulWidget {
  const CreateClassPage({super.key});

  @override
  State<CreateClassPage> createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClassProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Kelas Baru')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Kelas'),
                validator: (v) =>
                    v!.isEmpty ? 'Nama kelas tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (v) =>
                    v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              CommonButton(
                label: 'Simpan',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newClass = ClassEntity(
                      id: '',
                      name: _nameController.text,
                      description: _descController.text,
                      tutorName: 'Tutor Default',
                      studentCount: 0,
                    );
                    await provider.addClass(newClass);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
