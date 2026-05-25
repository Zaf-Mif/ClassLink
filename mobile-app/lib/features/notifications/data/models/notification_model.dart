class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type'] ?? '',
      referenceId: json['referenceId']?.toString(),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
