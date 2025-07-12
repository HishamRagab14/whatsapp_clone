import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:whatsapp_clone/core/widgets/status/status_icon_button.dart';

class AddStatusBottomSheet extends StatelessWidget {
  final List<AssetEntity> photos;
  final void Function(BuildContext) onAddText;
  final void Function(BuildContext) onAddVoice;
  final void Function(BuildContext) onAddCamera;
  final void Function(BuildContext, AssetEntity) onAddGallery;

  const AddStatusBottomSheet({
    super.key,
    required this.photos,
    required this.onAddText,
    required this.onAddVoice,
    required this.onAddCamera,
    required this.onAddGallery,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              children: [
                // Icons Row
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StatusIconButton(
                        icon: Icons.edit,
                        label: 'Text',
                        onTap: () => onAddText(context),
                      ),
                      StatusIconButton(
                        icon: Icons.mic,
                        label: 'Voice',
                        onTap: () => onAddVoice(context),
                      ),
                      StatusIconButton(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onTap: () => onAddCamera(context),
                      ),
                      StatusIconButton(
                        icon: Icons.photo,
                        label: 'Gallery',
                        onTap: () {}, // Gallery handled by grid below
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Gallery Title
                Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Gallery',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Gallery Grid - Scrollable
                Expanded(
                  child: photos.isEmpty
                      ? const Center(child: Text('No images found'))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<Uint8List?>(
                              future: photos[index].thumbnailDataWithSize(const ThumbnailSize(200, 200)),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  );
                                }
                                return GestureDetector(
                                  onTap: () => onAddGallery(context, photos[index]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add a new status',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 