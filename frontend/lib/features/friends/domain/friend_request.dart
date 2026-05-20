import 'friend_user.dart';

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.sender,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final FriendUser sender;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    final senderJson = json['sender'];
    final senderId = json['sender_id'] as String? ?? '';
    return FriendRequest(
      id: json['id'] as String? ?? '',
      senderId: senderId,
      receiverId: json['receiver_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      sender: senderJson is Map<String, dynamic>
          ? FriendUser.fromJson(senderJson)
          : FriendUser(id: senderId, name: senderId),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }
}
