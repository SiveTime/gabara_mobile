class TugasEntity {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String kelas;
  final bool isSubmitted;

  const TugasEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.kelas,
    required this.isSubmitted,
  });
}
