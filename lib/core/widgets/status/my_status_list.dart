import 'package:flutter/material.dart';
import 'package:whatsapp_clone/model/status/status_model.dart';
import 'package:whatsapp_clone/core/widgets/status/status_item.dart';

class MyStatusList extends StatelessWidget {
  final List<StatusModel> statuses;
  const MyStatusList({super.key, required this.statuses});

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) {
      return const Center(child: Text('لا توجد حالات لك بعد'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        return StatusItem(status: statuses[index]);
      },
    );
  }
} 