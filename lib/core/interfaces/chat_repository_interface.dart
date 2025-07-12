import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IChatRepository {
  String getChatId(String user1, String user2);
  Future<void> sendMessage(String chatDocId, String senderId, String text);
  Stream<QuerySnapshot> getMessagesStream(String chatDocId);
  Future<String> sendVoiceMessage(String chatId, String senderId, File file);
  Future<String> sendImageMessage(String chatId, String senderId, File imageFile);
  Future<Map<String, dynamic>> uploadVoiceMessage({
    required String filePath,
    required String chatId,
    required String senderId,
  });
  Future<void> deleteMessage(String receiverId, String messageId);
} 