import 'package:flutter/material.dart';
import '../../../model/users/user_model.dart';

class StatusViewersList extends StatelessWidget {
  final List<UserModel?> viewers;
  const StatusViewersList({super.key, required this.viewers});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('Viewers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(),
          Expanded(
            child: viewers.isEmpty
                ? const Center(child: Text('No viewers yet'))
                : ListView.builder(
                    itemCount: viewers.length,
                    itemBuilder: (context, index) {
                      final user = viewers[index];
                      if (user == null) return const SizedBox.shrink();
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                              ? Text((user.userName?.isNotEmpty ?? false) ? user.userName![0].toUpperCase() : '?')
                              : null,
                        ),
                        title: Text(user.userName ?? 'Unknown'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 