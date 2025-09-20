import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (data != null) {
      setState(() {
        _name = data["name"] ?? "";
        _phone = data["phone"] ?? "";
        _email = data["email"] ?? user.email ?? "";
        _nameCtrl.text = _name;
        _phoneCtrl.text = _phone;
        _loading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection("users").doc(user.uid).update({
      "name": _nameCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
    });

    setState(() {
      _name = _nameCtrl.text.trim();
      _phone = _phoneCtrl.text.trim();
      _editing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_editing) {
      _saveProfile();
    } else {
      setState(() => _editing = true);
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _editing
                ? TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person),
              ),
            )
                : ListTile(
              leading: const Icon(Icons.person),
              title: Text(_name),
            ),
            const SizedBox(height: 12),
            _editing
                ? TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: "Phone",
                prefixIcon: Icon(Icons.phone),
              ),
            )
                : ListTile(
              leading: const Icon(Icons.phone),
              title: Text(_phone),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(_email),
            ),
          ],
        ),
      ),
    );
  }
}
