import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:whatsapp_clone/core/widgets/status/my_status_section.dart';
import 'package:whatsapp_clone/core/widgets/status/recent_status_section.dart';
import 'package:whatsapp_clone/core/widgets/status/viewed_status_section.dart';
import 'package:whatsapp_clone/core/widgets/status/add_status_bottom_sheet.dart';
import 'package:whatsapp_clone/view_model/controllers/status_controller.dart';
import 'package:whatsapp_clone/model/status/status_model.dart';
import 'package:whatsapp_clone/core/services/firestore_user_service.dart';
import 'package:whatsapp_clone/model/users/user_model.dart';
import 'package:whatsapp_clone/core/widgets/status/status_text_dialog.dart';
import 'package:whatsapp_clone/core/widgets/status/status_viewer_screen.dart';
import 'package:whatsapp_clone/core/services/image_service.dart';
import 'package:whatsapp_clone/core/services/voice_recorder_service.dart';

class UpdatesScreen extends GetView<StatusController> {
  UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<UserModel?>(
        future: FirestoreUserService().getCurrentUser(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          return GetBuilder<StatusController>(
            builder: (controller) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    MyStatusSection(
                      myStatuses: controller.myStatuses,
                      onAddStatus: () => _showAddStatusOptions(context),
                      onViewStatus: _viewMyStatus,
                      onDeleteStatus: (statusId) => controller.deleteStatus(statusId),
                      userName: user?.userName,
                      profileImageUrl: user?.profileImageUrl,
                    ),
                    const SizedBox(height: 8),
                    RecentStatusSection(
                      recentStatuses: controller.recentStatuses,
                      groupedStatusesByUser: controller.groupedStatusesByUser,
                      onViewUserStatuses: (userId) => _viewUserStatuses(userId, controller),
                    ),
                    const SizedBox(height: 8),
                    ViewedStatusSection(
                      viewedStatuses: controller.viewedStatuses,
                      groupedStatusesByUser: controller.groupedStatusesByUser,
                      onViewUserStatuses: (userId) => _viewUserStatuses(userId, controller),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStatusOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> 
  _showAddStatusOptions(BuildContext context) async {
    // Request permission and get photos
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      Get.snackbar('Permission Denied', 'Gallery access is required to add a status.');
      return;
    }
    
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    final List<AssetEntity> photos = albums.isNotEmpty ? await albums[0].getAssetListPaged(page: 0, size: 60) : [];
    
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddStatusBottomSheet(
          photos: photos,
          onAddText: (ctx) {
            Navigator.pop(ctx);
            showDialog(
              context: context,
              builder: (_) => StatusTextDialog(
                onSend: (text) => controller.uploadTextStatus(text),
              ),
            );
          },
          onAddVoice: (ctx) {
            Navigator.pop(ctx);
            VoiceRecorderService().recordAudioStatus();
          },
          onAddCamera: (ctx) async {
            Navigator.pop(ctx);
            final image = await ImageService().takePhotoWithCamera();
            if (image != null) { controller.uploadCameraStatus(image.path); }
          },
          onAddGallery: (ctx, asset) {
            Navigator.pop(ctx);
            _addGalleryStatus(asset);
          },
        ),
      );
    }
  }

  void _addGalleryStatus(AssetEntity asset) async {
    try {
      final file = await asset.file;
      if (file != null) {
        await controller.uploadImageStatus(file.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
    }
  }

  void _viewMyStatus(StatusModel status) {
    final now = DateTime.now();
    if (now.difference(status.timestamp).inHours < 24) {
      Navigator.push(
        Get.context!,
        MaterialPageRoute(
          builder: (_) => StatusViewerScreen(
            statuses: [status],
            initialIndex: 0,
          ),
        ),
      );
    } else {
      Get.snackbar('Expired', 'This status is more than 24 hours old.');
    }
  }

  void _viewUserStatuses(String userId, StatusController controller) {
    final now = DateTime.now();
    final statuses = (controller.groupedStatusesByUser[userId] ?? [])
        .where((status) => now.difference(status.timestamp).inHours < 24)
        .toList();
    if (statuses.isNotEmpty) {
      Navigator.push(
        Get.context!,
        MaterialPageRoute(
          builder: (_) => StatusViewerScreen(
            statuses: statuses,
            initialIndex: 0,
          ),
        ),
      );
    } else {
      Get.snackbar('Expired', 'No statuses in the last 24 hours.');
    }
  }
}
