import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/constants.dart';

class AddStatusButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasStatus;
  final String? userName;
  final String? profileImageUrl;

  const AddStatusButton({
    super.key,
    required this.onTap,
    required this.hasStatus,
    this.userName,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl!)
                : const AssetImage('assets/images/person.jpg') as ImageProvider,
            child: profileImageUrl == null && userName != null
                ? Text(userName![0].toUpperCase())
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: kLightPrimaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        userName ?? (hasStatus ? 'My status' : 'Add to my status'),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        hasStatus ? 'Tap to add status update' : 'Tap to add status update',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
} 