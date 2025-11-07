import 'user_model.dart';

class LoginResponse {
  final String token;
  final String type;
  final UserModel user;

  LoginResponse({required this.token, required this.type, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      type: json['type'] as String? ?? 'Bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
