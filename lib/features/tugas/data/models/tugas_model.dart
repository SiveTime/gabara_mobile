import 'package:intl/intl.dart';

class TugasModel {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String kelas;
  final bool isSubmitted;

  TugasModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.kelas,
    required this.isSubmitted,
  });

  // convert ke entity
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'kelas': kelas,
        'isSubmitted': isSubmitted,
      };

  factory TugasModel.fromMap(Map<String, dynamic> map) {
    return TugasModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      deadline: DateTime.parse(map['deadline']),
      kelas: map['kelas'] ?? '',
      isSubmitted: map['isSubmitted'] ?? false,
    );
  }

  String get deadlineFormatted => DateFormat('dd MMM yyyy').format(deadline);
}
