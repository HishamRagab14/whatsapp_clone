import 'package:get/get.dart';
import 'package:whatsapp_clone/core/repositories/chat_repository.dart';
import 'package:whatsapp_clone/core/services/audio_player_service.dart';
import 'package:whatsapp_clone/core/services/voice_recorder_service.dart';
import 'package:whatsapp_clone/view_model/controllers/chat_detail_controller.dart';

class ChatDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Register Services
    Get.lazyPut<ChatRepository>(() => ChatRepository());
    Get.lazyPut<VoiceRecorderService>(() => VoiceRecorderService());
    Get.lazyPut<AudioPlayerService>(() => AudioPlayerService());
    
    // Register Controller with dependencies
    Get.lazyPut<ChatDetailController>(
      () => ChatDetailController(
        receiverId: Get.arguments['receiverId'] ?? '',
        chatRepository: Get.find<ChatRepository>(),
        voiceRecorderService: Get.find<VoiceRecorderService>(),
        audioPlayerService: Get.find<AudioPlayerService>(),
      ),
      tag: Get.arguments['receiverId'] ?? '',
    );
  }
} 