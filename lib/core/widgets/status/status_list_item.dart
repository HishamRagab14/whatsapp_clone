import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/constants.dart';
import 'package:whatsapp_clone/core/utils/time_formatter.dart';
import 'package:whatsapp_clone/model/status/status_model.dart';
import 'package:whatsapp_clone/core/services/firestore_user_service.dart';
import 'package:whatsapp_clone/model/users/user_model.dart';

class StatusListItem extends StatelessWidget {
  final StatusModel status;
  final bool isMyStatus;
  final VoidCallback onTap;
  final Function(String)? onDelete;

  const StatusListItem({
    super.key,
    required this.status,
    required this.isMyStatus,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if there are any unseen statuses for this user
    final bool hasUnseen = !isMyStatus && !status.isSeen;
    final Color ringColor =
        hasUnseen ? kLightPrimaryColor : Colors.grey[400]!;
    return FutureBuilder<UserModel?>(
      future: FirestoreUserService().getUserById(status.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return GestureDetector(
          onTap: onTap,
          onLongPress: isMyStatus ? () => _showDeleteDialog(context) : null,
          child: ListTile(
            leading: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        user?.profileImageUrl != null &&
                                user!.profileImageUrl!.isNotEmpty
                            ? NetworkImage(user.profileImageUrl!)
                            : AssetImage('assets/images/profile1.jpg'),
                    child:
                        (user?.profileImageUrl == null ||
                                user!.profileImageUrl!.isEmpty)
                            ? Text(
                              (user?.userName?.isNotEmpty ?? false)
                                  ? user!.userName![0]
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                ),
                if (!isMyStatus && !status.isSeen)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: kLightPrimaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              user?.userName ?? status.userName,
              style: TextStyle(
                fontWeight: status.isSeen ? FontWeight.normal : FontWeight.w600,
                fontSize: 16,
                color: status.isSeen ? Colors.grey[600] : Colors.black,
              ),
            ),
            subtitle: Text(
              _getStatusPreview(),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMyStatus)
                  Tooltip(
                    message: 'Delete Status',
                    child: IconButton(
                      onPressed: () => _showDeleteDialog(context),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: kLightPrimaryColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                Text(
                  TimeFormatter.formatTimeAgo(status.timestamp),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusPreview() {
    switch (status.type) {
      case StatusType.text:
        return status.text ?? 'Text status';
      case StatusType.image:
        return '📷 Image';
      case StatusType.audio:
        return '🎵 Audio';
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text(
                'Delete Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this status? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call(status.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kLightPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Delete', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}
