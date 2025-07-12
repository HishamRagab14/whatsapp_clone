import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/core/constants.dart';
import 'package:whatsapp_clone/core/widgets/chat/attachment_bottom_sheet.dart';
import 'package:whatsapp_clone/view_model/controllers/chat_detail_controller.dart';

class MessageInputField extends StatelessWidget {
  final ChatDetailController controller;
  
  const MessageInputField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildAttachmentButton(context),
          Expanded(child: _buildTextField()),
          _buildCameraButton(),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showAttachmentBottomSheet(context),
      icon: Icon(Icons.add, color: Colors.grey[600], size: 22),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 1,
            color: Colors.black12,
          ),
        ],
      ),
      child: TextField(
        controller: controller.messageInputController,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          suffixIcon: IconButton(
            onPressed: () {
            },
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.sticky_note_2_outlined,
              color: Colors.grey[700],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return IconButton(
      icon: Icon(
        Icons.camera_alt_outlined,
        color: Colors.grey[700],
        size: 20,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () => controller.sendImageMessage(ImageSource.camera),
    );
  }

  Widget _buildActionButton() {
    return Obx(() {
      if (controller.isUploadingImage.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      
      if (controller.isRecording.value) {
        return IconButton(
          onPressed: () => controller.stopRecording(),
          icon: const Icon(Icons.stop, color: Colors.red, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        );
      }
      
      if (controller.isTyping.value) {
        return IconButton(
          icon: const Icon(Icons.send, size: 20),
          color: kLightPrimaryColor,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => controller.sendMessage(),
        );
      } else {
        return IconButton(
          icon: Icon(
            Icons.mic_none_outlined,
            color: Colors.grey[700],
            size: 20,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => controller.startVoiceRecording(),
        );
      }
    });
  }

  void _showAttachmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AttachmentBottomSheet(controller: controller),
    );
  }
} 