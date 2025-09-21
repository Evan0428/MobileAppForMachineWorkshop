import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _editing = false;
  bool _loading = true;

  String _name = "";
  String _phone = "";
  String _email = "";
  String? _localPhotoPath; // ✅ 本地头像路径

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 从 Firestore 拿基本资料
    final doc = await _db.collection("users").doc(user.uid).get();
    final data = doc.data();

    // 从本地加载头像路径
    final prefs = await SharedPreferences.getInstance();
    final photoPath = prefs.getString("profile_photo");

    setState(() {
      _name = data?["name"] ?? "";
      _phone = data?["phone"] ?? "";
      _email = data?["email"] ?? user.email ?? "";
      _localPhotoPath = photoPath;
      _nameCtrl.text = _name;
      _phoneCtrl.text = _phone;
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection("users").doc(user.uid).set({
      "name": _nameCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "email": _email,
    }, SetOptions(merge: true));

    setState(() {
      _name = _nameCtrl.text.trim();
      _phone = _phoneCtrl.text.trim();
      _editing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  /// ✅ 本地上传头像（不走 Firebase Storage）
  Future<void> _pickAndSavePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // 保存到应用目录
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_photo.jpg');
    await file.writeAsBytes(await picked.readAsBytes());

    // 路径写入 SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_photo", file.path);

    setState(() {
      _localPhotoPath = file.path;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile photo updated locally")),
    );
  }

  void _toggleEdit() {
    if (_editing) {
      _saveProfile();
    } else {
      setState(() => _editing = true);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Widget _displayTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _editField(TextEditingController c, String label, IconData icon, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 头像区（编辑模式才显示上传按钮）
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: _localPhotoPath != null ? FileImage(File(_localPhotoPath!)) : null,
                  backgroundColor: Colors.grey.shade200,
                  child: _localPhotoPath == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                if (_editing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickAndSavePhoto,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            if (_editing) ...[
              _editField(_nameCtrl, "Name", Icons.person),
              _editField(_phoneCtrl, "Phone", Icons.phone, type: TextInputType.phone),
              _displayTile(Icons.email, "Email", _email),
            ] else ...[
              _displayTile(Icons.person, "Name", _name),
              _displayTile(Icons.phone, "Phone", _phone),
              _displayTile(Icons.email, "Email", _email),
            ],
          ],
        ),
      ),
    );
  }
}
