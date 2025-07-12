import 'package:flutter/material.dart';

Widget messageInputField() {
  final TextEditingController messageController = TextEditingController();
  return Row(
    children: [
      IconButton(
        onPressed: () {
          // print('Attachment button pressed');
        },
        icon: Icon(Icons.add, color: Colors.grey[600]),
      ),
      TextField(
        controller: messageController,
        decoration: InputDecoration(border: InputBorder.none),
      ),
    ],
  );
}
