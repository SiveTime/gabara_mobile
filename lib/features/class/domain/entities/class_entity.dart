import 'package:equatable/equatable.dart';

class ClassEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String subjectName; // <-- Tambahan baru
  final String tutorName;   // <-- Tambahan baru
  final int maxStudents;
  final bool isActive;

  const ClassEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.subjectName, // <-- Tambahkan di constructor
    required this.tutorName,   // <-- Tambahkan di constructor
    required this.maxStudents,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id, 
    name, 
    description, 
    subjectName, 
    tutorName, 
    maxStudents, 
    isActive
  ];
}