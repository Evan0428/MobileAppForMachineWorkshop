import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import '../models.dart';
import 'job_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  static const routeName = '/history';
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<JobListController>();

    // ✅ 从 Firestore 直接获取 jobs
    final jobsStream = FirebaseFirestore.instance
        .collection("jobs")
        .orderBy("scheduledFor", descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MechanicJob.fromFirestore(d)).toList());

    return Scaffold(
      appBar: AppBar(title: const Text("Job History")),
      body: StreamBuilder<List<MechanicJob>>(
        stream: jobsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No jobs found"));
          }

          // ✅ 过滤出 Completed 和 Signed-off 的工作
          final historyJobs = snapshot.data!
              .where((j) => j.status == JobStatus.completed || j.status == JobStatus.signedOff)
              .toList();

          if (historyJobs.isEmpty) {
            return const Center(child: Text("No completed jobs yet"));
          }

          // ✅ 分组：今天 / 本周 / 更早
          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);
          final startOfWeek = startOfToday.subtract(Duration(days: now.weekday - 1));

          final todayJobs = historyJobs.where((j) => j.scheduledFor.isAfter(startOfToday)).toList();
          final weekJobs = historyJobs
              .where((j) => j.scheduledFor.isAfter(startOfWeek) && j.scheduledFor.isBefore(startOfToday))
              .toList();
          final earlierJobs = historyJobs.where((j) => j.scheduledFor.isBefore(startOfWeek)).toList();

          Widget buildSection(String title, List<MechanicJob> jobs) {
            if (jobs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...jobs.map((job) => ListTile(
                  leading: const Icon(Icons.history, color: Colors.green),
                  title: Text(job.title),
                  subtitle: Text("Status: ${job.status.label}"),
                  onTap: () => Navigator.pushNamed(
                    context,
                    JobDetailScreen.routeName,
                    arguments: job.id,
                  ),
                )),
                const Divider(),
              ],
            );
          }

          return ListView(
            children: [
              buildSection("Today", todayJobs),
              buildSection("This Week", weekJobs),
              buildSection("Earlier", earlierJobs),
            ],
          );
        },
      ),
    );
  }
}
