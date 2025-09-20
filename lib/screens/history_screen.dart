import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import '../models.dart';
import 'job_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<JobListController>();

    // ✅ 过滤出 Completed 和 Signed-off 的工作
    final historyJobs = c.jobs.where(
          (j) => j.status == JobStatus.completed || j.status == JobStatus.signedOff,
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Job History")),
      body: historyJobs.isEmpty
          ? const Center(child: Text("No completed jobs yet"))
          : ListView.builder(
        itemCount: historyJobs.length,
        itemBuilder: (context, index) {
          final job = historyJobs[index];
          return ListTile(
            leading: const Icon(Icons.history, color: Colors.green),
            title: Text(job.title),
            subtitle: Text("Status: ${job.status.label}"),
            onTap: () => Navigator.pushNamed(
              context,
              JobDetailScreen.routeName,
              arguments: job.id,
            ),
          );
        },
      ),
    );
  }
}
