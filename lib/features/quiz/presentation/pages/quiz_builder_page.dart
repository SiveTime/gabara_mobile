// lib/features/quiz/presentation/pages/quiz_builder_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import '../widgets/question_editor.dart';

/// QuizBuilderPage for creating new quiz
/// **Validates: Requirements 2.1, 2.2, 2.3, 2.6, 2.7, 2.8, 2.9, 2.10, 2.11**
class QuizBuilderPage extends StatefulWidget {
  const QuizBuilderPage({super.key});

  @override
  State<QuizBuilderPage> createState() => _QuizBuilderPageState();
}

class _QuizBuilderPageState extends State<QuizBuilderPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '10');
  final _attemptsController = TextEditingController(text: '1');

  String? _selectedClassId;
  String _status = 'draft';
  DateTime? _openDate;
  TimeOfDay? _openTime;
  DateTime? _closeDate;
  TimeOfDay? _closeTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<QuizProvider>();
      provider.fetchMyClasses();
      provider.initBuilder();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _attemptsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/logo_gabara.png',
          height: 40,
          errorBuilder: (context, error, stackTrace) => const Text(
            'GARASI BELAJAR',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Home',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.grey,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Kuis',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const Text(
                        'Buat Quiz',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                // Form
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormCard(provider),
                      const SizedBox(height: 16),

                      // Questions section
                      ...provider.builderQuestions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final question = entry.value;
                        return QuestionEditor(
                          index: index,
                          question: question,
                          onQuestionTextChanged: (text) =>
                              provider.updateQuestionText(index, text),
                          onTypeChanged: (type) =>
                              provider.changeQuestionType(index, type),
                          onDelete: () => provider.removeQuestion(index),
                          onAddOption: () => provider.addOption(index),
                          onRemoveOption: (optIndex) =>
                              provider.removeOption(index, optIndex),
                          onSetCorrectOption: (optIndex) =>
                              provider.setCorrectOption(index, optIndex),
                          onOptionTextChanged: (optIndex, text) =>
                              provider.updateOptionText(index, optIndex, text),
                        );
                      }),

                      // Add question button
                      TextButton.icon(
                        onPressed: () => provider.addQuestion(),
                        icon: const Icon(Icons.add, color: Colors.blue),
                        label: const Text(
                          'Tambah Pertanyaan',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(color: Colors.grey),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _saveQuiz(provider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Simpan Quiz',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(QuizProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Judul Quiz'),
          TextField(
            controller: _titleController,
            decoration: _inputDecoration('Masukkan judul quiz'),
          ),
          const SizedBox(height: 16),

          _buildLabel('Deskripsi'),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            maxLength: 255,
            decoration: _inputDecoration('Deskripsi'),
          ),
          const SizedBox(height: 16),

          _buildLabel('Kelas'),
          DropdownButtonFormField<String>(
            initialValue: _selectedClassId,
            decoration: _inputDecoration('Pilih kelas'),
            items: provider.myClasses.map((c) {
              return DropdownMenuItem<String>(
                value: c['id'].toString(),
                child: Text(c['name'] ?? ''),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedClassId = value),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Tanggal Dibuka'),
                    _buildDatePicker(_openDate, () => _selectDate(true)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Waktu Dibuka'),
                    _buildTimePicker(_openTime, () => _selectTime(true)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Tanggal Ditutup'),
                    _buildDatePicker(_closeDate, () => _selectDate(false)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Waktu Ditutup'),
                    _buildTimePicker(_closeTime, () => _selectTime(false)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Durasi (menit)'),
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('10'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Status'),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: _inputDecoration(''),
                      items: const [
                        DropdownMenuItem(value: 'draft', child: Text('Draf')),
                        DropdownMenuItem(
                          value: 'published',
                          child: Text('Diterbitkan'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _status = value ?? 'draft'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildLabel('Kesempatan Mengerjakan'),
          TextField(
            controller: _attemptsController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('1'),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildDatePicker(DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                  : 'Pilih tanggal mulai',
              style: TextStyle(
                color: date != null ? Colors.black87 : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(TimeOfDay? time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(time?.hour.toString().padLeft(2, '0') ?? '00'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(':'),
          ),
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(time?.minute.toString().padLeft(2, '0') ?? '00'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isOpen) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isOpen) {
          _openDate = picked;
        } else {
          _closeDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(bool isOpen) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isOpen) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  void _saveQuiz(QuizProvider provider) async {
    DateTime? openAt, closeAt;
    if (_openDate != null && _openTime != null) {
      openAt = DateTime(
        _openDate!.year,
        _openDate!.month,
        _openDate!.day,
        _openTime!.hour,
        _openTime!.minute,
      );
    }
    if (_closeDate != null && _closeTime != null) {
      closeAt = DateTime(
        _closeDate!.year,
        _closeDate!.month,
        _closeDate!.day,
        _closeTime!.hour,
        _closeTime!.minute,
      );
    }

    final quiz = QuizModel(
      id: '',
      classId: _selectedClassId,
      title: _titleController.text,
      description: _descriptionController.text,
      questions: provider.builderQuestions,
      openAt: openAt,
      closeAt: closeAt,
      attemptsAllowed: int.tryParse(_attemptsController.text) ?? 1,
      durationMinutes: int.tryParse(_durationController.text) ?? 10,
      status: _status,
    );

    final success = await provider.createQuiz(quiz);
    if (success && mounted) {
      provider.clearBuilder();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz berhasil dibuat'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
