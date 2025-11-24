class ChatModel {
  final int id;
  final int partnerId;
  final String partnerName;
  final String? partnerImage;
  final bool isPartnerOnline;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int? unreadCount;
  final bool isActive;

  ChatModel({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    this.partnerImage,
    required this.isPartnerOnline,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount,
    required this.isActive,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as int,
      partnerId: json['partnerId'] as int,
      partnerName: json['partnerName'] as String,
      partnerImage: json['partnerImage'] as String?,
      isPartnerOnline: json['isPartnerOnline'] as bool? ?? false,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  ChatModel copyWith({
    int? id,
    int? partnerId,
    String? partnerName,
    String? partnerImage,
    bool? isPartnerOnline,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isActive,
  }) {
    return ChatModel(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      partnerImage: partnerImage ?? this.partnerImage,
      isPartnerOnline: isPartnerOnline ?? this.isPartnerOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
