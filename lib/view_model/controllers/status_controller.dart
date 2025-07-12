import 'package:get/get.dart';
import 'package:whatsapp_clone/model/status/status_model.dart';
import 'package:whatsapp_clone/core/interfaces/status_repository_interface.dart';

class StatusController extends GetxController {
  final IStatusRepository repository;
  final String currentUserId;

  StatusController({required this.repository, required this.currentUserId});

  List<StatusModel> myStatuses = [];
  List<StatusModel> recentStatuses = [];
  List<StatusModel> viewedStatuses = [];
  bool isLoading = false;
  Map<String, List<StatusModel>> groupedStatusesByUser = {};

  @override
  void onInit() {
    super.onInit();
    loadStatuses();
  }

  Future<void> loadStatuses() async {
    try {
      isLoading = true;
      update();

      final allStatuses = await repository.fetchAllStatuses(currentUserId);
      final now = DateTime.now();
      for (final status in allStatuses) {
        print('DEBUG: statusId=${status.id}, userId=${status.userId}, timestamp=${status.timestamp}, diff=${now.difference(status.timestamp).inHours}h');
      }
      // فلترة الحالات الأقدم من 24 ساعة
      final filtered = allStatuses.where((status) => now.difference(status.timestamp).inHours < 24).toList();
      print('DEBUG: filtered statuses count = ${filtered.length}');
      for (final status in filtered) {
        print('DEBUG: FILTERED statusId=${status.id}, userId=${status.userId}, timestamp=${status.timestamp}, diff=${now.difference(status.timestamp).inHours}h');
      }
      // تجميع الحالات حسب userId
      groupedStatusesByUser = {};
      for (final status in filtered) {
        groupedStatusesByUser.putIfAbsent(status.userId, () => []).add(status);
      }
      // تحديث myStatuses
      myStatuses = groupedStatusesByUser[currentUserId] ?? [];
      print('DEBUG: myStatuses count = ${myStatuses.length}');
      for (final status in myStatuses) {
        print('DEBUG: MYSTATUS statusId=${status.id}, timestamp=${status.timestamp}, diff=${now.difference(status.timestamp).inHours}h');
      }
      // تحديث recentStatuses: المستخدمين الآخرين الذين لم تُشاهد حالاتهم
      recentStatuses = groupedStatusesByUser.entries
        .where((e) => e.key != currentUserId && e.value.any((s) => !s.seenBy.contains(currentUserId)))
        .map((e) => e.value.first)
        .toList();
      // تحديث viewedStatuses: المستخدمين الآخرين الذين شاهدت حالاتهم
      viewedStatuses = groupedStatusesByUser.entries
        .where((e) => e.key != currentUserId && e.value.every((s) => s.seenBy.contains(currentUserId)))
        .map((e) => e.value.first)
        .toList();

      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
      Get.snackbar('Error', 'Failed to load statuses: $e');
    }
  }

  // Upload Methods
  Future<void> uploadTextStatus(String text) async {
    try {
      await repository.uploadTextStatus(text);
      await loadStatuses();
      Get.snackbar('Success', 'Text status uploaded successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload text status: $e');
    }
  }

  Future<void> uploadImageStatus(String imagePath) async {
    try {
      await repository.uploadImageStatus(imagePath);
      await loadStatuses();
      Get.snackbar('Success', 'Image status uploaded successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image status: $e');
    }
  }

  Future<void> uploadAudioStatus(String audioPath) async {
    try {
      await repository.uploadAudioStatus(audioPath);
      await loadStatuses();
      Get.snackbar('Success', 'Audio status uploaded successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload audio status: $e');
    }
  }

  Future<void> uploadCameraStatus(String imagePath) async {
    try {
      await repository.uploadCameraStatus(imagePath);
      await loadStatuses();
      Get.snackbar('Success', 'Camera status uploaded successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload camera status: $e');
    }
  }

  // View Methods
  Future<void> markStatusAsSeen(String statusId) async {
    try {
      await repository.markStatusAsSeen(statusId, currentUserId);
      await loadStatuses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark status as seen: $e');
    }
  }

  // Delete Methods
  Future<void> deleteStatus(String statusId) async {
    try {
      await repository.deleteStatus(statusId);
      await loadStatuses();
      Get.snackbar('Success', 'Status deleted successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete status: $e');
    }
  }

  // Helper Methods
  bool isMyStatus(StatusModel status) {
    return status.userId == currentUserId;
  }

  bool isStatusSeen(StatusModel status) {
    return status.seenBy.contains(currentUserId);
  }

  String getStatusTimeAgo(StatusModel status) {
    final now = DateTime.now();
    final difference = now.difference(status.timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 