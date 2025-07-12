import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/core/widgets/custom_chat_detail_app_bar.dart';
import 'package:whatsapp_clone/core/widgets/chat/message_list_builder.dart';
import 'package:whatsapp_clone/core/widgets/chat/message_input_field.dart';
import 'package:whatsapp_clone/view_model/controllers/chat_detail_controller.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.receiverId,
  });
  final String name;
  final String imageUrl;
  final String receiverId;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final ChatDetailController controller;
  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ChatDetailController(receiverId: widget.receiverId),
      tag: widget.receiverId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomChatDetailAppBar(
        imageUrl: widget.imageUrl,
        name: widget.name,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/chatbackground.jpg'),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final messages = controller.messages;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start a conversation!'),
                  );
                }

                return MessageListBuilder(
                  messages: messages,
                  userImageUrl: widget.imageUrl,
                  controller: controller,
                );
              }),
            ),
            MessageInputField(controller: controller),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete(tag: widget.receiverId);
    super.dispose();
  }


  // دالة مشاركة الصورة

  // دالة نسخ رابط الصورة
}

// class _AttachmentIcon extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback? onTap;
//   const _AttachmentIcon({required this.icon, required this.label, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: onTap != null ? Colors.blueGrey[50] : Colors.grey[200],
//             child: Icon(icon, color: onTap != null ? Colors.blueGrey : Colors.grey, size: 26),
//           ),
//           SizedBox(height: 6),
//           Text(
//             label,
//             style: TextStyle(fontSize: 12, color: onTap != null ? Colors.black87 : Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
// }


