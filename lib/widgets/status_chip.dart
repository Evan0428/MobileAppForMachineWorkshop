import 'package:flutter/material.dart';
import '../models.dart';

class StatusChip extends StatelessWidget {
  final JobStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case JobStatus.assigned: color = Colors.grey;
      case JobStatus.accepted: color = Colors.blueGrey;
      case JobStatus.inProgress: color = Colors.blue;
      case JobStatus.onHold: color = Colors.orange;
      case JobStatus.completed: color = Colors.green;
    }
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      label: Text(status.label),
      side: BorderSide(color: color.withOpacity(0.5)),
    );
  }
}
