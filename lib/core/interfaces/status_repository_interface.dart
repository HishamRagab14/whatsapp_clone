import 'package:whatsapp_clone/model/status/status_model.dart';

abstract class IStatusRepository {
  // Upload Methods
  Future<void> uploadTextStatus(String text);
  Future<void> uploadImageStatus(String imagePath);
  Future<void> uploadAudioStatus(String audioPath);
  Future<void> uploadCameraStatus(String imagePath);
  
  // Fetch Methods
  Future<List<StatusModel>> fetchAllStatuses(String currentUserId);
  Future<List<StatusModel>> fetchMyStatuses(String currentUserId);
  Future<List<StatusModel>> fetchRecentStatuses(String currentUserId);
  Future<List<StatusModel>> fetchViewedStatuses(String currentUserId);
  
  // Update Methods
  Future<void> markStatusAsSeen(String statusId, String userId);
  
  // Delete Methods
  Future<void> deleteStatus(String statusId);
} 