import 'package:flutter/material.dart';
import '../../domain/entities/class_entity.dart';

class ClassCard extends StatelessWidget {
  final ClassEntity classEntity;

  const ClassCard({super.key, required this.classEntity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(classEntity.name),
        subtitle: Text(classEntity.description),
        trailing: Text('${classEntity.studentCount} siswa'),
      ),
    );
  }
}
