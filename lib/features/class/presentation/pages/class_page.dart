import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // Import AuthProvider
import '../providers/class_provider.dart';
import '../widgets/class_card.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  @override
  void initState() {
    super.initState();
    // Panggil data kelas saat halaman pertama kali dimuat
    Future.microtask(
      () => Provider.of<ClassProvider>(context, listen: false).fetchClasses(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);

    // Cek Role User untuk menampilkan tombol Buat Kelas
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isMentor = authProvider.user?.role == 'mentor';

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kelas'), centerTitle: true),
      // Tombol Floating Action Button hanya untuk Mentor
      floatingActionButton: isMentor
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/create-class');
              },
              label: const Text('Buat Kelas'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => classProvider.fetchClasses(),
        child: classProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : classProvider.classes.isEmpty
            ? _buildEmptyState() // Widget kosong jika belum ada kelas
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: classProvider.classes.length,
                itemBuilder: (context, index) {
                  final classItem = classProvider.classes[index];
                  return ClassCard(
                    classEntity: classItem,
                    onTap: () {
                      // TODO: Navigasi ke Detail Kelas
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Masuk ke kelas: ${classItem.name}"),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.class_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Belum ada kelas tersedia",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
