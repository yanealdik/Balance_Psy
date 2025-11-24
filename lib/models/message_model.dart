class MessageModel {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String senderName;
  final String? senderImage;
  final String text;
  final String type;
  final String? attachmentUrl;
  final String? attachmentType;
  final String? attachmentName;
  final int? attachmentSize;
  final int? voiceDuration;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.text,
    required this.type,
    this.attachmentUrl,
    this.attachmentType,
    this.attachmentName,
    this.attachmentSize,
    this.voiceDuration,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      chatRoomId: json['chatRoomId'] as int,
      senderId: json['senderId'] as int,
      senderName: json['senderName'] as String,
      senderImage: json['senderImage'] as String?,
      text: json['text'] as String,
      type: json['type'] as String,
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentType: json['attachmentType'] as String?,
      attachmentName: json['attachmentName'] as String?,
      attachmentSize: json['attachmentSize'] as int?,
      voiceDuration: json['voiceDuration'] as int?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }
}
