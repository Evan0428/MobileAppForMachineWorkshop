import 'package:cloud_firestore/cloud_firestore.dart';

/// 用户模型
class MechanicUser {
  final String uid;
  String name;
  String email;
  String phone;
  String role; // e.g. 'mechanic' / 'admin'

  MechanicUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory MechanicUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MechanicUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'mechanic',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}

/// Firestore DAO
class UserRepository {
  static final UserRepository _i = UserRepository._internal();
  factory UserRepository() => _i;
  UserRepository._internal();

  final _db = FirebaseFirestore.instance;

  /// 新用户注册时写入资料
  Future<void> createUser(MechanicUser user) async {
    await _db.collection("users").doc(user.uid).set(user.toMap());
  }

  /// 获取用户资料
  Future<MechanicUser?> getUser(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    if (!doc.exists) return null;
    return MechanicUser.fromFirestore(doc);
  }

  /// 更新用户资料
  Future<void> updateUser(MechanicUser user) async {
    await _db.collection("users").doc(user.uid).update(user.toMap());
  }

  /// 删除用户（可选）
  Future<void> deleteUser(String uid) async {
    await _db.collection("users").doc(uid).delete();
  }
}
