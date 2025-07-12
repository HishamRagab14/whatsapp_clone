import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/model/chats/chat_overview.dart';
import 'package:whatsapp_clone/view/chats/chats_list_view.dart';
import 'package:whatsapp_clone/view_model/controllers/chat_list_controller.dart';
import 'package:whatsapp_clone/core/widgets/chat_shimmer.dart';

class ChatListContent extends StatelessWidget {
  const ChatListContent({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final ChatListController controller = Get.find<ChatListController>();
    
    return Obx(() {
      final allChats = controller.chats;
      
      if (allChats.isEmpty) {
        return const ChatShimmer();
      }
      
      final List<ChatOverview> filteredChats = _filterChats(allChats, searchQuery);
      
      return ChatsListView(filteredChats: filteredChats);
    });
  }

  List<ChatOverview> _filterChats(List<ChatOverview> allChats, String query) {
    if (query.isEmpty) {
      return allChats;
    }
    
    return allChats
        .where((chat) => 
            chat.lastMessage.toLowerCase().contains(query.toLowerCase()) ||
            chat.peerName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
} 