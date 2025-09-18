import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';

class JobRepository {
  static final JobRepository _i = JobRepository._internal();
  factory JobRepository() => _i;
  JobRepository._internal();

  final _uuid = const Uuid();

  final List<MechanicJob> _jobs = [
    MechanicJob(
      id: 'J-001',
      title: 'Engine Oil & Filter Change',
      description: 'Replace engine oil, oil filter, inspect belts. Customer notes ticking noise.',
      customer: Customer(id: 'C-001', name: 'Alex Tan', phone: '012-3456789', email: 'alex.tan@example.com'),
      vehicle: Vehicle(
        vin: 'WVWZZZ1JZXW000001',
        plate: 'VBL 1234',
        make: 'Proton',
        model: 'X50',
        year: 2022,
        history: [
          ServiceRecord(date: DateTime.now().subtract(const Duration(days: 120)), description: '15k km service'),
        ],
      ),
      parts: [
        PartItem(id: 'P-100', name: 'Engine Oil 5W-30', number: 'EO-5W30', qty: 4),
        PartItem(id: 'P-101', name: 'Oil Filter', number: 'OF-123', qty: 1),
      ],
      scheduledFor: DateTime.now().add(const Duration(hours: 1)),
    ),
    MechanicJob(
      id: 'J-002',
      title: 'Brake Pad Replacement (Front)',
      description: 'Replace front brake pads and check brake fluid.',
      customer: Customer(id: 'C-002', name: 'Mei Ling', phone: '013-9988776', email: 'meiling@example.com'),
      vehicle: Vehicle(
        vin: 'JH4DC5300RS000002',
        plate: 'WQY 8899',
        make: 'Perodua',
        model: 'Myvi',
        year: 2020,
        history: [
          ServiceRecord(date: DateTime.now().subtract(const Duration(days: 45)), description: 'Battery replacement'),
        ],
      ),
      parts: [
        PartItem(id: 'P-200', name: 'Brake Pads Set', number: 'BP-FRONT', qty: 1),
        PartItem(id: 'P-201', name: 'Brake Cleaner', number: 'BC-500', qty: 1),
      ],
      scheduledFor: DateTime.now().add(const Duration(hours: 3)),
    ),
  ];

  Future<List<MechanicJob>> listJobs({DateTime? start, DateTime? end}) async {
    await _restoreElapsed();
    if (start == null || end == null) return _jobs;
    return _jobs
        .where((j) =>
    j.scheduledFor.isAfter(start.subtract(const Duration(seconds: 1))) &&
        j.scheduledFor.isBefore(end.add(const Duration(seconds: 1))))
        .toList();
  }

  Future<MechanicJob?> getJob(String id) async {
    await _restoreElapsed();
    try {
      return _jobs.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStatus(String id, JobStatus status) async {
    final job = await getJob(id);
    if (job != null) job.status = status;
  }

  Future<void> addTextNote(String id, String text) async {
    final job = await getJob(id);
    if (job == null) return;
    job.notes.insert(0, NoteItem(id: _uuid.v4(), timestamp: DateTime.now(), text: text));
  }

  Future<void> addPhotoNote(String id, String photoPath) async {
    final job = await getJob(id);
    if (job == null) return;
    job.notes.insert(0, NoteItem(id: _uuid.v4(), timestamp: DateTime.now(), photoPath: photoPath));
  }

  Future<void> saveElapsed(String id, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('elapsed_$id', seconds);
    final job = await getJob(id);
    if (job != null) job.elapsedSeconds = seconds;
  }

  Future<void> _restoreElapsed() async {
    final prefs = await SharedPreferences.getInstance();
    for (final j in _jobs) {
      j.elapsedSeconds = prefs.getInt('elapsed_${j.id}') ?? j.elapsedSeconds;
    }
  }
}
