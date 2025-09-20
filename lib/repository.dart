import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models.dart';

class JobRepository {
  static final JobRepository _i = JobRepository._internal();
  factory JobRepository() => _i;
  JobRepository._internal();

  final _uuid = const Uuid();
  final _db = FirebaseFirestore.instance;

  /// 当前用户 UID
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// 一次性拉取 Job 列表（支持时间范围）
  Future<List<MechanicJob>> listJobs({DateTime? start, DateTime? end}) async {
    if (_uid == null) return [];

    Query<Map<String, dynamic>> query = _db
        .collection("jobs")
        .where("createdBy", isEqualTo: _uid)
        .orderBy("scheduledFor");

    if (start != null && end != null) {
      query = query
          .where("scheduledFor", isGreaterThanOrEqualTo: start)
          .where("scheduledFor", isLessThanOrEqualTo: end);
    }

    final snapshot = await query.get();
    final jobs =
    snapshot.docs.map((doc) => MechanicJob.fromFirestore(doc)).toList();

    // 恢复本地 elapsedSeconds
    await _restoreElapsed(jobs);
    return jobs;
  }

  /// 实时监听 Job 列表（推荐给 Dashboard 用）
  Stream<List<MechanicJob>> streamJobs() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection("jobs")
        .where("createdBy", isEqualTo: _uid)
        .orderBy("scheduledFor")
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MechanicJob.fromFirestore(doc)).toList());
  }

  /// 根据 ID 获取 Job
  Future<MechanicJob?> getJob(String id) async {
    if (_uid == null) return null;
    final doc = await _db.collection("jobs").doc(id).get();
    if (!doc.exists) return null;
    final job = MechanicJob.fromFirestore(doc);
    await _restoreElapsed([job]);
    return job;
  }

  /// 更新 Job 状态
  Future<void> updateStatus(String id, JobStatus status) async {
    await _db.collection("jobs").doc(id).update({
      "status": status.name,
    });
  }

  /// 添加文字笔记
  Future<void> addTextNote(String jobId, String text) async {
    final note = {
      "id": _uuid.v4(),
      "timestamp": DateTime.now(),
      "text": text,
    };
    await _db.collection("jobs").doc(jobId).collection("notes").add(note);
  }

  /// 添加照片笔记
  Future<void> addPhotoNote(String jobId, String photoPath) async {
    final note = {
      "id": _uuid.v4(),
      "timestamp": DateTime.now(),
      "photoPath": photoPath,
    };
    await _db.collection("jobs").doc(jobId).collection("notes").add(note);
  }

  /// 保存本地 elapsedSeconds
  Future<void> saveElapsed(String id, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('elapsed_$id', seconds);
  }

  /// 恢复本地 elapsedSeconds
  Future<void> _restoreElapsed(List<MechanicJob> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    for (final j in jobs) {
      j.elapsedSeconds = prefs.getInt('elapsed_${j.id}') ?? j.elapsedSeconds;
    }
  }

  /// 新增 Job
  Future<void> addJob({
    required String title,
    required String description,
    required Customer customer,
    required Vehicle vehicle,
    required List<PartItem> parts,
    required DateTime scheduledFor,
  }) async {
    if (_uid == null) return;
    await _db.collection("jobs").add({
      "title": title,
      "description": description,
      "status": JobStatus.assigned.name, // 默认状态
      "scheduledFor": scheduledFor,
      "createdBy": _uid,
      "createdAt": FieldValue.serverTimestamp(),
      "customer": customer.toMap(),
      "vehicle": vehicle.toMap(),
      "parts": parts.map((p) => p.toMap()).toList(),
      "notes": [],
    });
  }
}
