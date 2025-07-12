import 'package:flutter/material.dart';

class DeleteStatusDialog extends StatelessWidget {
  final VoidCallback onDelete;
  const DeleteStatusDialog({super.key, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Status'),
      content: const Text('Are you sure you want to delete this status?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onDelete,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
} 