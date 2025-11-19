class UserModel {
  final int userId;
  final String email;
  final String fullName;
  final String? phone;
  final String? dateOfBirth;
  final String? avatarUrl;
  final String role;
  final String? gender;
  final List<String>? interests;
  final String? registrationGoal;
  final bool isActive;
  final bool emailVerified;

  UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.phone,
    this.dateOfBirth,
    this.avatarUrl,
    required this.role,
    this.gender,
    this.interests,
    this.registrationGoal,
    required this.isActive,
    required this.emailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String,
      gender: json['gender'] as String?,
      interests: (json['interests'] as List?)?.cast<String>(),
      registrationGoal: json['registrationGoal'] as String?,
      isActive: json['isActive'] as bool,
      emailVerified: json['emailVerified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'avatarUrl': avatarUrl,
      'role': role,
      'gender': gender,
      'interests': interests,
      'registrationGoal': registrationGoal,
      'isActive': isActive,
      'emailVerified': emailVerified,
    };
  }
}
