class ClientSearchResult {
  final int id;
  final String fullName;
  final String phone;
  final String? email;
  final String? avatarUrl;

  ClientSearchResult({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
  });

  factory ClientSearchResult.fromJson(Map<String, dynamic> json) {
    return ClientSearchResult(
      id: (json['userId'] ?? json['id']) as int, // поддерживаем обе схемы
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
