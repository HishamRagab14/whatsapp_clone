import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:whatsapp_clone/model/users/user_model.dart';
import 'package:flutter/foundation.dart';

class FirestoreUserService {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final storageRef = FirebaseStorage.instance.ref();

  Future<void> createUserIfNotExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await usersRef.doc(user.uid).get();
    if (!doc.exists) {
      final defaultUserName = user.displayName ?? 'User ${user.phoneNumber?.substring(user.phoneNumber!.length - 4) ?? 'Unknown'}';
      await usersRef.doc(user.uid).set({
        'uId': user.uid,
        'phoneNumber': user.phoneNumber,
        'userName': defaultUserName,
        'profileImageUrl': null,
        'status': 'Hey there! I am using Hisham\'s WhatsApp.',
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      // print('✅ Created new user in Firestore: $defaultUserName');
    }
  }

  /// الحصول على بيانات المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await usersRef.doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// رفع الصورة الشخصية إلى Firebase Storage
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final fileName = 'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileRef = storageRef.child(fileName);
      
      final uploadTask = fileRef.putFile(imageFile);
      final snapshot = await uploadTask;
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  /// تحديث رابط الصورة الشخصية في Firestore
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await usersRef.doc(userId).update({
        'profileImageUrl': imageUrl,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      rethrow;
    }
  }

  /// تحديث اسم المستخدم
  Future<void> updateUserName(String userId, String userName) async {
    try {
      await usersRef.doc(userId).update({
        'userName': userName,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user name: $e');
      rethrow;
    }
  }

  /// تحديث حالة المستخدم (Status)
  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await usersRef.doc(userId).update({
        'status': status,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user status: $e');
      rethrow;
    }
  }

  /// تحديث حالة الاتصال للمستخدم
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await usersRef.doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating online status: $e');
      rethrow;
    }
  }

  /// الحصول على جميع المستخدمين
  Future<List<UserModel>> getAllUsers() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      final querySnapshot = await usersRef
          .where('uId', isNotEqualTo: currentUser.uid)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  /// الحصول على مستخدم بواسطة ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await usersRef.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  /// حذف الصورة الشخصية فقط
  Future<void> deleteProfileImage(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user?.profileImageUrl != null) {
        // حذف الصورة من Storage
        final imageRef = FirebaseStorage.instance.refFromURL(user!.profileImageUrl!);
        await imageRef.delete();
        
        // تحديث المستخدم بدون صورة
        await usersRef.doc(userId).update({
          'profileImageUrl': null,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
      rethrow;
    }
  }

  /// حذف حساب المستخدم
  Future<void> deleteUser(String userId) async {
    try {
      // حذف الصورة الشخصية من Storage إذا كانت موجودة
      final user = await getUserById(userId);
      if (user?.profileImageUrl != null) {
        try {
          final imageRef = FirebaseStorage.instance.refFromURL(user!.profileImageUrl!);
          await imageRef.delete();
        } catch (e) {
          debugPrint('Error deleting profile image: $e');
        }
      }

      // حذف بيانات المستخدم من Firestore
      await usersRef.doc(userId).delete();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  /// تحديث بيانات المستخدم الحالي إذا كانت غير مكتملة
  Future<void> updateCurrentUserIfNeeded() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await usersRef.doc(user.uid).get();
      if (doc.exists) {
        final userData = doc.data()!;
        final currentUserName = userData['userName'];
        final currentStatus = userData['status'];
        
        // إذا كان الاسم فارغ أو "Unknown"، قم بتحديثه
        if (currentUserName == null || currentUserName.isEmpty || currentUserName == 'Unknown') {
          final defaultUserName = user.displayName ?? 'User ${user.phoneNumber?.substring(user.phoneNumber!.length - 4) ?? 'Unknown'}';
          await usersRef.doc(user.uid).update({
            'userName': defaultUserName,
            'lastSeen': FieldValue.serverTimestamp(),
          });
          // print('✅ Updated user name to: $defaultUserName');
        }
        
        // إذا كان الـ status فارغ، قم بتحديثه
        if (currentStatus == null || currentStatus.isEmpty) {
          await usersRef.doc(user.uid).update({
            'status': 'Hey there! I am using Hisham\'s WhatsApp.',
            'lastSeen': FieldValue.serverTimestamp(),
          });
          // print('✅ Updated user status');
        }
      }
    } catch (e) {
      debugPrint('Error updating current user: $e');
    }
  }


}
