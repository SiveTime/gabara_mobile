// lib/features/quiz/presentation/widgets/quiz_modal_edit.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/quiz_model.dart';
import '../../domain/entities/quiz_entity.dart';
import '../providers/quiz_provider.dart';

/// Modal dialog for editing quiz metadata and questions
/// **Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5**
class QuizModalEdit extends StatefulWidget {
  final QuizEntity quiz;
  final Function(QuizModel) onSave;

  const QuizModalEdit({super.key, required this.quiz, required this.onSave});

  @override
  State<QuizModalEdit> createState() => _QuizModalEditState();
}

class _QuizModalEditState extends State<QuizModalEdit>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedClassId;
  DateTime? _openDate;
  TimeOfDay? _openTime;
  DateTime? _closeDate;
  TimeOfDay? _closeTime;

  // Questions state
  late List<QuestionModel> _questions;
  final Map<int, TextEditingController> _questionControllers = {};
  final Map<String, TextEditingController> _optionControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Pre-populate fields with existing quiz data
    _titleController = TextEditingController(text: widget.quiz.title);
    _descriptionController = TextEditingController(
      text: widget.quiz.description,
    );
    _selectedClassId = widget.quiz.classId;

    if (widget.quiz.openAt != null) {
      _openDate = widget.quiz.openAt;
      _openTime = TimeOfDay.fromDateTime(widget.quiz.openAt!);
    }
    if (widget.quiz.closeAt != null) {
      _closeDate = widget.quiz.closeAt;
      _closeTime = TimeOfDay.fromDateTime(widget.quiz.closeAt!);
    }

    // Load existing questions
    _questions = widget.quiz.questions.map((q) {
      return QuestionModel(
        id: q.id,
        quizId: q.quizId,
        question: q.question,
        questionType: q.questionType,
        options: q.options
            .map(
              (o) => OptionModel(
                id: o.id,
                questionId: o.questionId,
                text: o.text,
                isCorrect: o.isCorrect,
                orderIndex: o.orderIndex,
              ),
            )
            .toList(),
        orderIndex: q.orderIndex,
      );
    }).toList();

    // Initialize controllers for questions
    for (var i = 0; i < _questions.length; i++) {
      _questionControllers[i] = TextEditingController(
        text: _questions[i].question,
      );
      for (var j = 0; j < _questions[i].optionModels.length; j++) {
        final key = '${i}_$j';
        _optionControllers[key] = TextEditingController(
          text: _questions[i].optionModels[j].text,
        );
      }
    }

    // Fetch classes for dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().fetchMyClasses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _questionControllers.values) {
      controller.dispose();
    }
    for (var controller in _optionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Quiz',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Info Quiz'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pertanyaan'),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_questions.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildInfoTab(), _buildQuestionsTab()],
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Quiz
          _buildLabel('Judul Quiz'),
          TextField(
            controller: _titleController,
            decoration: _inputDecoration('Masukkan judul quiz'),
          ),
          const SizedBox(height: 16),

          // Deskripsi
          _buildLabel('Deskripsi'),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 255,
            decoration: _inputDecoration('Deskripsi'),
          ),
          const SizedBox(height: 16),

          // Kelas dropdown
          _buildLabel('Kelas'),
          Consumer<QuizProvider>(
            builder: (context, provider, child) {
              return DropdownButtonFormField<String>(
                initialValue: _selectedClassId,
                decoration: _inputDecoration('Pilih kelas'),
                items: provider.myClasses.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['id'].toString(),
                    child: Text(c['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedClassId = value);
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Tanggal Dibuka
          _buildLabel('Tanggal Dibuka'),
          _buildDatePicker(date: _openDate, onTap: () => _selectDate(true)),
          const SizedBox(height: 16),

          // Waktu Dibuka
          _buildLabel('Waktu Dibuka'),
          _buildTimePicker(time: _openTime, onTap: () => _selectTime(true)),
          const SizedBox(height: 16),

          // Tanggal Ditutup
          _buildLabel('Tanggal Ditutup'),
          _buildDatePicker(date: _closeDate, onTap: () => _selectDate(false)),
          const SizedBox(height: 16),

          // Waktu Ditutup
          _buildLabel('Waktu Ditutup'),
          _buildTimePicker(time: _closeTime, onTap: () => _selectTime(false)),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab() {
    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada pertanyaan',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pertanyaan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _questions.length,
            itemBuilder: (context, index) => _buildQuestionCard(index),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: OutlinedButton.icon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Pertanyaan'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int questionIndex) {
    final question = _questions[questionIndex];
    final questionController = _questionControllers[questionIndex];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Soal ${questionIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                // Question type dropdown
                DropdownButton<String>(
                  value: question.questionType,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'multiple_choice',
                      child: Text(
                        'Pilihan Ganda',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'true_false',
                      child: Text(
                        'Benar/Salah',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _changeQuestionType(questionIndex, value);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeQuestion(questionIndex),
                  tooltip: 'Hapus pertanyaan',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Question text
            TextField(
              controller: questionController,
              decoration: _inputDecoration('Tulis pertanyaan...'),
              maxLines: 2,
              onChanged: (value) {
                _questions[questionIndex] = question.copyWith(question: value);
              },
            ),
            const SizedBox(height: 16),

            // Options
            _buildLabel('Pilihan Jawaban'),
            const SizedBox(height: 8),
            ...List.generate(
              question.optionModels.length,
              (optionIndex) =>
                  _buildOptionRow(questionIndex, optionIndex, question),
            ),

            // Add option button (only for multiple choice)
            if (question.questionType == 'multiple_choice')
              TextButton.icon(
                onPressed: () => _addOption(questionIndex),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Pilihan'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(
    int questionIndex,
    int optionIndex,
    QuestionModel question,
  ) {
    final option = question.optionModels[optionIndex];
    final key = '${questionIndex}_$optionIndex';
    final controller = _optionControllers[key];
    final isCorrect = option.isCorrect;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Radio button for correct answer
          Radio<int>(
            value: optionIndex,
            groupValue: question.optionModels.indexWhere((o) => o.isCorrect),
            onChanged: (value) {
              if (value != null) {
                _setCorrectOption(questionIndex, value);
              }
            },
            activeColor: Colors.green,
          ),
          // Option text field
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: question.questionType == 'true_false'
                    ? option.text
                    : 'Pilihan ${String.fromCharCode(65 + optionIndex)}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isCorrect ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isCorrect ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isCorrect ? Colors.green : Colors.blue,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixIcon: isCorrect
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              enabled: question.questionType != 'true_false',
              onChanged: (value) {
                _updateOptionText(questionIndex, optionIndex, value);
              },
            ),
          ),
          // Delete option button (only for multiple choice with > 2 options)
          if (question.questionType == 'multiple_choice' &&
              question.optionModels.length > 2)
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: Colors.red.shade300,
                size: 20,
              ),
              onPressed: () => _removeOption(questionIndex, optionIndex),
            ),
        ],
      ),
    );
  }

  void _addQuestion() {
    final newIndex = _questions.length;
    final newQuestion = QuestionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: '',
      questionType: 'multiple_choice',
      options: [
        OptionModel(
          id: '${newIndex}_a',
          text: '',
          isCorrect: false,
          orderIndex: 0,
        ),
        OptionModel(
          id: '${newIndex}_b',
          text: '',
          isCorrect: false,
          orderIndex: 1,
        ),
      ],
      orderIndex: newIndex,
    );

    setState(() {
      _questions.add(newQuestion);
      _questionControllers[newIndex] = TextEditingController();
      _optionControllers['${newIndex}_0'] = TextEditingController();
      _optionControllers['${newIndex}_1'] = TextEditingController();
    });
  }

  void _removeQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pertanyaan'),
        content: Text('Hapus Soal ${index + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _questionControllers[index]?.dispose();
                _questionControllers.remove(index);
                for (
                  var j = 0;
                  j < _questions[index].optionModels.length;
                  j++
                ) {
                  final key = '${index}_$j';
                  _optionControllers[key]?.dispose();
                  _optionControllers.remove(key);
                }
                _questions.removeAt(index);
                // Re-index
                _reindexControllers();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _reindexControllers() {
    final newQuestionControllers = <int, TextEditingController>{};
    final newOptionControllers = <String, TextEditingController>{};

    for (var i = 0; i < _questions.length; i++) {
      _questions[i] = _questions[i].copyWith(orderIndex: i);
      newQuestionControllers[i] = TextEditingController(
        text: _questions[i].question,
      );

      for (var j = 0; j < _questions[i].optionModels.length; j++) {
        final key = '${i}_$j';
        newOptionControllers[key] = TextEditingController(
          text: _questions[i].optionModels[j].text,
        );
      }
    }

    _questionControllers.clear();
    _questionControllers.addAll(newQuestionControllers);
    _optionControllers.clear();
    _optionControllers.addAll(newOptionControllers);
  }

  void _changeQuestionType(int questionIndex, String newType) {
    final question = _questions[questionIndex];
    List<OptionModel> newOptions;

    if (newType == 'true_false') {
      newOptions = [
        OptionModel(
          id: '${questionIndex}_true',
          text: 'Benar',
          isCorrect: false,
          orderIndex: 0,
        ),
        OptionModel(
          id: '${questionIndex}_false',
          text: 'Salah',
          isCorrect: false,
          orderIndex: 1,
        ),
      ];
    } else {
      newOptions = [
        OptionModel(
          id: '${questionIndex}_a',
          text: '',
          isCorrect: false,
          orderIndex: 0,
        ),
        OptionModel(
          id: '${questionIndex}_b',
          text: '',
          isCorrect: false,
          orderIndex: 1,
        ),
      ];
    }

    setState(() {
      _questions[questionIndex] = question.copyWith(
        questionType: newType,
        options: newOptions,
      );
      // Update option controllers
      for (var j = 0; j < newOptions.length; j++) {
        final key = '${questionIndex}_$j';
        _optionControllers[key]?.dispose();
        _optionControllers[key] = TextEditingController(
          text: newOptions[j].text,
        );
      }
    });
  }

  void _addOption(int questionIndex) {
    final question = _questions[questionIndex];
    final newOptionIndex = question.optionModels.length;
    final newOption = OptionModel(
      id: '${questionIndex}_${String.fromCharCode(97 + newOptionIndex)}',
      text: '',
      isCorrect: false,
      orderIndex: newOptionIndex,
    );

    setState(() {
      final updatedOptions = [...question.optionModels, newOption];
      _questions[questionIndex] = question.copyWith(options: updatedOptions);
      _optionControllers['${questionIndex}_$newOptionIndex'] =
          TextEditingController();
    });
  }

  void _removeOption(int questionIndex, int optionIndex) {
    final question = _questions[questionIndex];
    if (question.optionModels.length <= 2) return;

    setState(() {
      final updatedOptions = List<OptionModel>.from(question.optionModels);
      updatedOptions.removeAt(optionIndex);
      // Re-index
      for (var i = 0; i < updatedOptions.length; i++) {
        updatedOptions[i] = updatedOptions[i].copyWith(orderIndex: i);
      }
      _questions[questionIndex] = question.copyWith(options: updatedOptions);

      // Update controllers
      final key = '${questionIndex}_$optionIndex';
      _optionControllers[key]?.dispose();
      _optionControllers.remove(key);
    });
  }

  void _setCorrectOption(int questionIndex, int optionIndex) {
    final question = _questions[questionIndex];
    final updatedOptions = question.optionModels.map((option) {
      final index = question.optionModels.indexOf(option);
      return option.copyWith(isCorrect: index == optionIndex);
    }).toList();

    setState(() {
      _questions[questionIndex] = question.copyWith(options: updatedOptions);
    });
  }

  void _updateOptionText(int questionIndex, int optionIndex, String text) {
    final question = _questions[questionIndex];
    final updatedOptions = List<OptionModel>.from(question.optionModels);
    updatedOptions[optionIndex] = updatedOptions[optionIndex].copyWith(
      text: text,
    );

    _questions[questionIndex] = question.copyWith(options: updatedOptions);
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildDatePicker({DateTime? date, required VoidCallback onTap}) {
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
                  : 'Pilih tanggal',
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

  Widget _buildTimePicker({TimeOfDay? time, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          _buildTimeField(time?.hour.toString().padLeft(2, '0') ?? '00'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(':', style: TextStyle(fontSize: 18)),
          ),
          _buildTimeField(time?.minute.toString().padLeft(2, '0') ?? '00'),
        ],
      ),
    );
  }

  Widget _buildTimeField(String value) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(value, style: const TextStyle(fontSize: 16))),
    );
  }

  Future<void> _selectDate(bool isOpenDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isOpenDate ? _openDate : _closeDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isOpenDate) {
          _openDate = picked;
        } else {
          _closeDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(bool isOpenTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isOpenTime ? _openTime : _closeTime) ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  void _saveQuiz() {
    // Validate
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul quiz tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      _tabController.animateTo(0);
      return;
    }

    DateTime? openAt;
    DateTime? closeAt;

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

    // Build updated questions from current state
    final updatedQuestions = _questions.map((q) {
      return QuestionModel(
        id: q.id,
        quizId: widget.quiz.id,
        question: q.question,
        questionType: q.questionType,
        options: q.optionModels
            .map(
              (o) => OptionModel(
                id: o.id,
                questionId: q.id,
                text: o.text,
                isCorrect: o.isCorrect,
                orderIndex: o.orderIndex,
              ),
            )
            .toList(),
        orderIndex: q.orderIndex,
      );
    }).toList();

    final updatedQuiz = QuizModel(
      id: widget.quiz.id,
      classId: _selectedClassId,
      title: _titleController.text,
      description: _descriptionController.text,
      questions: updatedQuestions,
      openAt: openAt,
      closeAt: closeAt,
      attemptsAllowed: widget.quiz.attemptsAllowed,
      durationMinutes: widget.quiz.durationMinutes,
      status: widget.quiz.status,
      createdBy: widget.quiz.createdBy,
    );

    widget.onSave(updatedQuiz);
  }
}
