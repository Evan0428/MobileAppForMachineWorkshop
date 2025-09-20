import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool ready = false;
  User? user;

  bool get isLoggedIn => user != null;

  /// 初始化：监听 Firebase 用户状态
  void load() {
    _auth.authStateChanges().listen((u) {
      user = u;
      ready = true;
      notifyListeners();
    });
  }

  /// 登录
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  /// 注册
  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Registration failed");
    }
  }

  /// 登出
  Future<void> logout() async {
    await _auth.signOut();
  }
}
