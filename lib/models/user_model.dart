class UserModel {
  final int userId;
  final String email;
  final String fullName;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final String role;
  final String? gender;
  final Set<String>? interests;
  final String? registrationGoal;
  final bool isActive;
  final bool emailVerified;
  final DateTime? createdAt;

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
    this.isActive = true,
    this.emailVerified = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // ✅ ИСПРАВЛЕНО: Обработка dateOfBirth (массив или строка)
    DateTime? dateOfBirth;
    if (json['dateOfBirth'] != null) {
      if (json['dateOfBirth'] is String) {
        dateOfBirth = DateTime.parse(json['dateOfBirth']);
      } else if (json['dateOfBirth'] is List) {
        // Формат [year, month, day] из Java LocalDate
        final parts = json['dateOfBirth'] as List;
        dateOfBirth = DateTime(parts[0], parts[1], parts[2]);
      }
    }

    // ✅ ИСПРАВЛЕНО: Обработка createdAt
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is String) {
        createdAt = DateTime.parse(json['createdAt']);
      } else if (json['createdAt'] is List) {
        final parts = json['createdAt'] as List;
        createdAt = DateTime(
          parts[0],
          parts[1],
          parts[2],
          parts.length > 3 ? parts[3] : 0,
          parts.length > 4 ? parts[4] : 0,
          parts.length > 5 ? parts[5] : 0,
        );
      }
    }

    // ✅ ИСПРАВЛЕНО: Обработка avatarUrl (UUID → полный URL)
    String? avatarUrl = json['avatarUrl'] as String?;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (!avatarUrl.startsWith('http')) {
        // Если это UUID, формируем полный URL
        avatarUrl = 'http://localhost:8055/assets/$avatarUrl';
        print('⚠️ Fixed avatar URL in UserModel: $avatarUrl');
      }
    }

    return UserModel(
      userId: json['userId'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: dateOfBirth,
      avatarUrl: avatarUrl,
      role: json['role'] as String,
      gender: json['gender'] as String?,
      interests: json['interests'] != null
          ? Set<String>.from(json['interests'] as List)
          : null,
      registrationGoal: json['registrationGoal'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'role': role,
      'gender': gender,
      'interests': interests?.toList(),
      'registrationGoal': registrationGoal,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? userId,
    String? email,
    String? fullName,
    String? phone,
    DateTime? dateOfBirth,
    String? avatarUrl,
    String? role,
    String? gender,
    Set<String>? interests,
    String? registrationGoal,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      registrationGoal: registrationGoal ?? this.registrationGoal,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, email: $email, fullName: $fullName, avatarUrl: $avatarUrl)';
  }
}
