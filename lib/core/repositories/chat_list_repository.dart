import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_clone/model/chats/chat_overview.dart';

class ChatListRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<List<ChatOverview>> getChatsOverviewsStream(String currentUserId) {
    return _firebaseFirestore
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          List<ChatOverview> chatOverviews = [];

          for (final doc in snap.docs) {
            try {
              final data = doc.data();
              final chatOverview = await _buildChatOverview(
                data,
                doc.id,
                currentUserId,
              );
              if (chatOverview != null) {
                chatOverviews.add(chatOverview);
              }
            } catch (e) {
              // No print statements here
            }
          }

          return chatOverviews;
        });
  }

  Future<ChatOverview?> _buildChatOverview(
    Map<String, dynamic> data,
    String docId,
    String currentUserId,
  ) async {
    try {
      final users = List<String>.from(data['users']);
      final peerId = users.firstWhere((id) => id != currentUserId);

      // الحصول على معلومات المستخدم الآخر
      final userDoc =
          await _firebaseFirestore.collection('users').doc(peerId).get();
      String peerName = 'Unknown';
      String peerImage = 'assets/images/profile2.png';

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        peerName = userData['userName'] ?? userData['name'] ?? userData['displayName'] ?? 'Unknown';
        peerImage = userData['profileImageUrl'] ?? userData['photoURL'] ?? 'assets/images/profile2.png';
        
      } 

      // التحقق من وجود timestamp
      DateTime lastTimestamp;
      if (data['lastMessageTime'] != null) {
        lastTimestamp = (data['lastMessageTime'] as Timestamp).toDate();
      } else {
        lastTimestamp = DateTime.now();
      }

      return ChatOverview(
        peerId: peerId,
        peerName: peerName,
        peerImage: peerImage,
        lastMessage: data['lastMessage'] ?? '',
        lastTimestamp: lastTimestamp,
        unreadCount: data['unreadCount'] ?? 0,
      );
    } catch (e) {
      // print('❌ Error building chat overview: $e');
      return null;
    }
  }
}
