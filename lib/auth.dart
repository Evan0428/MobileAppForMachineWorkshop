<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  static const _kLoggedIn = 'logged_in';
  bool _ready = false;     // 已完成读取本地状态
  bool _loggedIn = false;  // 是否已登录

  bool get ready => _ready;
  bool get isLoggedIn => _loggedIn;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = prefs.getBool(_kLoggedIn) ?? false;
    _ready = true;
    notifyListeners();
  }

  Future<void> login({String? username, String? password}) async {
    // TODO: 换成你真实的校验逻辑
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    _loggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, false);
    _loggedIn = false;
    notifyListeners();
  }
}
=======
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  static const _kLoggedIn = 'logged_in';
  bool _ready = false;     // 已完成读取本地状态
  bool _loggedIn = false;  // 是否已登录

  bool get ready => _ready;
  bool get isLoggedIn => _loggedIn;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = prefs.getBool(_kLoggedIn) ?? false;
    _ready = true;
    notifyListeners();
  }

  Future<void> login({String? username, String? password}) async {
    // TODO: 换成你真实的校验逻辑
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    _loggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, false);
    _loggedIn = false;
    notifyListeners();
  }
}
>>>>>>> df8ba06 (Initial)
