import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _busy = false;

  String _passwordStrength = ""; // ✅ 密码强度状态

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ✅ 检查密码强度
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() => _passwordStrength = "");
    } else if (password.length < 6) {
      setState(() => _passwordStrength = "weak");
    } else if (password.length < 10) {
      setState(() => _passwordStrength = "medium");
    } else {
      setState(() => _passwordStrength = "strong");
    }
  }

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // 🚫 如果密码不够强，不允许注册
    if (_passwordStrength == "weak" || _passwordStrength.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password too weak. Please use at least Medium strength.")),
      );
      return;
    }

    setState(() => _busy = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      await FirebaseFirestore.instance.collection("users").doc(cred.user!.uid).set({
        "uid": cred.user!.uid,
        "name": _nameCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "phone": _phoneCtrl.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please log in.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final primary = const Color(0xFF45C2C7);

    // ✅ 根据状态确定颜色 & 文案
    Color strengthColor;
    String strengthText;
    switch (_passwordStrength) {
      case "weak":
        strengthColor = Colors.red;
        strengthText = "Weak";
        break;
      case "medium":
        strengthColor = Colors.orange;
        strengthText = "Medium";
        break;
      case "strong":
        strengthColor = Colors.green;
        strengthText = "Strong";
        break;
      default:
        strengthColor = Colors.transparent;
        strengthText = "";
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部渐变区
            Container(
              width: double.infinity,
              height: media.size.height * 0.28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Image.asset(
                    'assets/images/login_logo.png',
                    fit: BoxFit.contain,
                    height: 90,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 注册表单
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter phone' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        onChanged: _checkPasswordStrength, // ✅ 实时检测强度
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                      ),

                      // ✅ 密码强度条
                      if (_passwordStrength.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: _passwordStrength == "weak"
                                    ? 0.33
                                    : _passwordStrength == "medium"
                                    ? 0.66
                                    : 1.0,
                                backgroundColor: Colors.grey.shade300,
                                color: strengthColor,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(strengthText, style: TextStyle(color: strengthColor)),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: (_busy ||
                              _passwordStrength == "weak" ||
                              _passwordStrength.isEmpty)
                              ? null
                              : _doRegister, // 🚫 禁用弱密码提交
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _busy
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Register'),
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Already have an account? Log In"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
