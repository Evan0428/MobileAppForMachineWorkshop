import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../state.dart';
import '../auth.dart';
import 'history_screen.dart';
import 'job_detail_screen.dart';
import 'profile_screen.dart';
import '../models.dart';
import 'login_screen.dart';
import '../repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<JobListController>();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final repo = JobRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs — GearUp')),

      // ✅ Drawer 菜单
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Job History"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthController>().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // ✅ 搜索框
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search jobs...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                context.read<JobListController>().setSearch(value);
              },
            ),
          ),

          // ✅ 状态过滤下拉菜单
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButton<JobStatus?>(
              value: controller.statusFilter,
              hint: const Text("Filter by Status"),
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text("All Jobs"),
                ),
                ...JobStatus.values.map(
                      (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.label),
                  ),
                ),
              ],
              onChanged: (s) {
                context.read<JobListController>().setStatusFilter(s);
              },
            ),
          ),

          // ✅ Today / This Week 切换按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Job Range:"),
                ToggleButtons(
                  isSelected: [!controller.showWeek, controller.showWeek],
                  onPressed: (index) {
                    context.read<JobListController>().toggleRange(index == 1);
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Today"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("This Week"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Job 列表（改为监听 Firebase）
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("jobs")
                  .where("createdBy", isEqualTo: uid)
                  .orderBy("scheduledFor")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No jobs found"));
                }

                var jobs = snapshot.data!.docs
                    .map((doc) => MechanicJob.fromFirestore(doc))
                    .toList();

                // 过滤：状态
                if (controller.statusFilter != null) {
                  jobs = jobs
                      .where((j) => j.status == controller.statusFilter)
                      .toList();
                }

                // 过滤：搜索
                if (controller.search.isNotEmpty) {
                  jobs = jobs
                      .where((j) => j.title
                      .toLowerCase()
                      .contains(controller.search.toLowerCase()))
                      .toList();
                }

                // 过滤：时间范围
                final now = DateTime.now();
                if (controller.showWeek) {
                  final weekEnd = now.add(const Duration(days: 7));
                  jobs = jobs
                      .where((j) =>
                  j.scheduledFor.isAfter(now) &&
                      j.scheduledFor.isBefore(weekEnd))
                      .toList();
                } else {
                  jobs = jobs
                      .where((j) =>
                  j.scheduledFor.year == now.year &&
                      j.scheduledFor.month == now.month &&
                      j.scheduledFor.day == now.day)
                      .toList();
                }

                if (jobs.isEmpty) {
                  return const Center(child: Text("No jobs match filters"));
                }

                return ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return ListTile(
                      leading: const Icon(Icons.build, color: Colors.blue),
                      title: Text(job.title),
                      subtitle: Text("Status: ${job.status.label}"),
                      onTap: () => Navigator.pushNamed(
                        context,
                        JobDetailScreen.routeName,
                        arguments: job.id,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ✅ 新增 Job 按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.pushNamed(context, "/add-job");
          if (added == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Job added successfully")),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
