// lib/features/assignments/presentation/pages/create_assignment_page.dart
// Requirements: 5.1-5.8, 7.1-7.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/assignment_model.dart';
import '../providers/assignment_provider.dart';

/// Page to create or edit an assignment
/// **Validates: Requirements 5.1-5.8, 7.1-7.5**
class CreateAssignmentPage extends StatefulWidget {
  final String? assignmentId;

  const CreateAssignmentPage({super.key, this.assignmentId});

  bool get isEditing => assignmentId != null;

  @override
  State<CreateAssignmentPage> createState() => _CreateAssignmentPageState();
}

class _CreateAssignmentPageState extends State<CreateAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxScoreController = TextEditingController(text: '100');

  String? _selectedClassId;
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _deadlineTime = const TimeOfDay(hour: 23, minute: 59);
  bool _isLoading = false;
  bool _hasSubmissions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<AssignmentProvider>();
    await provider.loadMyClasses();

    if (widget.isEditing) {
      await provider.loadAssignmentDetail(widget.assignmentId!);
      final assignment = provider.currentAssignment;
      _hasSubmissions = provider.hasSubmissions;
      
      if (assignment != null) {
        setState(() {
          _titleController.text = assignment.title;
          _descriptionController.text = assignment.description;
          _selectedClassId = assignment.classId;
          _deadline = assignment.deadline;
          _deadlineTime = TimeOfDay.fromDateTime(assignment.deadline);
          _maxScoreController.text = assignment.maxScore.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxScoreController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Tugas' : 'Buat Tugas'),
      ),
      body: Consumer<AssignmentProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Warning for editing with submissions
                if (widget.isEditing && _hasSubmissions)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[800]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tugas ini sudah memiliki submission. Deadline dan nilai maksimal tidak dapat diubah.',
                            style: TextStyle(color: Colors.orange[800]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Tugas *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul tugas harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                // Class dropdown
                DropdownButtonFormField<String>(
                  value: _selectedClassId,
                  decoration: const InputDecoration(
                    labelText: 'Kelas *',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.myClasses.map((c) {
                    return DropdownMenuItem(
                      value: c['id'] as String,
                      child: Text(c['name'] as String),
                    );
                  }).toList(),
                  onChanged: widget.isEditing ? null : (value) => setState(() => _selectedClassId = value),
                  validator: (value) {
                    if (value == null) return 'Pilih kelas';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Deadline date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deadline *'),
                  subtitle: Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(_deadline),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _hasSubmissions ? null : _selectDeadlineDate,
                ),
                const Divider(),

                // Deadline time picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Waktu Deadline *'),
                  subtitle: Text(_deadlineTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: _hasSubmissions ? null : _selectDeadlineTime,
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Max score
                TextFormField(
                  controller: _maxScoreController,
                  decoration: const InputDecoration(
                    labelText: 'Nilai Maksimal *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !_hasSubmissions,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nilai maksimal harus diisi';
                    }
                    final score = int.tryParse(value);
                    if (score == null || score <= 0) {
                      return 'Nilai maksimal harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAssignment,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.isEditing ? 'Simpan' : 'Buat'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDeadlineDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _selectDeadlineTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _deadlineTime,
    );
    if (picked != null) {
      setState(() => _deadlineTime = picked);
    }
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<AssignmentProvider>();
    final deadlineDateTime = DateTime(
      _deadline.year,
      _deadline.month,
      _deadline.day,
      _deadlineTime.hour,
      _deadlineTime.minute,
    );

    final assignment = AssignmentModel(
      id: widget.assignmentId ?? '',
      classId: _selectedClassId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: deadlineDateTime,
      maxScore: int.parse(_maxScoreController.text),
      isActive: true,
      createdBy: '',
    );

    final result = widget.isEditing
        ? await provider.updateAssignment(assignment)
        : await provider.createAssignment(assignment);

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? 'Tugas berhasil diperbarui' : 'Tugas berhasil dibuat',
          ),
        ),
      );
      Navigator.pop(context);
    } else if (provider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
