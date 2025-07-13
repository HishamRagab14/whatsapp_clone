import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/state_manager.dart';
import 'package:whatsapp_clone/core/repositories/chat_list_repository.dart';
import 'package:whatsapp_clone/model/chats/chat_overview.dart';

class ChatListController extends GetxController {
  final ChatListRepository _repo = ChatListRepository();
  final RxList<ChatOverview> chats = <ChatOverview>[].obs;

  late final String currentUserId;
  StreamSubscription? _chatStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _setupChatStream();
  }

  void _setupChatStream() {
    _chatStreamSubscription?.cancel();
    _chatStreamSubscription = _repo.getChatsOverviewsStream(currentUserId).listen((list) {
      chats.value = list;
    });
  }

  @override
  void onClose() {
    _chatStreamSubscription?.cancel();
    super.onClose();
  }
}
