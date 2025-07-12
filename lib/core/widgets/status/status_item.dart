import 'package:flutter/material.dart';
import 'package:whatsapp_clone/model/status/status_model.dart';

class StatusItem extends StatelessWidget {
  final StatusModel status;
  const StatusItem({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(status.profileImageUrl ?? 'https://ui-avatars.com/api/?name=${status.userName}'),
      ),
      title: Text(status.userName),
      subtitle: Text(status.text ?? 'Status'),
      trailing: Text(_formatTime(status.timestamp)),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ساعة';
    } else {
      return '${diff.inDays} يوم';
    }
  }
} 