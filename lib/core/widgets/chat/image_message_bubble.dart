import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/constants.dart';
import 'package:whatsapp_clone/core/services/image_service.dart';
import 'package:whatsapp_clone/view_model/controllers/chat_detail_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageMessageBubble extends StatelessWidget {
  final String imageUrl;
  final bool isMe;
  final String userImageUrl;
  final String messageTime;
  final ChatDetailController controller;
  
  const ImageMessageBubble({
    super.key,
    required this.imageUrl,
    required this.isMe,
    required this.userImageUrl,
    required this.messageTime,
    required this.controller,
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isMe ? kMyMessageBubbleColor : kOtherMessageBubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: GestureDetector(
          onTap: () => _showImageDialog(context),
          onLongPress: () => _showImageOptions(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 180,
              height: 180,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    final imageService = ImageService();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download, color: Colors.blue),
                title: const Text('Download Image'),
                onTap: () async {
                  Navigator.pop(context);
                  await imageService.downloadImage(imageUrl);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Share Image'),
                onTap: () async {
                  Navigator.pop(context);
                  await imageService.shareImage(imageUrl);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.orange),
                title: const Text('Copy Image URL'),
                onTap: () {
                  Navigator.pop(context);
                  imageService.copyImageUrl(imageUrl);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 