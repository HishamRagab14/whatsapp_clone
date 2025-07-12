import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/core/utils/time_formatter.dart';
import 'package:whatsapp_clone/core/widgets/chat/image_message_bubble.dart';
import 'package:whatsapp_clone/core/widgets/message_date_divider.dart';
import 'package:whatsapp_clone/core/widgets/text_message_bubble.dart';
import 'package:whatsapp_clone/core/widgets/voice_message_bubble.dart';
import 'package:whatsapp_clone/view_model/controllers/chat_detail_controller.dart';

class MessageListBuilder extends StatelessWidget {
  final List<SimpleChatMessage> messages;
  final String userImageUrl;
  final ChatDetailController controller;
  
  const MessageListBuilder({
    super.key,
    required this.messages,
    required this.userImageUrl,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.only(top: 10),
      itemCount: _buildMessageList().length,
      itemBuilder: (context, index) {
        return _buildMessageList()[index];
      },
    );
  }

  List<Widget> _buildMessageList() {
    final List<Widget> widgets = [];
    DateTime? lastMessageDate;

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final messageDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );

      if (lastMessageDate == null || messageDate != lastMessageDate) {
        widgets.add(MessageDateDivider(date: message.timestamp));
        lastMessageDate = messageDate;
      }

      widgets.add(_buildMessageWidget(message));
    }

    return widgets;
  }

  Widget _buildMessageWidget(SimpleChatMessage message) {
    final messageTime = TimeFormatter.formatMessageTime(message.timestamp);

    switch (message.type) {
      case 'voice':
        return _buildVoiceMessage(message, messageTime);
      case 'image':
        return _buildImageMessage(message, messageTime);
      default:
        return _buildTextMessage(message, messageTime);
    }
  }

  Widget _buildVoiceMessage(SimpleChatMessage message, String messageTime) {
    if (message.isUploading) {
      return VoiceMessageBubble(
        isMe: message.isMe,
        isUploading: true,
        userImageUrl: userImageUrl,
        messageTime: messageTime,
        currentTime: controller.recordingDuration.value,
        onTap: null,
      );
    } else if (message.audioUrl != null) {
      return Obx(() {
        final isCurrentlyPlaying = controller.isMessagePlaying(message.audioUrl!);
        final progress = controller.getMessageProgress(message.audioUrl!);
        final currentTime = controller.getMessageCurrentTime(message.audioUrl!);
        final totalDuration = controller.audioDurations[message.audioUrl!] ??
            controller.getMessageTotalDuration(message.audioUrl!);
        
        return VoiceMessageBubble(
          isMe: message.isMe,
          audioUrl: message.audioUrl!,
          userImageUrl: userImageUrl,
          messageTime: messageTime,
          progress: progress,
          currentTime: currentTime,
          duration: totalDuration,
          isPlaying: isCurrentlyPlaying,
          onTap: () => _handleVoiceMessageTap(message.audioUrl!),
          onSeek: (progress) => controller.seekVoiceMessage(progress, message.audioUrl!),
        );
      });
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildImageMessage(SimpleChatMessage message, String messageTime) {
    if (message.imageUrl != null) {
      return ImageMessageBubble(
        imageUrl: message.imageUrl!,
        isMe: message.isMe,
        userImageUrl: userImageUrl,
        messageTime: messageTime,
        controller: controller,
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildTextMessage(SimpleChatMessage message, String messageTime) {
    return TextMessageBubble(
      isMe: message.isMe,
      text: message.text,
      messageTime: messageTime,
    );
  }

  Future<void> _handleVoiceMessageTap(String audioUrl) async {
    try {
      if (!controller.audioDurations.containsKey(audioUrl)) {
        await controller.fetchAndCacheAudioDuration(audioUrl);
      }
      await controller.toggleVoiceMessagePlayback(audioUrl);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to play voice message',
        duration: const Duration(seconds: 2),
      );
    }
  }
} 