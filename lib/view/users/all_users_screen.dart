import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/view/chats/chat_details/chat_detail_screen.dart';

class AllUsersScreen extends StatelessWidget {
  const AllUsersScreen({super.key});
  static const String allUsersRoute = '/all-users';

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('All Contacts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users =
              snapshot.data!.docs
                  .where((doc) => doc.id != currentUserId)
                  .toList();
          log('Current user ID: $currentUserId');
          log('All users count (excluding current): ${users.length}');
          for (var user in users) {
            log('User ID: ${user.id}, Data: ${user.data()}');
          }

          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data();
              //as Map<String, dynamic>;
              final userId = users[index].id;
              final userName = userData['userName'] ?? 'Unknown Name';
              final userImage = userData['profileImage'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      (userImage.trim().isNotEmpty)
                          ? NetworkImage(userImage)
                          : const AssetImage('assets/images/profile2.png')
                              as ImageProvider,
                ),
                title: Text(userName),
                subtitle: Text(userId),
                onTap: () {
                  Get.to(
                    () => ChatDetailScreen(
                      name: userName,
                      imageUrl:
                          (userImage.isNotEmpty)
                              ? userImage
                              : 'assets/images/profile2.png',
                      receiverId: userId,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
