import 'package:flutter/material.dart';

class StatusOptionsBottomSheet extends StatelessWidget {
  final bool isMyStatus;
  final VoidCallback? onDelete;
  const StatusOptionsBottomSheet({
    super.key,
    required this.isMyStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (!isMyStatus) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Status', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              if (onDelete != null) onDelete!();
            },
          ),
        ],
      ),
    );
  }
} 