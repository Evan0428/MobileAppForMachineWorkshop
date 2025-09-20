import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import 'job_detail_screen.dart';
import 'profile_screen.dart'; // ✅ 新增 Profile 页面
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
                Navigator.pop(context); // 先关掉 Drawer
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
                // ✅ 这里以后可以调用 AuthController.logout()
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // ✅ Job 列表
      body: ListView.builder(
        itemCount: c.jobs.length,
        itemBuilder: (context, index) {
          final job = c.jobs[index]; // 👈 这里是 MechanicJob
          return ListTile(
            title: Text(job.title),
            subtitle: Text("Status: ${job.status.label}"), // 👈 用 JobStatusX.label
            onTap: () => Navigator.pushNamed(
              context,
              JobDetailScreen.routeName,
              arguments: job.id, // 👈 保持你原始逻辑，传 job.id
            ),
          );
        },
      ),
    );
  }
}
