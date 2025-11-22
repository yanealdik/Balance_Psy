class PsychologistModel {
  final int id;
  final int userId;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String specialization;
  final int experienceYears;
  final String bio;
  final List<String> approaches;
  final String education;
  final String? certificateUrl;
  final double hourlyRate; // ✅ ИСПРАВЛЕНО: было sessionPrice
  final double rating;
  final int reviewsCount;
  final int totalSessions;
  final bool isAvailable;
  final bool isVerified;
  final String verificationStatus;
  final String? createdAt;

  PsychologistModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
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
    required this.verificationStatus,
    this.createdAt,
  });

  factory PsychologistModel.fromJson(Map<String, dynamic> json) {
    return PsychologistModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      specialization: json['specialization'] as String,
      experienceYears: json['experienceYears'] as int,
      bio: json['bio'] as String,
      approaches: (json['approaches'] as List<dynamic>).cast<String>(),
      education: json['education'] as String,
      certificateUrl: json['certificateUrl'] as String?,
      hourlyRate: (json['hourlyRate'] as num).toDouble(), // ✅ ИСПРАВЛЕНО
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviewsCount'] as int,
      totalSessions: json['totalSessions'] as int,
      isAvailable: json['isAvailable'] as bool,
      isVerified: json['isVerified'] as bool,
      verificationStatus: json['verificationStatus'] as String,
      createdAt: json['createdAt'] as String?,
    );
  }
}
