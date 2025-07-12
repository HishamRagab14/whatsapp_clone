import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/constants.dart';

class TextMessageBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final String messageTime;

  const TextMessageBubble({
    super.key,
    required this.isMe,
    required this.text,
    required this.messageTime,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 60 : 8,
          right: isMe ? 8 : 60,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // فقاعة الرسالة النصية
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? kMyMessageBubbleColor : kOtherMessageBubbleColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                text,
                style: TextStyle(
                  // color: isMe ? Colors.white : Colors.black87,
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            if (isMe) ...[
              // أيقونات الحالة للرسائل المرسلة مني
              SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.done_all, size: 16, color: Colors.blue),
                  Text(
                    messageTime,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
