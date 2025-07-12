import 'package:flutter/material.dart';
import 'package:whatsapp_clone/model/chats/chat_overview.dart';
import 'package:whatsapp_clone/view/chats/chat_item.dart';

class ChatsListView extends StatelessWidget {
  const ChatsListView({super.key, required this.filteredChats});

  final List<ChatOverview> filteredChats;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return ChatItem(chat: chat);
      },
    );
  }
}
