// lib/features/meetings/presentation/pages/create_meeting_page.dart
// Requirements: 1.1-1.8, 3.1-3.4

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/meeting_model.dart';
import '../providers/meeting_provider.dart';

/// Page to create or edit a meeting
/// **Validates: Requirements 1.1-1.8, 3.1-3.4**
class CreateMeetingPage extends StatefulWidget {
  final String? meetingId;

  const CreateMeetingPage({super.key, this.meetingId});

  bool get isEditing => meetingId != null;

  @override
  State<CreateMeetingPage> createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController(text: '60');

  String? _selectedClassId;
  String _meetingType = 'online';
  DateTime _meetingDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _meetingTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<MeetingProvider>();
    await provider.loadMyClasses();

    if (widget.isEditing) {
      await provider.loadMeetingDetail(widget.meetingId!);
      final meeting = provider.currentMeeting;
      if (meeting != null) {
        setState(() {
          _titleController.text = meeting.title;
          _descriptionController.text = meeting.description;
          _selectedClassId = meeting.classId;
          _meetingType = meeting.meetingType;
          _meetingDate = meeting.meetingDate;
          _meetingTime = TimeOfDay.fromDateTime(meeting.meetingDate);
          _durationController.text = meeting.durationMinutes.toString();
          _meetingLinkController.text = meeting.meetingLink ?? '';
          _locationController.text = meeting.location ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingLinkController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Pertemuan' : 'Buat Pertemuan'),
      ),
      body: Consumer<MeetingProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Pertemuan *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul pertemuan harus diisi';
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
                  maxLines: 3,
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
                  onChanged: (value) => setState(() => _selectedClassId = value),
                  validator: (value) {
                    if (value == null) return 'Pilih kelas';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tanggal Pertemuan *'),
                  subtitle: Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(_meetingDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
                const Divider(),

                // Time picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Waktu Mulai *'),
                  subtitle: Text(_meetingTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: _selectTime,
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Duration
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Durasi (menit) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Durasi harus diisi';
                    }
                    final duration = int.tryParse(value);
                    if (duration == null || duration <= 0) {
                      return 'Durasi harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Meeting type
                const Text(
                  'Tipe Pertemuan *',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Online'),
                        value: 'online',
                        groupValue: _meetingType,
                        onChanged: (v) => setState(() => _meetingType = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Offline'),
                        value: 'offline',
                        groupValue: _meetingType,
                        onChanged: (v) => setState(() => _meetingType = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Conditional fields
                if (_meetingType == 'online')
                  TextFormField(
                    controller: _meetingLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Meeting Link *',
                      border: OutlineInputBorder(),
                      hintText: 'https://zoom.us/j/...',
                    ),
                    validator: (value) {
                      if (_meetingType == 'online' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Link meeting harus diisi untuk meeting online';
                      }
                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi *',
                      border: OutlineInputBorder(),
                      hintText: 'Ruang kelas, gedung, dll',
                    ),
                    validator: (value) {
                      if (_meetingType == 'offline' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Lokasi harus diisi untuk meeting offline';
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
                        onPressed: _isLoading ? null : _saveMeeting,
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _meetingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _meetingDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _meetingTime,
    );
    if (picked != null) {
      setState(() => _meetingTime = picked);
    }
  }

  Future<void> _saveMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<MeetingProvider>();
    final meetingDateTime = DateTime(
      _meetingDate.year,
      _meetingDate.month,
      _meetingDate.day,
      _meetingTime.hour,
      _meetingTime.minute,
    );

    final meeting = MeetingModel(
      id: widget.meetingId ?? '',
      classId: _selectedClassId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      meetingDate: meetingDateTime,
      durationMinutes: int.parse(_durationController.text),
      meetingType: _meetingType,
      meetingLink: _meetingType == 'online' ? _meetingLinkController.text.trim() : null,
      location: _meetingType == 'offline' ? _locationController.text.trim() : null,
      status: 'scheduled',
      createdBy: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = widget.isEditing
        ? await provider.updateMeeting(meeting)
        : await provider.createMeeting(meeting);

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Pertemuan berhasil diperbarui'
                : 'Pertemuan berhasil dibuat',
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
