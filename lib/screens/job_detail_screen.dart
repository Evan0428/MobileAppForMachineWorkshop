import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../models.dart';
import '../state.dart';
import '../widgets/status_chip.dart';
import 'sign_off_screen.dart';

class JobDetailScreen extends StatefulWidget {
  static const routeName = '/job';
  const JobDetailScreen({super.key});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late final JobDetailController c;
  final noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    c = JobDetailController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ModalRoute.of(context)!.settings.arguments as String;
      c.init(id);
      setState(() {});
    });
  }

  @override
  void dispose() {
    noteCtrl.dispose();
    c.dispose();
    super.dispose();
  }

  Future<void> _pickAndSavePhoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
    if (x == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${x.name}');
    await file.writeAsBytes(await x.readAsBytes());
    await c.addPhotoNote(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final job = c.job;
    if (job == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_turned_in),
            tooltip: 'Digital Sign-off',
            onPressed: () => Navigator.pushNamed(context, SignOffScreen.routeName, arguments: job.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusChip(status: job.status),
                const SizedBox(width: 8),
                DropdownButton<JobStatus>(
                  value: job.status,
                  items: JobStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                  onChanged: (s) => c.setStatus(s!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _section(
              context,
              'Customer & Vehicle',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line('Customer', job.customer.name),
                  _line('Phone', job.customer.phone),
                  _line('Email', job.customer.email),
                  const Divider(),
                  _line('Plate', job.vehicle.plate),
                  _line('VIN', job.vehicle.vin),
                  _line('Make/Model', '${job.vehicle.make} ${job.vehicle.model}'),
                  _line('Year', job.vehicle.year.toString()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section(context, 'Job Description', Text(job.description)),
            const SizedBox(height: 16),
            _section(
              context,
              'Assigned Parts',
              Column(
                children: job.parts.map((p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.name),
                  subtitle: Text(p.number),
                  trailing: Text('x${p.qty}'),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _section(
              context,
              'Service History',
              Column(
                children: job.vehicle.history.isEmpty
                    ? [const Text('No history.')]
                    : job.vehicle.history.map((h) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history),
                  title: Text(h.description),
                  subtitle: Text(h.formattedDate),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _section(
              context,
              'Time Tracking',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatDuration(job.elapsedSeconds), style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton.icon(onPressed: c.startTimer, icon: const Icon(Icons.play_arrow), label: const Text('Start')),
                      OutlinedButton.icon(onPressed: c.pauseTimer, icon: const Icon(Icons.pause), label: const Text('Pause')),
                      OutlinedButton.icon(onPressed: c.stopTimer, icon: const Icon(Icons.stop), label: const Text('Stop')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section(
              context,
              'Notes & Photos',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: noteCtrl,
                          decoration: const InputDecoration(hintText: 'Add note...'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          final t = noteCtrl.text.trim();
                          if (t.isNotEmpty) {
                            c.addTextNote(t);
                            noteCtrl.clear();
                          }
                        },
                        child: const Text('Add'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(onPressed: _pickAndSavePhoto, icon: const Icon(Icons.photo_camera)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...job.notes.map((n) => Card(
                    child: ListTile(
                      leading: n.photoPath != null
                          ? Image.file(File(n.photoPath!), width: 56, height: 56, fit: BoxFit.cover)
                          : const Icon(Icons.note),
                      title: n.text != null ? Text(n.text!) : const Text('Photo'),
                      subtitle: Text(n.timestamp.toString()),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(k, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
