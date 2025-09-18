import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import '../models.dart';
import '../auth.dart';
import 'job_detail_screen.dart';
import '../widgets/status_chip.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<JobListController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs — GearUp'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'logout') context.read<AuthController>().logout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Today')),
                ButtonSegment(value: true, label: Text('Week')),
              ],
              selected: <bool>{c.showWeek},
              onSelectionChanged: (s) => context.read<JobListController>().toggleRange(s.first),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: context.read<JobListController>().setSearch,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search jobs, plate, customer...',
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<JobListController>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: c.filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final j = c.filtered[i];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, JobDetailScreen.routeName, arguments: j.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.build, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(j.title, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(j.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      StatusChip(status: j.status),
                                      Chip(label: Text(j.vehicle.plate)),
                                      Chip(label: Text('${j.vehicle.make} ${j.vehicle.model} ${j.vehicle.year}')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(j.customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('${j.scheduledFor.hour.toString().padLeft(2, '0')}:${j.scheduledFor.minute.toString().padLeft(2, '0')}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
