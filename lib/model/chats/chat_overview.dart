import 'package:intl/intl.dart';

class ChatOverview {
  final String peerId;
  final String peerName;
  final String peerImage;
  final String lastMessage;
  final DateTime lastTimestamp;
  final int unreadCount;
  final String messageType;

  ChatOverview({
    required this.peerId,
    required this.peerName,
    required this.peerImage,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.unreadCount,
    this.messageType = 'text',
  });

  // تنسيق الوقت للعرض
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(lastTimestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd').format(lastTimestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // تنسيق الرسالة الأخيرة
  String get formattedLastMessage {
    if (messageType == 'voice') {
      return '🎤 Voice Message';
    }
    return lastMessage;
  }

  factory ChatOverview.fromDoc(
    Map<String, dynamic> data,
    String docId,
    String currentUserId,
  ) {
    final users = List<String>.from(data['users']);
    final peerId = users.firstWhere((id) => id != currentUserId);

    DateTime lastTimestamp;
    if (data['lastMessageTime'] != null) {
      lastTimestamp = (data['lastMessageTime'] as dynamic).toDate();
    } else {
      lastTimestamp = DateTime.now();
    }

    return ChatOverview(
      peerId: peerId,
      peerName: data['peerName'] ?? 'Unknown',
      peerImage: data['peerImage'] ?? 'assets/images/profile2.png',
      lastMessage: data['lastMessage'] ?? '',
      lastTimestamp: lastTimestamp,
      unreadCount: data['unreadCount'] ?? 0,
      messageType: data['lastMessageType'] ?? 'text',
    );
  }
}
