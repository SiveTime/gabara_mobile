class ProfileEntity {
  final String id;
  final String fullName;
  final String? phone;
  final String? gender;
  final String? birthDate;
  final String? address;
  final String? parentName;
  final String? parentPhone;
  final String? expertiseField;  // Bidang Keilmuan (Mentor)
  final String? occupation;      // Pekerjaan (Mentor)
  final String? avatarUrl;

  ProfileEntity({
    required this.id,
    required this.fullName,
    this.phone,
    this.gender,
    this.birthDate,
    this.address,
    this.parentName,
    this.parentPhone,
    this.expertiseField,
    this.occupation,
    this.avatarUrl,
  });
}
