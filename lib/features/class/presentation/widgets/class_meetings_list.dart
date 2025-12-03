// lib/features/class/presentation/widgets/class_meetings_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../meetings/data/models/meeting_model.dart';
import '../../../meetings/presentation/providers/meeting_provider.dart';
import '../../../assignments/data/models/assignment_model.dart';
import '../../../assignments/presentation/providers/assignment_provider.dart';
import '../pages/student_assignment_detail_page.dart';
import '../pages/mentor_assignment_detail_page.dart';
import 'class_assignments_list.dart';

/// Widget untuk menampilkan daftar pertemuan dalam sebuah kelas
class ClassMeetingsList extends StatefulWidget {
  final String classId;
  final bool isMentor;

  const ClassMeetingsList({
    super.key,
    required this.classId,
    this.isMentor = false,
  });

  @override
  State<ClassMeetingsList> createState() => _ClassMeetingsListState();
}

class _ClassMeetingsListState extends State<ClassMeetingsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMeetings();
    });
  }

  Future<void> _loadMeetings() async {
    final provider = context.read<MeetingProvider>();
    await provider.loadMeetingsByClass(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MeetingProvider>(
      builder: (context, provider, child) {
        final meetings = provider.meetings;
        final isLoading = provider.isLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List of meetings
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (meetings.isEmpty)
              _buildEmptyState(context)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return MeetingCard(
                    meeting: meeting,
                    meetingNumber: index + 1,
                    isMentor: widget.isMentor,
                    onTap: () => _showMeetingDetail(context, meeting),
                    onEdit: widget.isMentor ? () => _editMeeting(context, meeting) : null,
                    onDelete: widget.isMentor ? () => _deleteMeeting(context, meeting) : null,
                  );
                },
              ),

            // Add meeting button for mentor
            if (widget.isMentor) ...[
              const SizedBox(height: 16),
              _buildAddMeetingButton(context),
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
        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            widget.isMentor
                ? 'Belum ada pertemuan untuk kelas ini'
                : 'Belum ada materi yang tersedia',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (widget.isMentor) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showAddMeetingDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pertemuan'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddMeetingButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _showAddMeetingDialog(context),
        icon: const Icon(Icons.add, color: primaryBlue),
        label: const Text('Tambah Pertemuan', style: TextStyle(color: primaryBlue)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: primaryBlue.withValues(alpha: 0.5), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }


  void _showAddMeetingDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMeetingPage(classId: widget.classId),
      ),
    ).then((_) => _loadMeetings());
  }

  void _showMeetingDetail(BuildContext context, MeetingModel meeting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingDetailBottomSheet(
          meeting: meeting,
          isMentor: widget.isMentor,
        ),
      ),
    );
  }

  void _editMeeting(BuildContext context, MeetingModel meeting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMeetingPage(meeting: meeting),
      ),
    ).then((_) => _loadMeetings());
  }

  Future<void> _deleteMeeting(BuildContext context, MeetingModel meeting) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pertemuan'),
        content: Text('Apakah Anda yakin ingin menghapus "${meeting.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<MeetingProvider>();
      final success = await provider.deleteMeeting(meeting.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Pertemuan berhasil dihapus' : 'Gagal menghapus pertemuan'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

/// Card untuk menampilkan item pertemuan
class MeetingCard extends StatefulWidget {
  final MeetingModel meeting;
  final int meetingNumber;
  final bool isMentor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MeetingCard({
    super.key,
    required this.meeting,
    required this.meetingNumber,
    this.isMentor = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<MeetingCard> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  bool _isExpanded = false;
  List<AssignmentModel> _assignments = [];
  List<AssignmentModel> _allClassAssignments = []; // All assignments in class for global numbering
  bool _isLoadingAssignments = false;
  late AssignmentProvider _assignmentProvider;

  @override
  void initState() {
    super.initState();
    _assignmentProvider = context.read<AssignmentProvider>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    if (_isLoadingAssignments) return;
    
    setState(() => _isLoadingAssignments = true);
    try {
      // Load ALL assignments for this class (for global numbering)
      final allAssignments = await _assignmentProvider.assignmentService
          .fetchAssignmentsByClass(widget.meeting.classId);
      
      // Sort by created_at for consistent numbering
      allAssignments.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.now();
        final bDate = b.createdAt ?? DateTime.now();
        return aDate.compareTo(bDate);
      });
      
      // Filter assignments that belong to this meeting
      final meetingAssignments = allAssignments.where((a) {
        final attachmentUrl = a.attachmentUrl ?? '';
        if (attachmentUrl.startsWith('meeting:${widget.meeting.id}|')) {
          return true;
        }
        if (attachmentUrl == 'meeting:${widget.meeting.id}') {
          return true;
        }
        return false;
      }).toList();
      
      if (mounted) {
        setState(() {
          _allClassAssignments = allAssignments;
          _assignments = meetingAssignments;
          _isExpanded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading assignments: $e');
    } finally {
      if (mounted) setState(() => _isLoadingAssignments = false);
    }
  }

  /// Get global assignment number based on all assignments in class
  int _getGlobalAssignmentNumber(AssignmentModel assignment) {
    final index = _allClassAssignments.indexWhere((a) => a.id == assignment.id);
    return index >= 0 ? index + 1 : 1;
  }

  void _toggleExpanded() {
    if (!_isExpanded && _assignments.isEmpty) {
      _loadAssignments();
    } else {
      setState(() => _isExpanded = !_isExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Pertemuan ${widget.meetingNumber} - ${widget.meeting.title}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey.shade600,
                          ),
                          if (widget.isMentor)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') widget.onEdit?.call();
                                if (value == 'delete') widget.onDelete?.call();
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
                    ],
                  ),

                  // Description
                  if (widget.meeting.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.meeting.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Expanded section (berkas + tugas)
          if (_isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Berkas section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Berkas',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      if (widget.isMentor)
                        OutlinedButton.icon(
                          onPressed: () => _showAddFileDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            side: BorderSide(color: Colors.blue.withValues(alpha: 0.5)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_getAttachments().isEmpty)
                    Center(
                      child: Text(
                        'Belum ada berkas',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    )
                  else
                    ..._getAttachments().asMap().entries.map((entry) => _buildAttachmentTile(entry.value, entry.key)),
                  
                  const SizedBox(height: 16),
                  
                  // Tugas section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tugas',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      if (widget.isMentor)
                        OutlinedButton.icon(
                          onPressed: () => _navigateToAddAssignment(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            side: BorderSide(color: primaryBlue.withValues(alpha: 0.5)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingAssignments)
                    const Center(child: CircularProgressIndicator())
                  else if (_assignments.isEmpty)
                    Center(
                      child: Text(
                        'Belum ada tugas',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = _assignments[index];
                        return _buildAssignmentTile(context, assignment, index);
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Parse attachments from meetingLink field
  List<Map<String, String>> _getAttachments() {
    final meetingLink = widget.meeting.meetingLink;
    if (meetingLink == null || meetingLink.isEmpty) return [];
    
    try {
      return meetingLink.split('|||').map((item) {
        final parts = item.split('::');
        return {
          'name': parts.isNotEmpty ? parts[0] : 'Berkas',
          'url': parts.length > 1 ? parts[1] : '',
        };
      }).where((a) => a['url']!.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }

  Widget _buildAttachmentTile(Map<String, String> attachment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue.shade50,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_outlined, color: Colors.blue.shade400, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment['name'] ?? 'Berkas',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  attachment['url'] ?? '',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (widget.isMentor)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditFileDialog(context, attachment, index);
                } else if (value == 'delete') {
                  _deleteFile(context, index);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
              icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }

  void _showEditFileDialog(BuildContext context, Map<String, String> attachment, int index) {
    final urlController = TextEditingController(text: attachment['url']);
    final nameController = TextEditingController(text: attachment['name']);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Berkas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Nama Berkas',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: 'URL Berkas (https://...)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (urlController.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext);
                await _updateFileInMeeting(
                  index,
                  nameController.text.trim().isNotEmpty 
                      ? nameController.text.trim() 
                      : 'Berkas',
                  urlController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateFileInMeeting(int index, String name, String url) async {
    try {
      final provider = context.read<MeetingProvider>();
      
      // Get current attachments and update the specific one
      final currentAttachments = _getAttachments();
      if (index < currentAttachments.length) {
        currentAttachments[index] = {'name': name, 'url': url};
      }
      
      // Convert to string format
      final attachmentsJson = currentAttachments
          .map((a) => '${a['name']}::${a['url']}')
          .join('|||');
      
      // Update meeting with new attachments
      final updatedMeeting = widget.meeting.copyWith(meetingLink: attachmentsJson);
      final result = await provider.updateMeeting(updatedMeeting);
      
      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berkas berhasil diupdate'), backgroundColor: Colors.green),
          );
          setState(() {});
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
    }
  }

  Future<void> _deleteFile(BuildContext context, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Berkas'),
        content: const Text('Apakah Anda yakin ingin menghapus berkas ini?'),
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
      try {
        final provider = context.read<MeetingProvider>();
        
        // Get current attachments and remove the specific one
        final currentAttachments = _getAttachments();
        if (index < currentAttachments.length) {
          currentAttachments.removeAt(index);
        }
        
        // Convert to string format (or null if empty)
        String? attachmentsJson;
        if (currentAttachments.isNotEmpty) {
          attachmentsJson = currentAttachments
              .map((a) => '${a['name']}::${a['url']}')
              .join('|||');
        }
        
        // Update meeting with new attachments
        final updatedMeeting = widget.meeting.copyWith(meetingLink: attachmentsJson);
        final result = await provider.updateMeeting(updatedMeeting);
        
        if (mounted) {
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Berkas berhasil dihapus'), backgroundColor: Colors.green),
            );
            setState(() {});
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
      }
    }
  }

  Widget _buildAssignmentTile(BuildContext context, AssignmentModel assignment, int index) {
    final now = DateTime.now();
    final isExpired = assignment.deadline.isBefore(now);
    final globalNumber = _getGlobalAssignmentNumber(assignment);

    return GestureDetector(
      onTap: () {
        // Navigate to assignment detail page
        if (widget.isMentor) {
          // Mentor: navigasi ke halaman detail mentor
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MentorAssignmentDetailPage(
                assignment: assignment,
                assignmentNumber: globalNumber,
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
                assignmentNumber: globalNumber,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: isExpired ? Colors.red.shade100 : Colors.orange.shade100),
          borderRadius: BorderRadius.circular(8),
          color: isExpired ? Colors.red.shade50 : Colors.orange.shade50,
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon tugas
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isExpired ? Colors.red.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: isExpired ? Colors.red.shade400 : Colors.orange.shade400,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 12, color: isExpired ? Colors.red : Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Deadline: ${DateFormat('dd MMM, HH:mm').format(assignment.deadline)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isExpired ? Colors.red : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.isMentor)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAssignmentPage(assignment: assignment),
                        ),
                      ).then((_) => _loadAssignments());
                    } else if (value == 'delete') {
                      _deleteAssignment(context, assignment);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                  icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade600),
                ),
            ],
          ),
          if (assignment.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                assignment.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  void _navigateToAddAssignment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssignmentPage(
          classId: widget.meeting.classId,
          meetingId: widget.meeting.id,
        ),
      ),
    ).then((_) => _loadAssignments());
  }

  void _showAddFileDialog(BuildContext context) {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Berkas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Nama Berkas',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: 'URL Berkas (https://...)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (urlController.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext);
                await _addFileToMeeting(
                  nameController.text.trim().isNotEmpty 
                      ? nameController.text.trim() 
                      : 'Berkas',
                  urlController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _addFileToMeeting(String name, String url) async {
    try {
      final provider = context.read<MeetingProvider>();
      
      // Get current attachments
      final currentAttachments = _getAttachments();
      currentAttachments.add({'name': name, 'url': url});
      
      // Convert to string format
      final attachmentsJson = currentAttachments
          .map((a) => '${a['name']}::${a['url']}')
          .join('|||');
      
      // Update meeting with new attachments
      final updatedMeeting = widget.meeting.copyWith(meetingLink: attachmentsJson);
      final result = await provider.updateMeeting(updatedMeeting);
      
      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berkas berhasil ditambahkan'), backgroundColor: Colors.green),
          );
          setState(() {});
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
    }
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
        if (success) _loadAssignments();
      }
    }
  }
}


/// Page untuk menambah pertemuan baru
class AddMeetingPage extends StatefulWidget {
  final String classId;

  const AddMeetingPage({super.key, required this.classId});

  @override
  State<AddMeetingPage> createState() => _AddMeetingPageState();
}

class _AddMeetingPageState extends State<AddMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;
  MeetingModel? _createdMeeting;
  
  // File attachments
  final List<Map<String, String>> _attachments = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddFileDialog() {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Berkas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Nama Berkas',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: 'URL Berkas (https://...)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                setState(() {
                  _attachments.add({
                    'name': nameController.text.trim().isNotEmpty 
                        ? nameController.text.trim() 
                        : 'Berkas ${_attachments.length + 1}',
                    'url': urlController.text.trim(),
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
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
          'Tambah Pertemuan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveMeeting,
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
                decoration: InputDecoration(
                  hintText: 'Judul Pertemuan',
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul pertemuan tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Deskripsi Pertemuan',
                  alignLabelWithHint: true,
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
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 24),

              // Attachments section
              if (_attachments.isNotEmpty) ...[
                const Text(
                  'Berkas Terlampir',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _attachments.length,
                  itemBuilder: (context, index) {
                    final attachment = _attachments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.description_outlined, color: Colors.blue.shade400, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attachment['name'] ?? 'Berkas',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  attachment['url'] ?? '',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeAttachment(index),
                            icon: Icon(Icons.close, size: 18, color: Colors.red.shade400),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showAddFileDialog,
                      icon: Icon(Icons.attach_file, color: Colors.purple.shade400),
                      label: Text('Tambah Berkas', style: TextStyle(color: Colors.purple.shade400)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.purple.shade200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToAddAssignment(context),
                      icon: Icon(Icons.assignment_outlined, color: Colors.purple.shade400),
                      label: Text('Tambah Tugas', style: TextStyle(color: Colors.purple.shade400)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.purple.shade200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<MeetingProvider>();
      
      // Get current user ID
      final userId = provider.meetingService.supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User tidak login');
      }

      // Convert attachments to JSON string for storage in meetingLink field
      String? attachmentsJson;
      if (_attachments.isNotEmpty) {
        attachmentsJson = _attachments.map((a) => '${a['name']}::${a['url']}').join('|||');
      }

      final meeting = MeetingModel(
        id: '',
        classId: widget.classId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        meetingDate: DateTime.now(),
        meetingType: 'offline', // Default type for class meetings
        meetingLink: attachmentsJson, // Store attachments here
        status: 'scheduled',
        createdBy: userId,
      );

      final created = await provider.createMeeting(meeting);

      if (mounted) {
        if (created != null) {
          setState(() => _createdMeeting = created);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pertemuan berhasil ditambahkan'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Close after saving
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

  Future<void> _navigateToAddAssignment(BuildContext context) async {
    // If meeting is not saved yet, save it first
    if (_createdMeeting == null) {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi judul pertemuan terlebih dahulu')),
        );
        return;
      }
      
      // Save meeting first
      await _saveMeetingAndContinue();
      if (_createdMeeting == null) return; // Failed to save
    }
    
    // Navigate to add assignment with the meeting ID
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAssignmentPage(
            classId: widget.classId,
            meetingId: _createdMeeting!.id,
          ),
        ),
      ).then((_) {
        // After adding assignment, close this page and go back to meetings list
        if (mounted) Navigator.pop(context);
      });
    }
  }

  Future<void> _saveMeetingAndContinue() async {
    setState(() => _isSaving = true);

    try {
      final provider = context.read<MeetingProvider>();
      
      final userId = provider.meetingService.supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User tidak login');
      }

      String? attachmentsJson;
      if (_attachments.isNotEmpty) {
        attachmentsJson = _attachments.map((a) => '${a['name']}::${a['url']}').join('|||');
      }

      final meeting = MeetingModel(
        id: '',
        classId: widget.classId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        meetingDate: DateTime.now(),
        meetingType: 'offline',
        meetingLink: attachmentsJson,
        status: 'scheduled',
        createdBy: userId,
      );

      final created = await provider.createMeeting(meeting);

      if (mounted && created != null) {
        setState(() => _createdMeeting = created);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pertemuan berhasil disimpan'), backgroundColor: Colors.green),
        );
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

/// Page untuk edit pertemuan
class EditMeetingPage extends StatefulWidget {
  final MeetingModel meeting;

  const EditMeetingPage({super.key, required this.meeting});

  @override
  State<EditMeetingPage> createState() => _EditMeetingPageState();
}

class _EditMeetingPageState extends State<EditMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.meeting.title);
    _descriptionController = TextEditingController(text: widget.meeting.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
          'Edit Pertemuan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _updateMeeting,
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
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Judul Pertemuan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Deskripsi Pertemuan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<MeetingProvider>();
      final updated = widget.meeting.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      final result = await provider.updateMeeting(updated);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pertemuan berhasil diupdate'), backgroundColor: Colors.green),
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

/// Bottom sheet untuk detail pertemuan
class MeetingDetailBottomSheet extends StatelessWidget {
  final MeetingModel meeting;
  final bool isMentor;

  const MeetingDetailBottomSheet({
    super.key,
    required this.meeting,
    this.isMentor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pertemuan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meeting.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat: ${DateFormat('dd MMMM yyyy', 'id').format(meeting.createdAt ?? DateTime.now())}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (meeting.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(meeting.description, style: TextStyle(color: Colors.grey.shade700)),
            ],
            const SizedBox(height: 24),
            const Text('Lampiran', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            _buildAttachmentTile(
              icon: Icons.description_outlined,
              color: Colors.blue,
              title: 'Berkas',
              subtitle: 'Tidak ada berkas',
            ),
            _buildAttachmentTile(
              icon: Icons.assignment_outlined,
              color: Colors.orange,
              title: 'Tugas',
              subtitle: 'Belum ada tugas terkait',
            ),
            _buildAttachmentTile(
              icon: Icons.quiz_outlined,
              color: Colors.purple,
              title: 'Kuis',
              subtitle: 'Belum ada kuis terkait',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
    );
  }
}
