// lib/features/class/presentation/widgets/class_assignments_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../assignments/data/models/assignment_model.dart';
import '../../../assignments/presentation/providers/assignment_provider.dart';
import '../pages/mentor_assignment_detail_page.dart';
import '../pages/student_assignment_detail_page.dart';

/// Widget untuk menampilkan daftar tugas dalam sebuah kelas
class ClassAssignmentsList extends StatefulWidget {
  final String classId;
  final bool isMentor;

  const ClassAssignmentsList({
    super.key,
    required this.classId,
    this.isMentor = false,
  });

  @override
  State<ClassAssignmentsList> createState() => _ClassAssignmentsListState();
}

class _ClassAssignmentsListState extends State<ClassAssignmentsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssignments();
    });
  }

  Future<void> _loadAssignments() async {
    final provider = context.read<AssignmentProvider>();
    await provider.loadAssignmentsByClass(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssignmentProvider>(
      builder: (context, provider, child) {
        final assignments = provider.assignments;
        final isLoading = provider.isLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (assignments.isEmpty)
              _buildEmptyState(context)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  return AssignmentCard(
                    assignment: assignment,
                    isMentor: widget.isMentor,
                    onTap: () => _showAssignmentDetail(context, assignment, index),
                    onEdit: widget.isMentor ? () => _editAssignment(context, assignment) : null,
                    onDelete: widget.isMentor ? () => _deleteAssignment(context, assignment) : null,
                  );
                },
              ),

            // Add assignment button for mentor
            if (widget.isMentor) ...[
              const SizedBox(height: 16),
              _buildAddAssignmentButton(context),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            widget.isMentor ? 'Belum ada tugas untuk kelas ini' : 'Belum ada tugas yang tersedia',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (widget.isMentor) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showAddAssignmentPage(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Tugas'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddAssignmentButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _showAddAssignmentPage(context),
        icon: const Icon(Icons.add, color: primaryBlue),
        label: const Text('Tambah Tugas', style: TextStyle(color: primaryBlue)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: primaryBlue.withValues(alpha: 0.5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showAddAssignmentPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAssignmentPage(classId: widget.classId)),
    ).then((_) => _loadAssignments());
  }

  void _showAssignmentDetail(BuildContext context, AssignmentModel assignment, int index) {
    if (widget.isMentor) {
      // Mentor: navigasi ke halaman detail mentor
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MentorAssignmentDetailPage(
            assignment: assignment,
            assignmentNumber: index + 1,
          ),
        ),
      ).then((_) => _loadAssignments());
    } else {
      // Siswa: navigasi ke halaman detail siswa
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentAssignmentDetailPage(
            assignment: assignment,
            assignmentNumber: index + 1,
          ),
        ),
      );
    }
  }

  void _editAssignment(BuildContext context, AssignmentModel assignment) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAssignmentPage(assignment: assignment)),
    ).then((_) => _loadAssignments());
  }

  Future<void> _deleteAssignment(BuildContext context, AssignmentModel assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text('Apakah Anda yakin ingin menghapus "${assignment.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<AssignmentProvider>();
      final success = await provider.deleteAssignment(assignment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Tugas berhasil dihapus' : 'Gagal menghapus tugas'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}


/// Card untuk menampilkan item tugas
class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final bool isMentor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AssignmentCard({
    super.key,
    required this.assignment,
    this.isMentor = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = assignment.deadline.isBefore(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.assignment_outlined, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: isExpired ? Colors.red : Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Deadline: ${DateFormat('dd MMM yyyy, HH:mm').format(assignment.deadline)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isExpired ? Colors.red : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isMentor)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Hapus', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    ),
                ],
              ),
              if (assignment.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  assignment.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.star_outline,
                    label: 'Nilai Min: ${assignment.maxScore}',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(isExpired),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isExpired ? 'Tertutup' : 'Aktif',
        style: TextStyle(
          fontSize: 11,
          color: isExpired ? Colors.red : Colors.green,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


/// Page untuk menambah tugas baru (sesuai gambar)
class AddAssignmentPage extends StatefulWidget {
  final String classId;
  final String? meetingId; // Optional meeting link

  const AddAssignmentPage({super.key, required this.classId, this.meetingId});

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _attachmentController = TextEditingController();
  
  // Multiple file links
  final List<TextEditingController> _fileControllers = [TextEditingController()];
  
  DateTime? _openDate;
  TimeOfDay? _openTime;
  DateTime? _closeDate;
  TimeOfDay? _closeTime;
  int _maxScore = 100;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Default open date is now
    _openDate = DateTime.now();
    _openTime = TimeOfDay.now();
    // Default close date is 7 days from now
    _closeDate = DateTime.now().add(const Duration(days: 7));
    _closeTime = const TimeOfDay(hour: 23, minute: 59);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _attachmentController.dispose();
    for (var controller in _fileControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Tugas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAssignment,
            child: Text(
              'Simpan',
              style: TextStyle(
                color: _isSaving ? Colors.grey : primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Berkas Section
              const Text('Berkas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ..._buildFileFields(),
              const SizedBox(height: 8),
              _buildAddFileButton(),

              const SizedBox(height: 24),

              // Tugas Section
              const Text('Tugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Judul Tugas *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tugas tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Attachment URL field
              TextFormField(
                controller: _attachmentController,
                decoration: _inputDecoration('Link File Pendukung (Opsional)'),
              ),

              const SizedBox(height: 12),

              // Date and Time pickers row - Open
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Tanggal Dibuka', _openDate, (date) => setState(() => _openDate = date))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimePicker('Waktu Dibuka', _openTime, (time) => setState(() => _openTime = time))),
                ],
              ),

              const SizedBox(height: 12),

              // Date and Time pickers row - Close
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Tanggal Ditutup', _closeDate, (date) => setState(() => _closeDate = date))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimePicker('Waktu Ditutup', _closeTime, (time) => setState(() => _closeTime = time))),
                ],
              ),

              const SizedBox(height: 12),

              // Description field
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: _inputDecoration('Deskripsi Tugas *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tugas tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Min Score field
              TextFormField(
                initialValue: '100',
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Nilai Minimal'),
                onChanged: (value) {
                  _maxScore = int.tryParse(value) ?? 100;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFileFields() {
    return _fileControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: _inputDecoration('Masukkan link berkas (URL)'),
              ),
            ),
            if (_fileControllers.length > 1)
              IconButton(
                onPressed: () => _removeFileField(index),
                icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade400),
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildAddFileButton() {
    return OutlinedButton.icon(
      onPressed: _addFileField,
      icon: Icon(Icons.add, color: Colors.purple.shade400),
      label: Text('Tambah Link Berkas Lain', style: TextStyle(color: Colors.purple.shade400)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.purple.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addFileField() {
    setState(() {
      _fileControllers.add(TextEditingController());
    });
  }

  void _removeFileField(int index) {
    setState(() {
      _fileControllers[index].dispose();
      _fileControllers.removeAt(index);
    });
  }

  Widget _buildDatePicker(String label, DateTime? value, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onChanged(date);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null ? DateFormat('dd/MM/yyyy').format(value) : label,
              style: TextStyle(color: value != null ? Colors.black : Colors.grey),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? value, Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        if (time != null) onChanged(time);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null ? value.format(context) : label,
              style: TextStyle(color: value != null ? Colors.black : Colors.grey),
            ),
            const Icon(Icons.access_time, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_closeDate == null || _closeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal dan waktu ditutup harus diisi'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = context.read<AssignmentProvider>();
      final userId = provider.assignmentService.supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak login');

      // Combine date and time for deadline
      final deadline = DateTime(
        _closeDate!.year,
        _closeDate!.month,
        _closeDate!.day,
        _closeTime!.hour,
        _closeTime!.minute,
      );

      // Collect file URLs
      final fileUrls = _fileControllers
          .map((c) => c.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      // Build attachment URL with meeting reference if meetingId is provided
      String? attachmentUrl;
      final userAttachment = _attachmentController.text.trim().isNotEmpty 
          ? _attachmentController.text.trim() 
          : (fileUrls.isNotEmpty ? fileUrls.first : null);
      
      if (widget.meetingId != null) {
        // Store meeting reference in attachment_url: "meeting:meeting_id|actual_url"
        attachmentUrl = 'meeting:${widget.meetingId}|${userAttachment ?? ''}';
      } else {
        attachmentUrl = userAttachment;
      }

      final assignment = AssignmentModel(
        id: '',
        classId: widget.classId,
        meetingId: null, // Don't send meeting_id to avoid database errors
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: deadline,
        maxScore: _maxScore,
        attachmentUrl: attachmentUrl,
        createdBy: userId,
      );

      final created = await provider.createAssignment(assignment);

      if (mounted) {
        if (created != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil ditambahkan'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${provider.errorMessage}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}


/// Page untuk edit tugas
class EditAssignmentPage extends StatefulWidget {
  final AssignmentModel assignment;

  const EditAssignmentPage({super.key, required this.assignment});

  @override
  State<EditAssignmentPage> createState() => _EditAssignmentPageState();
}

class _EditAssignmentPageState extends State<EditAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _attachmentController;
  late DateTime _closeDate;
  late TimeOfDay _closeTime;
  late int _maxScore;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignment.title);
    _descriptionController = TextEditingController(text: widget.assignment.description);
    _attachmentController = TextEditingController(text: widget.assignment.attachmentUrl ?? '');
    _closeDate = widget.assignment.deadline;
    _closeTime = TimeOfDay.fromDateTime(widget.assignment.deadline);
    _maxScore = widget.assignment.maxScore;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Tugas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _updateAssignment,
            child: Text(
              'Simpan',
              style: TextStyle(
                color: _isSaving ? Colors.grey : primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Judul Tugas *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tugas tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Attachment URL field
              TextFormField(
                controller: _attachmentController,
                decoration: _inputDecoration('Link File Pendukung (Opsional)'),
              ),

              const SizedBox(height: 12),

              // Date and Time pickers row - Close
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Tanggal Ditutup', _closeDate, (date) => setState(() => _closeDate = date))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimePicker('Waktu Ditutup', _closeTime, (time) => setState(() => _closeTime = time))),
                ],
              ),

              const SizedBox(height: 12),

              // Description field
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: _inputDecoration('Deskripsi Tugas *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tugas tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Min Score field
              TextFormField(
                initialValue: _maxScore.toString(),
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Nilai Minimal'),
                onChanged: (value) {
                  _maxScore = int.tryParse(value) ?? 100;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime value, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onChanged(date);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd/MM/yyyy').format(value)),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay value, Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: value);
        if (time != null) onChanged(time);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value.format(context)),
            const Icon(Icons.access_time, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _updateAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<AssignmentProvider>();

      final deadline = DateTime(
        _closeDate.year,
        _closeDate.month,
        _closeDate.day,
        _closeTime.hour,
        _closeTime.minute,
      );

      final updated = widget.assignment.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: deadline,
        maxScore: _maxScore,
        attachmentUrl: _attachmentController.text.trim().isNotEmpty ? _attachmentController.text.trim() : null,
      );

      final result = await provider.updateAssignment(updated);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil diupdate'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${provider.errorMessage}'), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
