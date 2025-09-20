import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 以后可以从 AuthController 获取真实用户数据
    const userName = "John Mechanic";
    const userEmail = "john@example.com";
    const userPhone = "+60123456789";

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            Text("Name: $userName", style: const TextStyle(fontSize: 18)),
            Text("Email: $userEmail", style: const TextStyle(fontSize: 18)),
            Text("Phone: $userPhone", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
