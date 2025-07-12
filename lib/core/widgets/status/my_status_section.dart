import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/widgets/status/add_status_button.dart';
import 'package:whatsapp_clone/core/widgets/status/status_list_item.dart';
import 'package:whatsapp_clone/model/status/status_model.dart';
import 'package:whatsapp_clone/core/widgets/status/status_viewer_screen.dart';

class MyStatusSection extends StatelessWidget {
  final List<StatusModel> myStatuses;
  final VoidCallback onAddStatus;
  final Function(StatusModel) onViewStatus;
  final Function(String)? onDeleteStatus;
  final String? userName;
  final String? profileImageUrl;

  const MyStatusSection({
    super.key,
    required this.myStatuses,
    required this.onAddStatus,
    required this.onViewStatus,
    this.onDeleteStatus,
    this.userName,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Only show the most recent status as preview, but open all on tap
    final latestStatus = myStatuses.isNotEmpty
        ? (myStatuses..sort((a, b) => b.timestamp.compareTo(a.timestamp))).first
        : null;
    return Column(
      children: [
        AddStatusButton(
          onTap: onAddStatus,
          hasStatus: myStatuses.isNotEmpty,
          userName: userName,
          profileImageUrl: profileImageUrl,
        ),
        if (latestStatus != null)
          StatusListItem(
            status: latestStatus,
            isMyStatus: true,
            onTap: () {
              // Open all statuses in StoryView
              for (final status in myStatuses) {
                // debug print for confirmation
                print('DEBUG: MyStatus in StoryView: id= [status.id], timestamp= [status.timestamp]');
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => StatusViewerScreen(statuses: myStatuses, initialIndex: 0)));
            },
            onDelete: onDeleteStatus,
          ),
      ],
    );
  }
} 