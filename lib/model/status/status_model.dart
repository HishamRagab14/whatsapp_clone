import 'package:cloud_firestore/cloud_firestore.dart';

enum StatusType { text, image, audio }

class StatusModel {
  final String id;
  final String userId;
  final String userName;
  final String? profileImageUrl;
  final StatusType type;
  final String? text;
  final String? mediaUrl;
  final DateTime timestamp;
  final List<String> seenBy;

  StatusModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.profileImageUrl,
    required this.type,
    this.text,
    this.mediaUrl,
    required this.timestamp,
    required this.seenBy,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return StatusModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      type: StatusType.values.firstWhere(
        (e) => e.toString() == 'StatusType.${json['type']}',
        orElse: () => StatusType.text,
      ),
      text: json['text'],
      mediaUrl: json['mediaUrl'],
      timestamp: parseTimestamp(json['timestamp']),
      seenBy: List<String>.from(json['seenBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'profileImageUrl': profileImageUrl,
      'type': type.toString().split('.').last,
      'text': text,
      'mediaUrl': mediaUrl,
      'timestamp': timestamp.toIso8601String(),
      'seenBy': seenBy,
    };
  }

  StatusModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? profileImageUrl,
    StatusType? type,
    String? text,
    String? mediaUrl,
    DateTime? timestamp,
    List<String>? seenBy,
  }) {
    return StatusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      type: type ?? this.type,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timestamp: timestamp ?? this.timestamp,
      seenBy: seenBy ?? this.seenBy,
    );
  }

  bool get isSeen => seenBy.isNotEmpty;
  bool get isMyStatus => false; // سيتم تحديده في الـ controller
} 