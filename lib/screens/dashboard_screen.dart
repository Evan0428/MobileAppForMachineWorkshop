import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import 'job_detail_screen.dart';
import 'profile_screen.dart';
import '../models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<JobListController>();

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
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                // ✅ 以后可调用 AuthController.logout()
                Navigator.pop(context);
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

          // ✅ Today / This Week 切换按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Job Range:"),
                ToggleButtons(
                  isSelected: [!c.showWeek, c.showWeek],
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

          // ✅ Job 列表
          Expanded(
            child: c.jobs.isEmpty
                ? const Center(child: Text("No jobs found"))
                : ListView.builder(
              itemCount: c.jobs.length,
              itemBuilder: (context, index) {
                final job = c.jobs[index];
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
            ),
          ),
        ],
      ),
    );
  }
}
