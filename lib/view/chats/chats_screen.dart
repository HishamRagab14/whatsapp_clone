import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/core/widgets/search_text_field.dart';
import 'package:whatsapp_clone/core/widgets/chat_list_content.dart';
import 'package:whatsapp_clone/view_model/controllers/chat_list_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatListController controller = Get.put(ChatListController());
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchTextField(
            onChanged: _onSearchChanged,
          ),
          Expanded(
            child: ChatListContent(
              searchQuery: searchQuery,
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
  }
}


// final List<Map<String, dynamic>> chats = [
  //   {
  //     'name': 'Hassan',
  //     'message': 'Hey, how are you?',
  //     'time': '4:00 PM',
  //     'unreadCount': 2,
  //     'imageUrl': 'assets/images/profile2.png',
  //   },
  //   {
  //     'name': 'Ahmed Ali',
  //     'message': 'Hi, I am Ahmed Ali',
  //     'time': '3:00 PM',
  //     'unreadCount': 0,
  //     'imageUrl': 'assets/images/profile2.png',
  //   },
  //   {
  //     'name': 'Hisham Ragab',
  //     'message': 'Hi, I am Hisham Ragab',
  //     'time': '2:00 PM',
  //     'unreadCount': 4,
  //     'imageUrl': 'assets/images/profile2.png',
  //   },
  // ];

  // List<Map<String, dynamic>> filteredChats =
    //     chats
    //         .where(
    //           (chat) => chat['message'].toLowerCase().contains(
    //             searchQuery.toLowerCase(),
    //           ),
    //         )
    //         .toList();