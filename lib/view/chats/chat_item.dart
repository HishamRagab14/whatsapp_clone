import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/model/chats/chat_overview.dart';
import 'package:whatsapp_clone/view/chats/chat_details/chat_detail_screen.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({super.key, required this.chat});
  final ChatOverview chat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage:
              chat.peerImage.startsWith('http')
                  ? NetworkImage(chat.peerImage)
                  : AssetImage(chat.peerImage) as ImageProvider,
          onBackgroundImageError: (exception, stackTrace) {
            // print('❌ Error loading profile image: $exception');
          },
        ),
        title: Text(
          chat.peerName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Row(
          children: [
            if (chat.messageType == 'voice') ...[
              Icon(Icons.mic, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                chat.formattedLastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: chat.unreadCount > 0 ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chat.formattedTime,
              style: TextStyle(
                fontSize: 12,
                color: chat.unreadCount > 0 ? Colors.green : Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            if (chat.unreadCount > 0)
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chat.unreadCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        onTap: () {
          Get.to(
            () => ChatDetailScreen(
              name: chat.peerName,
              imageUrl: chat.peerImage,
              receiverId: chat.peerId,
            ),
          );
        },
      ),
    );
  }
}
