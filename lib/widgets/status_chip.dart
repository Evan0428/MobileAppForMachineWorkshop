import 'package:flutter/material.dart';
import '../models.dart';

class StatusChip extends StatelessWidget {
  final JobStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      JobStatus.assigned   => Colors.grey,
      JobStatus.accepted   => Colors.blueGrey,
      JobStatus.inProgress => Colors.blue,
      JobStatus.onHold     => Colors.orange,
      JobStatus.completed  => Colors.green,
      JobStatus.signedOff  => Colors.teal,
    };


    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      label: Text(status.label),
      side: BorderSide(color: color.withOpacity(0.5)),
    );
  }
}
