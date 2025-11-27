import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.id,
    required super.fullName,
    super.phone,
    super.gender,
    super.birthDate,
    super.address,
    super.parentName,
    super.parentPhone,
    super.expertiseField,
    super.occupation,
    super.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      address: json['address'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      expertiseField: json['expertise_field'],
      occupation: json['occupation'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate,
      'address': address,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'expertise_field': expertiseField,
      'occupation': occupation,
      'avatar_url': avatarUrl,
    };
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      fullName: fullName,
      phone: phone,
      gender: gender,
      birthDate: birthDate,
      address: address,
      parentName: parentName,
      parentPhone: parentPhone,
      expertiseField: expertiseField,
      occupation: occupation,
      avatarUrl: avatarUrl,
    );
  }
}
