import '../../domain/entities/class_entity.dart';

class ClassModel extends ClassEntity {
  const ClassModel({
    required super.id,
    required super.name,
    required super.description,
    required super.subjectName,
    required super.tutorName,
    required super.maxStudents,
    required super.isActive,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Tanpa Nama',
      description: json['description'] ?? '',
      // Mengambil data nested dari relasi Supabase
      // subjects: { name: "Matematika" }
      subjectName: (json['subjects'] != null) 
          ? json['subjects']['name'] 
          : 'Umum',
      // tutor: { full_name: "Budi Santoso" }
      tutorName: (json['tutor'] != null) 
          ? json['tutor']['full_name'] 
          : 'Admin', 
      maxStudents: json['max_students'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      // Kita tidak simpan subjectName/tutorName saat create, 
      // tapi pakai ID (logic ada di Service)
      'max_students': maxStudents,
      'is_active': isActive,
    };
  }
}