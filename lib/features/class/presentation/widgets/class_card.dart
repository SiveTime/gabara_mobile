import 'package:flutter/material.dart';
import '../../domain/entities/class_entity.dart';

class ClassCard extends StatelessWidget {
  final ClassEntity classEntity;
  final VoidCallback? onTap; // Agar kartu bisa diklik

  const ClassCard({
    super.key, 
    required this.classEntity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Chip Mapel & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      classEntity.subjectName, // Menampilkan Mapel
                      style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(
                    classEntity.isActive ? Icons.check_circle : Icons.cancel,
                    color: classEntity.isActive ? Colors.green : Colors.red,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Nama Kelas
              Text(
                classEntity.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              // Nama Tutor
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    classEntity.tutorName, // Menampilkan Tutor
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              // Jumlah Siswa
              Row(
                children: [
                  const Icon(Icons.group, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${classEntity.maxStudents} siswa max', // Menampilkan max siswa
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade200),
              
              // Deskripsi singkat
              Text(
                classEntity.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}