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
  String? _localPhotoPath;

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

    final doc = await _db.collection("users").doc(user.uid).get();
    final data = doc.data();

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

  Future<void> _pickAndSavePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_photo.jpg');
    await file.writeAsBytes(await picked.readAsBytes());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_photo", file.path);

    setState(() {
      _localPhotoPath = file.path;
    });
  }

  Future<void> _changePasswordDialog() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          title: const Text("Change Password",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Current Password"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final oldPass = oldCtrl.text.trim();
                final newPass = newCtrl.text.trim();
                if (oldPass.isEmpty || newPass.isEmpty) return;

                try {
                  final user = FirebaseAuth.instance.currentUser!;
                  final cred = EmailAuthProvider.credential(
                    email: user.email!,
                    password: oldPass,
                  );
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newPass);
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password updated successfully")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed: $e")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
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

  Widget _infoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _editField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
            icon: Icon(_editing ? Icons.check : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 头像 + 名字
          Column(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage: _localPhotoPath != null
                    ? FileImage(File(_localPhotoPath!))
                    : null,
                backgroundColor: Colors.grey.shade300,
                child: _localPhotoPath == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white70)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                _name.isNotEmpty ? _name : "Unnamed User",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(_email, style: TextStyle(color: Colors.grey.shade600)),
              if (_editing)
                TextButton.icon(
                  onPressed: _pickAndSavePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Change Photo"),
                ),
            ],
          ),

          const SizedBox(height: 20),

          if (_editing) ...[
            _editField(_nameCtrl, "Name"),
            _editField(_phoneCtrl, "Phone"),
            _infoCard("Email", _email),
          ] else ...[
            _infoCard("Name", _name),
            _infoCard("Phone", _phone),
            _infoCard("Email", _email),
          ],

          const SizedBox(height: 20),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _changePasswordDialog,
            icon: const Icon(Icons.lock),
            label: const Text("Change Password"),
          ),
        ],
      ),
    );
  }
}
