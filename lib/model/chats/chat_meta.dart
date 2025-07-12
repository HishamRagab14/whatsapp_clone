import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMeta {
  final String chatId;
  final String otherUserId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastSenderId;

  ChatMeta({
    required this.chatId,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderId,
  });

  factory ChatMeta.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // نفترض users مخزنة كـ array of IDs
    final users = List<String>.from(data['users'] as List);
    final otherId = users.firstWhere((id) => id != currentUserId);

    return ChatMeta(
      chatId: doc.id,
      otherUserId: otherId,
      lastMessage: data['lastMessage'] as String,
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastSenderId: data['lastSenderId'] as String,
    );
  }
}
