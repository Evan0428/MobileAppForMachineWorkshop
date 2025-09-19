import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
    setState(() {});
  }

  Widget _kpiChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child, List<Widget>? actions}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (actions != null) ...actions,
            ]),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String k, String v, {IconData? icon, VoidCallback? onTap}) {
    final row = Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        SizedBox(width: 120, child: Text(k, style: const TextStyle(color: Colors.black54))),
        Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }

  Widget _statusStepper(JobStatus status) {
    final steps = [
      JobStatus.assigned,
      JobStatus.accepted,
      JobStatus.inProgress,
      JobStatus.onHold,
      JobStatus.completed,
      JobStatus.signedOff,
    ];
    Color colorOf(JobStatus s) => switch (s) {
      JobStatus.assigned   => Colors.grey,
      JobStatus.accepted   => Colors.blueGrey,
      JobStatus.inProgress => Colors.blue,
      JobStatus.onHold     => Colors.orange,
      JobStatus.completed  => Colors.green,
      JobStatus.signedOff  => Colors.teal,   
    };
    final currentIndex = steps.indexOf(status);
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isEven) {
          final idx = i ~/ 2;
          final active = idx <= currentIndex;
          return Column(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: active ? colorOf(steps[idx]) : Colors.black12,
                child: Icon(Icons.check, size: 14, color: active ? Colors.white : Colors.black26),
              ),
              const SizedBox(height: 6),
              Text(steps[idx].label, style: TextStyle(fontSize: 10, color: active ? Colors.black87 : Colors.black45)),
            ],
          );
        } else {
          final active = (i ~/ 2) < currentIndex;
          return Expanded(
            child: Container(height: 2, color: active ? Colors.black54 : Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 4)),
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = c.job;
    if (job == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final sched = TimeOfDay.fromDateTime(job.scheduledFor);
    final schedStr = '${sched.hour.toString().padLeft(2, '0')}:${sched.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_turned_in),
            tooltip: 'Digital Sign-off',
            onPressed: () => Navigator.pushNamed(context, SignOffScreen.routeName, arguments: job.id),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        slivers: [

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusChip(status: job.status),
                          DropdownButton<JobStatus>(
                            value: job.status,
                            items: JobStatus.values
                                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                                .toList(),
                            onChanged: (s) => c.setStatus(s!),
                          ),
                          const SizedBox(width: 8),
                          _kpiChip(Icons.schedule, 'Scheduled', schedStr),
                          _kpiChip(Icons.timer, 'Elapsed', formatDuration(job.elapsedSeconds)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _statusStepper(job.status),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _sectionCard(
                title: 'Customer & Vehicle',
                actions: [
                  IconButton(
                    tooltip: 'Copy phone',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: job.customer.phone));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone copied')));
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Customer', job.customer.name, icon: Icons.person),
                    _infoRow('Phone', job.customer.phone, icon: Icons.phone, onTap: () {
                      Clipboard.setData(ClipboardData(text: job.customer.phone));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone copied')));
                    }),
                    _infoRow('Email', job.customer.email, icon: Icons.email),
                    const Divider(height: 24),
                    _infoRow('Plate', job.vehicle.plate, icon: Icons.directions_car),
                    _infoRow('VIN', job.vehicle.vin, icon: Icons.confirmation_number),
                    _infoRow('Make/Model', '${job.vehicle.make} ${job.vehicle.model}', icon: Icons.build),
                    _infoRow('Year', job.vehicle.year.toString(), icon: Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _sectionCard(
                title: 'Job Description',
                child: Text(job.description),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _sectionCard(
                title: 'Assigned Parts',
                child: job.parts.isEmpty
                    ? const Text('No parts assigned.')
                    : Column(
                  children: job.parts
                      .map((p) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.inventory_2),
                    title: Text(p.name),
                    subtitle: Text(p.number),
                    trailing: Text('x${p.qty}'),
                  ))
                      .toList(),
                ),
              ),
            ),
          ),


          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _sectionCard(
                title: 'Service History',
                child: job.vehicle.history.isEmpty
                    ? const Text('No history.')
                    : Column(
                  children: job.vehicle.history
                      .map((h) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history),
                    title: Text(h.description),
                    subtitle: Text(h.formattedDate),
                  ))
                      .toList(),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _sectionCard(
                title: 'Notes & Photos',
                actions: [
                  IconButton(onPressed: _pickAndSavePhoto, icon: const Icon(Icons.photo_camera)),
                ],
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: noteCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Add note...',
                              prefixIcon: Icon(Icons.edit_note),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            final t = noteCtrl.text.trim();
                            if (t.isNotEmpty) {
                              c.addTextNote(t);
                              noteCtrl.clear();
                              setState(() {});
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (job.notes.isEmpty)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('No notes yet.'),
                      )
                    else
                      Column(
                        children: job.notes.map((n) {
                          final isPhoto = n.photoPath != null;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: isPhoto
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(n.photoPath!),
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : const Icon(Icons.note),
                              title: isPhoto ? const Text('Photo') : Text(n.text ?? ''),
                              subtitle: Text(n.timestamp.toString()),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 88)), // for bottom bar spacing
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08))),
          ),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: c.startTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: c.pauseTimer,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: c.stopTimer,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, SignOffScreen.routeName, arguments: job.id),
                  icon: const Icon(Icons.assignment_turned_in),
                  label: const Text('Sign-off'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
