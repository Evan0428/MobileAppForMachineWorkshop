import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;

  // ✅ 假数据（以后可以从 Firebase 替换）
  String _name = "John Doe";
  String _phone = "+60 123456789";
  String _email = "johndoe@example.com";

  // 控制器（编辑模式用）
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _name);
    _phoneCtrl = TextEditingController(text: _phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_editing) {
      // 保存数据
      setState(() {
        _name = _nameCtrl.text;
        _phone = _phoneCtrl.text;
        _editing = false;
      });

      // ✅ 显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    } else {
      // 进入编辑模式
      setState(() => _editing = true);
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: child,
        subtitle: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ 用户头像
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade200,
              child: Text(
                _name.isNotEmpty ? _name[0] : "?",
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ 名字
            _buildInfoTile(
              icon: Icons.person,
              label: "Name",
              child: _editing
                  ? TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(border: InputBorder.none),
              )
                  : Text(_name, style: const TextStyle(fontSize: 16)),
            ),

            // ✅ 电话
            _buildInfoTile(
              icon: Icons.phone,
              label: "Phone",
              child: _editing
                  ? TextField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(border: InputBorder.none),
              )
                  : Text(_phone, style: const TextStyle(fontSize: 16)),
            ),

            // ✅ 邮箱（只读）
            _buildInfoTile(
              icon: Icons.email,
              label: "Email",
              child: Text(_email, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
