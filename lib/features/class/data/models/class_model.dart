class ClassModel {
  final String id;
  final String name;
  final String description;
  final String tutorName;
  final int studentCount;

  ClassModel({
    required this.id,
    required this.name,
    required this.description,
    required this.tutorName,
    required this.studentCount,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tutorName: json['tutor_name'] ?? '',
      studentCount: json['student_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tutor_name': tutorName,
      'student_count': studentCount,
    };
  }
}
