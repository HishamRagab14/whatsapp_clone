import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/core/widgets/chat/attachment_icon.dart';
import 'package:whatsapp_clone/view_model/controllers/chat_detail_controller.dart';

class AttachmentBottomSheet extends StatelessWidget {
  final ChatDetailController controller;
  
  const AttachmentBottomSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AttachmentIcon(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    controller.sendImageMessage(ImageSource.camera);
                  },
                ),
                AttachmentIcon(
                  icon: Icons.photo,
                  label: 'Images',
                  onTap: () {
                    Navigator.pop(context);
                    controller.sendImageMessage(ImageSource.gallery);
                  },
                ),
                AttachmentIcon(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  onTap: null, // TODO: Implement document functionality
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AttachmentIcon(
                  icon: Icons.poll,
                  label: 'Poll',
                  onTap: null, // TODO: Implement poll functionality
                ),
                AttachmentIcon(
                  icon: Icons.location_on,
                  label: 'Location',
                  onTap: null, // TODO: Implement location functionality
                ),
                AttachmentIcon(
                  icon: Icons.person,
                  label: 'Contact',
                  onTap: null, // TODO: Implement contact functionality
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
} 