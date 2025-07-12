import 'package:flutter/material.dart';

class AttachmentIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  
  const AttachmentIcon({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: onTap != null ? Colors.blueGrey[50] : Colors.grey[200],
            child: Icon(
              icon, 
              color: onTap != null ? Colors.blueGrey : Colors.grey, 
              size: 26
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12, 
              color: onTap != null ? Colors.black87 : Colors.grey
            ),
          ),
        ],
      ),
    );
  }
} 