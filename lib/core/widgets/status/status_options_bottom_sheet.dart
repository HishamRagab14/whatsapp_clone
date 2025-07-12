import 'package:flutter/material.dart';

class StatusOptionsBottomSheet extends StatelessWidget {
  final bool isMyStatus;
  final VoidCallback onDelete;
  const StatusOptionsBottomSheet({super.key, required this.isMyStatus, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white, // أو استخدم Theme.of(context).bottomSheetTheme.backgroundColor
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMyStatus)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Status', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: onDelete,
            ),
        ],
      ),
    );
  }
} 