import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  static const _kLoggedIn = 'logged_in';
  bool _ready = false;
  bool _loggedIn = false;

  bool get ready => _ready;
  bool get isLoggedIn => _loggedIn;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = prefs.getBool(_kLoggedIn) ?? false;
    _ready = true;
    notifyListeners();
  }

  Future<void> login({String? username, String? password}) async {
    // TODO: 接后端鉴权
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
