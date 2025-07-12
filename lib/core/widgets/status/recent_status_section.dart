import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/widgets/status/status_list_item.dart';
import 'package:whatsapp_clone/model/status/status_model.dart';

class RecentStatusSection extends StatelessWidget {
  final List<StatusModel> recentStatuses;
  final Function(String userId) onViewUserStatuses;
  final Map<String, List<StatusModel>> groupedStatusesByUser;

  const RecentStatusSection({
    super.key,
    required this.recentStatuses,
    required this.onViewUserStatuses,
    required this.groupedStatusesByUser,
  });

  @override
  Widget build(BuildContext context) {
    if (recentStatuses.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent updates',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          child: Column(
            children: recentStatuses
                .map(
                  (status) => StatusListItem(
                    status: status,
                    isMyStatus: false,
                    onTap: () => onViewUserStatuses(status.userId),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
} 