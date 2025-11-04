import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// Diekstrak dari kuis_edit.dart
class QuizEditDialog extends StatefulWidget {
  final bool isEditing;
  const QuizEditDialog({super.key, required this.isEditing});

  @override
  State<QuizEditDialog> createState() => _QuizEditDialogState();
}

class _QuizEditDialogState extends State<QuizEditDialog> {
    final _titleController = TextEditingController(text: 'QUIZ 2: Pengantar Tekdus');
    final _descController = TextEditingController(text: 'Fokus utama Teknik Industri (Tekdus) adalah pada sistem skala makro: proses, manusia, alur kerja, efisiensi, dan produktivitas.');
    final _durationController = TextEditingController(text: '10');
    
    String _quizStatus = 'Published';

    @override
    void initState(){
        super.initState();
        if (!widget.isEditing) {
            _titleController.clear();
            _descController.clear();
            _durationController.clear();
        }
    }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.isEditing ? 'Edit Quiz' : 'Buat Quiz', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildLabel('Judul Quiz'),
                        TextFormField(controller: _titleController, decoration: const InputDecoration(border: OutlineInputBorder())),
                        const SizedBox(height: 16),

                        _buildLabel('Deskripsi'),
                        TextFormField(controller: _descController, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder())),
                        const SizedBox(height: 16),

                        _buildLabel('Dibuka'),
                        TextFormField(readOnly: true, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'dd/mm/yyyy --:--', suffixIcon: Icon(Icons.calendar_today))),
                        const SizedBox(height: 16),

                        _buildLabel('Ditutup'),
                        TextFormField(readOnly: true, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'dd/mm/yyyy --:--', suffixIcon: Icon(Icons.calendar_today))),
                        const SizedBox(height: 16),

                        _buildLabel('Durasi (menit)'),
                        TextFormField(controller: _durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder())),
                        const SizedBox(height: 16),

                        _buildLabel('Status'),
                         DropdownButtonFormField<String>(
                            initialValue: _quizStatus,
                            items: ['Published', 'Draft'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _quizStatus = newValue!;
                              });
                            },
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                          ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        _buildQuestionEditor(1),

                        TextButton.icon(
                          onPressed: (){}, 
                          icon: const Icon(Icons.add), 
                          label: const Text('Tambah Pertanyaan'),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(), 
                              child: const Text('Batal'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: (){
                                // Logika simpan kuis
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white), 
                              child: const Text('Simpan Quiz'),
                            )
                          ],
                        )
                    ],
                ),
            ),
        ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildQuestionEditor(int number){
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8)
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                 Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text('Pertanyaan $number', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        DropdownButton<String>(
                            value: 'Multiple Choice',
                            items: ['Multiple Choice', 'Essay'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (_) {},
                        ),
                        TextButton(
                          onPressed: (){}, 
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Hapus'),
                        ),
                    ],
                 ),
                 const SizedBox(height: 16),
                 const TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Pertanyaan')),
                 const SizedBox(height: 16),
                 Row(
                    children: [
                      ElevatedButton(
                        onPressed: (){}, 
                        child: const Text("Choose File"),
                      ),
                      const SizedBox(width: 12),
                      const Text("No file chosen"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildOptionEditor('A'),
                  _buildOptionEditor('B'),

                  TextButton.icon(
                    onPressed: (){}, 
                    icon: const Icon(Icons.add), 
                    label: const Text('Tambah opsi'),
                  ),
            ],
            
        ),
      );
  }

  String? _selectedOption;

  Widget _buildOptionEditor(String optionLabel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _selectedOption == optionLabel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: _selectedOption == optionLabel ? Theme.of(context).primaryColor : Colors.grey,
            ),
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            onPressed: () {
              setState(() {
                _selectedOption = optionLabel;
              });
            },
          ),
          Expanded(
            child: TextFormField(
              controller: TextEditingController(text: 'Opsi $optionLabel'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }
}