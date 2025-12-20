import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../presentation/providers/class_provider.dart';
import '../../presentation/widgets/class_card.dart';
import '../../domain/entities/class_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../presentation/pages/profile_page.dart';
import '../../../../presentation/layout/student_app_drawer.dart';
import '../../../../presentation/layout/tutor_app_drawer.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _enrollCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final classProvider = Provider.of<ClassProvider>(context, listen: false);

      if (authProvider.user?.role == 'mentor') {
        classProvider.fetchMyClasses();
      } else {
        classProvider.fetchClasses();
      }
    });
  }

  @override
  void dispose() {
    _enrollCodeController.dispose();
    super.dispose();
  }

  void _showEnrollDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Bergabung ke Kelas",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Kode Enrollment *",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _enrollCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: "Masukkan kode kelas",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black54,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_enrollCodeController.text.isNotEmpty) {
                            final classProvider = context.read<ClassProvider>();
                            final success = await classProvider.joinClass(
                              _enrollCodeController.text,
                            );

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);

                            if (!mounted) return;
                            if (success) {
                              _enrollCodeController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Berhasil bergabung ke kelas!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    classProvider.errorMessage ??
                                        "Gagal bergabung",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Bergabung",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, ClassEntity classEntity) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Hapus Kelas'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kelas "${classEntity.name}"?\n\nSemua data terkait kelas ini akan dihapus permanen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final classProvider = context.read<ClassProvider>();
                final success = await classProvider.deleteClass(classEntity.id);

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Kelas berhasil dihapus'
                          : 'Gagal menghapus kelas',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isMentor = authProvider.user?.role == 'mentor';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isMentor
          ? const TutorAppDrawer(activeRoute: 'class')
          : const StudentAppDrawer(activeRoute: 'class'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Image.asset('assets/GabaraColor.png', height: 28),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildProfilePopupMenu(context),
          ),
        ],
      ),
      floatingActionButton: isMentor
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/create-class'),
              label: const Text('Buat Kelas'),
              icon: const Icon(Icons.add),
              backgroundColor: accentBlue,
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => isMentor
            ? classProvider.fetchMyClasses()
            : classProvider.fetchClasses(),
        child: classProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : classProvider.classes.isEmpty
            ? _buildEmptyState(isMentor)
            : Column(
                children: [
                  // Header yang konsisten untuk semua state
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kelasku',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (!isMentor)
                          ElevatedButton.icon(
                            onPressed: () => _showEnrollDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Enroll"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Class List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: classProvider.classes.length,
                      itemBuilder: (context, index) {
                        final classItem = classProvider.classes[index];
                        return ClassCard(
                          classEntity: classItem,
                          isMentor: isMentor,
                          onEdit: isMentor
                              ? () => Navigator.pushNamed(
                                  context,
                                  '/edit-class',
                                  arguments: classItem,
                                )
                              : null,
                          onDelete: isMentor
                              ? () =>
                                    _showDeleteConfirmation(context, classItem)
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMentor) {
    return Column(
      children: [
        // Header yang konsisten
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kelasku',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (!isMentor)
                ElevatedButton.icon(
                  onPressed: () => _showEnrollDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Enroll"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Empty state content
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/kosong.png',
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => Icon(
                        Icons.school_outlined,
                        size: 120,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isMentor
                          ? "Belum ada kelas"
                          : "Tidak ada kelas yang di enroll",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        isMentor
                            ? "Buat kelas pertama Anda dengan menekan tombol 'Buat Kelas' di bawah"
                            : "Silahkan enroll dengan meminta kode kelas kepada tutor pribadi dengan menekan tombol 'Enroll' di atas!",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePopupMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit_profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        } else if (value == 'logout') {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          authProvider.logout();
        }
      },
      icon: const Icon(Icons.more_vert, color: Colors.black),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  user?.name[0] ?? 'U',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    authProvider.user?.role ?? 'Student',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'edit_profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: 12),
              Text('Edit Profil'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Keluar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
