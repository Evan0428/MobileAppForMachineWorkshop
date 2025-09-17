import 'dart:async';
import 'package:flutter/material.dart';
import 'models.dart';
import 'repository.dart';

class JobListController extends ChangeNotifier {
  final repo = JobRepository();
  List<MechanicJob> all = [];
  List<MechanicJob> filtered = [];
  bool showWeek = false;
  String search = '';

  Future<void> load() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: showWeek ? 7 : 1));
    all = await repo.listJobs(start: start, end: end);
    apply();
  }

  void toggleRange(bool week) {
    showWeek = week;
    load();
  }

  void setSearch(String q) {
    search = q;
    apply();
  }

  void apply() {
    filtered = all.where((j) {
      final hay = (j.title + j.description + j.customer.name + j.vehicle.plate + j.vehicle.model).toLowerCase();
      return hay.contains(search.toLowerCase());
    }).toList();
    notifyListeners();
  }
}

class JobDetailController extends ChangeNotifier {
  final repo = JobRepository();
  MechanicJob? job;
  Timer? _timer;
  bool running = false;

  Future<void> init(String id) async {
    job = await repo.getJob(id);
    notifyListeners();
  }


  Future<void> setStatus(JobStatus s) async {
  if (job == null) return;
  await repo.updateStatus(job!.id, s);
  job!.status = s;
  notifyListeners();
  }


  void startTimer() {
    if (job == null || running) return;
    running = true;
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) async {
      job!.elapsedSeconds += 1;
      await repo.saveElapsed(job!.id, job!.elapsedSeconds);
      notifyListeners();
    });
  }

  void pauseTimer() {
    running = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void stopTimer() {
    pauseTimer();
  }

  Future<void> addTextNote(String text) async {
    if (job == null) return;
    await repo.addTextNote(job!.id, text);
    notifyListeners();
  }

  Future<void> addPhotoNote(String path) async {
    if (job == null) return;
    await repo.addPhotoNote(job!.id, path);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

String formatDuration(int seconds) {
  final d = Duration(seconds: seconds);
  final two = (int n) => n.toString().padLeft(2, '0');
  final h = two(d.inHours);
  final m = two(d.inMinutes.remainder(60));
  final s = two(d.inSeconds.remainder(60));
  return '$h:$m:$s';
}
