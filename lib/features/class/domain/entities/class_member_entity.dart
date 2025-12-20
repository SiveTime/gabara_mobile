class ClassMemberEntity {
  final String id;
  final String userId;
  final String classId;
  final String fullName;
  final String email;
  final String? profilePicture;
  final DateTime joinedAt;
  final String role; // 'student' or 'mentor'

  ClassMemberEntity({
    required this.id,
    required this.userId,
    required this.classId,
    required this.fullName,
    required this.email,
    this.profilePicture,
    required this.joinedAt,
    required this.role,
  });

  // Generate initials from full name
  String get initials {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return 'U';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }
}
