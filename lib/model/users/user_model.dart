import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uId;
  final String phoneNumber;
  final String? userName;
  final String? profileImageUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? status;

  UserModel({
    required this.uId,
    required this.phoneNumber,
    required this.userName,
    required this.profileImageUrl,
    this.status,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uId: map['uId'],
      phoneNumber: map['phoneNumber'],
      userName: map['userName'],
      profileImageUrl: map['profileImageUrl'],
      status: map['status'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null 
          ? (map['lastSeen'] is Timestamp 
              ? (map['lastSeen'] as Timestamp).toDate()
              : DateTime.parse(map['lastSeen']))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'phoneNumber': phoneNumber,
      'userName': userName,
      'profileImageUrl': profileImageUrl,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }
}
