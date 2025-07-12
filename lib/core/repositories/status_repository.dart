import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/core/interfaces/status_repository_interface.dart';
import 'package:whatsapp_clone/model/status/status_model.dart';

class StatusRepository implements IStatusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload Methods
  @override
  Future<void> uploadTextStatus(String text) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('🔍 Debug: User ID = ${user.uid}');
      print('🔍 Debug: User Name = ${user.displayName}');

      final statusId = const Uuid().v4();
      print('🔍 Debug: Status ID = $statusId');

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      
      final status = StatusModel(
        id: statusId,
        userId: user.uid,
        userName: userData?['userName'] ?? user.displayName ?? 'Unknown',
        profileImageUrl: userData?['profileImageUrl'] ?? user.photoURL,
        type: StatusType.text,
        text: text,
        timestamp: DateTime.now(),
        seenBy: [],
      );

      print('🔍 Debug: Status JSON = ${status.toJson()}');

      // Upload to statuses collection with server timestamp
      await _firestore
          .collection('statuses')
          .doc(statusId)
          .set({
            ...status.toJson(),
            'timestamp': FieldValue.serverTimestamp(),
          });
      
      print('✅ Debug: Status uploaded successfully to Firestore');
      
    } catch (e) {
      print('❌ Debug: Error uploading status = $e');
      Get.snackbar('Error', 'Failed to upload text status: $e');
      rethrow;
    }
  }

  @override
  Future<void> uploadImageStatus(String imagePath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final statusId = const Uuid().v4();
      final file = File(imagePath);
      
      // Upload to Firebase Storage
      final ref = _storage.ref().child('statuses/$statusId.jpg');
      await ref.putFile(file);
      final mediaUrl = await ref.getDownloadURL();

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      final status = StatusModel(
        id: statusId,
        userId: user.uid,
        userName: userData?['userName'] ?? user.displayName ?? 'Unknown',
        profileImageUrl: userData?['profileImageUrl'] ?? user.photoURL,
        type: StatusType.image,
        mediaUrl: mediaUrl,
        timestamp: DateTime.now(),
        seenBy: [],
      );

      await _firestore
          .collection('statuses')
          .doc(statusId)
          .set({
            ...status.toJson(),
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image status: $e');
      rethrow;
    }
  }

  @override
  Future<void> uploadAudioStatus(String audioPath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final statusId = const Uuid().v4();
      final file = File(audioPath);
      
      // Upload to Firebase Storage
      final ref = _storage.ref().child('statuses/$statusId.m4a');
      await ref.putFile(file);
      final mediaUrl = await ref.getDownloadURL();

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      final status = StatusModel(
        id: statusId,
        userId: user.uid,
        userName: userData?['userName'] ?? user.displayName ?? 'Unknown',
        profileImageUrl: userData?['profileImageUrl'] ?? user.photoURL,
        type: StatusType.audio,
        mediaUrl: mediaUrl,
        timestamp: DateTime.now(),
        seenBy: [],
      );

      await _firestore
          .collection('statuses')
          .doc(statusId)
          .set({
            ...status.toJson(),
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload audio status: $e');
      rethrow;
    }
  }

  @override
  Future<void> uploadCameraStatus(String imagePath) async {
    // نفس uploadImageStatus
    await uploadImageStatus(imagePath);
  }

  // Fetch Methods
  @override
  Future<List<StatusModel>> fetchAllStatuses(String currentUserId) async {
    try {
      final snapshot = await _firestore
          .collection('statuses')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StatusModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch statuses: $e');
      return [];
    }
  }

  @override
  Future<List<StatusModel>> fetchMyStatuses(String currentUserId) async {
    try {
      final snapshot = await _firestore
          .collection('statuses')
          .where('userId', isEqualTo: currentUserId)
          .get();

      final statuses = snapshot.docs
          .map((doc) => StatusModel.fromJson(doc.data()))
          .toList();
      
      // Sort in memory instead of using orderBy
      statuses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return statuses;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch my statuses: $e');
      return [];
    }
  }

  @override
  Future<List<StatusModel>> fetchRecentStatuses(String currentUserId) async {
    try {
      final allStatuses = await fetchAllStatuses(currentUserId);
      return allStatuses
          .where((status) => 
              status.userId != currentUserId && 
              !status.seenBy.contains(currentUserId))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch recent statuses: $e');
      return [];
    }
  }

  @override
  Future<List<StatusModel>> fetchViewedStatuses(String currentUserId) async {
    try {
      final allStatuses = await fetchAllStatuses(currentUserId);
      return allStatuses
          .where((status) => 
              status.userId != currentUserId && 
              status.seenBy.contains(currentUserId))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch viewed statuses: $e');
      return [];
    }
  }

  // Update Methods
  @override
  Future<void> markStatusAsSeen(String statusId, String userId) async {
    try {
      await _firestore
          .collection('statuses')
          .doc(statusId)
          .update({
        'seenBy': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark status as seen: $e');
      rethrow;
    }
  }

  // Delete Methods
  @override
  Future<void> deleteStatus(String statusId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Delete from Firestore
      await _firestore.collection('statuses').doc(statusId).delete();
      
      // Delete from Storage (if exists)
      try {
        await _storage.ref().child('statuses/$statusId.jpg').delete();
      } catch (e) {
        // File might not exist, ignore
      }
      
      try {
        await _storage.ref().child('statuses/$statusId.m4a').delete();
      } catch (e) {
        // File might not exist, ignore
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete status: $e');
      rethrow;
    }
  }
}
