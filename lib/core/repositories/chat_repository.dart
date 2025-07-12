// ignore_for_file: annotate_overrides

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:whatsapp_clone/core/interfaces/chat_repository_interface.dart';

class ChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  String getChatId(String user1, String user2) {
    final sortedUsers = [user1, user2]..sort();
    return '${sortedUsers[0]}_${sortedUsers[1]}';
  }

  Future<void> sendMessage(String chatDocId, senderId, String text) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatDocId)
          .collection('messages')
          .add({
            'text': text,
            'senderId': senderId,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'text',
          });

      // تحديث أو إنشاء chat overview
      await _updateChatOverview(chatDocId, senderId, text, 'text');
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getMessagesStream(String chatDocId) {
    return _firestore
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<String> sendVoiceMessage(
    String chatId,
    String senderId,
    File file,
  ) async {
    try {
      // التحقق من وجود الملف
      if (!await file.exists()) {
        throw Exception('Voice file does not exist');
      }

      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) { // 50MB
        throw Exception('Voice file is too large (max 50MB)');
      }

      final ref = FirebaseStorage.instance.ref(
        'voice_messages/$chatId/${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      
      final snapshot = await ref.putFile(file);
      
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
      
      final url = await snapshot.ref.getDownloadURL();
      
      // إضافة الرسالة إلى Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'audioUrl': url,
            'senderId': senderId,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'voice',
            'text': '',
          });
      
      debugPrint('✅ Voice message saved to Firestore');

      // تحديث أو إنشاء chat overview
      await _updateChatOverview(chatId, senderId, 'Voice Message', 'voice');
      
      return url;
    } catch (e) {
      debugPrint('Error sending voice message: $e');
      rethrow;
    }
  }

  Future<String> sendImageMessage(
    String chatId,
    String senderId,
    File imageFile,
  ) async {
    try {
      // تحقق من وجود الملف
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // تحقق من حجم الصورة (مثلاً أقل من 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) { // 10MB
        throw Exception('Image file is too large (max 10MB)');
      }

      final ref = FirebaseStorage.instance.ref(
        'chat_images/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final snapshot = await ref.putFile(imageFile);
      if (snapshot.state != TaskState.success) {
        throw Exception('Image upload failed with state: snapshot.state}');
      }
      final url = await snapshot.ref.getDownloadURL();

      // إضافة الرسالة إلى Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'imageUrl': url,
            'senderId': senderId,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'image',
            'text': '',
          });

      // تحديث أو إنشاء chat overview
      await _updateChatOverview(chatId, senderId, 'Photo', 'image');

      return url;
    } catch (e) {
      debugPrint('Error sending image message: $e');
      rethrow;
    }
  }

  // دالة لتحديث أو إنشاء chat overview
  Future<void> _updateChatOverview(String chatId, String senderId, String lastMessage, String messageType) async {
    try {
      // استخراج user IDs من chat ID
      final userIds = chatId.split('_');
      if (userIds.length != 2) {
        debugPrint('❌ Invalid chat ID format: $chatId');
        return;
      }

      final user1 = userIds[0];
      final user2 = userIds[1];

      // تحديث أو إنشاء chat overview
      await _firestore.collection('chats').doc(chatId).set({
        'users': [user1, user2],
        'lastMessage': lastMessage,
        'lastMessageType': messageType,
        'lastMessageSenderId': senderId,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Chat overview updated for chat: $chatId');
    } catch (e) {
      debugPrint('❌ Error updating chat overview: $e');
    }
  }

  Future<void> deleteMessage(String receiverId, String messageId) async {}

  // دالة جديدة لرفع الرسائل الصوتية مع مراقبة التقدم
  Future<Map<String, dynamic>> uploadVoiceMessage({
    required String filePath,
    required String chatId,
    required String senderId,
  }) async {
    try {
      debugPrint('🚀 Starting upload for file: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('❌ File does not exist: $filePath');
        return {
          'success': false,
          'error': 'File does not exist',
          'url': null,
          'messageId': null,
        };
      }

      // التحقق من حجم الملف
      final fileSize = await file.length();
      debugPrint('📁 File size: $fileSize bytes');
      
      if (fileSize > 50 * 1024 * 1024) { // 50MB
        return {
          'success': false,
          'error': 'File too large (max 50MB)',
          'url': null,
          'messageId': null,
        };
      }

      // رفع الملف إلى Firebase Storage مع مراقبة التقدم
      final ref = FirebaseStorage.instance.ref(
        'voice_messages/$chatId/${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      
      debugPrint('📤 Uploading to Firebase Storage...');
      final uploadTask = ref.putFile(file);
      
      // مراقبة تقدم التحميل
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      // إضافة timeout للرفع
      final snapshot = await uploadTask.timeout(
        Duration(seconds: 60), // زيادة الوقت للهواتف البطيئة
        onTimeout: () {
          debugPrint('⏰ Upload timeout after 60 seconds');
          throw Exception('Upload timeout');
        },
      );
      debugPrint('📤 Upload completed with state: ${snapshot.state}');
      
      if (snapshot.state != TaskState.success) {
        return {
          'success': false,
          'error': 'Upload failed with state: ${snapshot.state}',
          'url': null,
          'messageId': null,
        };
      }
      
      final url = await snapshot.ref.getDownloadURL();
      debugPrint('🔗 Download URL obtained: $url');
      
      // إضافة الرسالة إلى Firestore
      debugPrint('💾 Saving to Firestore...');
      final messageRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'audioUrl': url,
            'senderId': senderId,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'voice',
            'text': '', // إضافة حقل نصي فارغ للتوافق
          });
      
      debugPrint('✅ Firestore save completed with ID: ${messageRef.id}');
      
      // تحديث أو إنشاء chat overview
      await _updateChatOverview(chatId, senderId, 'Voice Message', 'voice');
      
      return {
        'success': true,
        'error': null,
        'url': url,
        'messageId': messageRef.id,
      };
    } catch (e) {
      debugPrint('❌ Error in uploadVoiceMessage: $e');
      return {
        'success': false,
        'error': e.toString(),
        'url': null,
        'messageId': null,
      };
    }
  }
}

// Future<String> sendVoiceMessage(
  //   String chatDocId,
  //   String senderId,
  //   File file,
  // ) async {
  //   try {
  //     if (!await file.exists()) {
  //       throw Exception('Voice file does not exist locally');
  //     }

  //     final safeChatDocId = chatDocId.replaceAll(
  //       RegExp(r'[^a-zA-Z0-9_-]'),
  //       '_',
  //     );

  //     final storageRef = _storage
  //         .ref()
  //         .child('voice_messages')
  //         .child(safeChatDocId)
  //         .child('${DateTime.now().millisecondsSinceEpoch}.m4a');
  //     final uploadTask = storageRef.putFile(file);

  //     final TaskSnapshot snapshot = await uploadTask;

  //     if (snapshot.state != TaskState.success) {
  //       throw Exception('Upload failed with state: ${snapshot.state}');
  //     }
  //     final downloadUrl = await snapshot.ref.getDownloadURL();

  //     await _firestore
  //         .collection('chats')
  //         .doc(chatDocId)
  //         .collection('messages')
  //         .add({
  //           'audioUrl': downloadUrl,
  //           'senderId': senderId,
  //           'timestamp': FieldValue.serverTimestamp(),
  //           'type': 'voice',
  //         });
  //     return downloadUrl;
  //   } catch (e, s) {
  //     print('Error sending voice message: $e');
  //     print('Stack trace: $s');
  //     rethrow;
  //   }
  // }