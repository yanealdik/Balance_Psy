class ProfileResponse {
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
  final String? createdAt;
  final String? lastLogin;
  final PsychologistProfileData? psychologistProfile;

  ProfileResponse({
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
    this.createdAt,
    this.lastLogin,
    this.psychologistProfile,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
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
      createdAt: json['createdAt'] as String?,
      lastLogin: json['lastLogin'] as String?,
      psychologistProfile: json['psychologistProfile'] != null
          ? PsychologistProfileData.fromJson(json['psychologistProfile'])
          : null,
    );
  }
}

class PsychologistProfileData {
  final int profileId;
  final String specialization;
  final int experienceYears;
  final String bio;
  final List<String> approaches;
  final String education;
  final String? certificateUrl;
  final double hourlyRate;
  final double rating;
  final int reviewsCount;
  final int totalSessions;
  final bool isAvailable;
  final bool isVerified;

  PsychologistProfileData({
    required this.profileId,
    required this.specialization,
    required this.experienceYears,
    required this.bio,
    required this.approaches,
    required this.education,
    this.certificateUrl,
    required this.hourlyRate,
    required this.rating,
    required this.reviewsCount,
    required this.totalSessions,
    required this.isAvailable,
    required this.isVerified,
  });

  factory PsychologistProfileData.fromJson(Map<String, dynamic> json) {
    // ✅ ИСПРАВЛЕНО: Безопасное извлечение данных с проверкой на null
    return PsychologistProfileData(
      profileId: json['profileId'] as int,
      specialization: json['specialization'] as String? ?? '',
      experienceYears: json['experienceYears'] as int? ?? 0,
      bio: json['bio'] as String? ?? '',
      approaches: (json['approaches'] as List?)?.cast<String>() ?? [],
      education: json['education'] as String? ?? '',
      certificateUrl: json['certificateUrl'] as String?,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      totalSessions: json['totalSessions'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}
