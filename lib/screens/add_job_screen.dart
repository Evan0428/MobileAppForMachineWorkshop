import 'package:flutter/material.dart';
import '../repository.dart';
import '../models.dart';

class AddJobScreen extends StatefulWidget {
  static const routeName = '/add-job';
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final custNameCtrl = TextEditingController();
  final custPhoneCtrl = TextEditingController();
  final custEmailCtrl = TextEditingController();
  final custIdCtrl = TextEditingController();
  final plateCtrl = TextEditingController();
  final vinCtrl = TextEditingController();
  final makeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final yearCtrl = TextEditingController();

  final List<PartItem> parts = [];
  final List<ServiceRecord> history = [];

  DateTime scheduledFor = DateTime.now().add(const Duration(hours: 1));

  void _addPart() {
    final nameCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Part"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: numCtrl, decoration: const InputDecoration(labelText: "Number")),
            TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              setState(() {
                parts.add(PartItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  number: numCtrl.text,
                  qty: int.tryParse(qtyCtrl.text) ?? 1,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _addHistory() {
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Service Record"),
        content: TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              if (descCtrl.text.isEmpty) return;
              setState(() {
                history.add(ServiceRecord(date: DateTime.now(), description: descCtrl.text));
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = JobRepository();
    await repo.addJob(
      title: titleCtrl.text,
      description: descCtrl.text,
      customer: Customer(
        id: custIdCtrl.text.isEmpty ? "C-${DateTime.now().millisecondsSinceEpoch}" : custIdCtrl.text,
        name: custNameCtrl.text,
        phone: custPhoneCtrl.text,
        email: custEmailCtrl.text,
      ),
      vehicle: Vehicle(
        vin: vinCtrl.text,
        plate: plateCtrl.text,
        make: makeCtrl.text,
        model: modelCtrl.text,
        year: int.tryParse(yearCtrl.text) ?? DateTime.now().year,
        history: history,
      ),
      parts: parts,
      scheduledFor: scheduledFor,
    );

    if (mounted) Navigator.pop(context);
  }

  Widget _sectionCard({required String title, required List<Widget> children, IconData? icon}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, size: 20, color: Colors.blueGrey),
                if (icon != null) const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Job")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              title: "Job Info",
              icon: Icons.work,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: "Job Title", prefixIcon: Icon(Icons.title)),
                  validator: (v) => v == null || v.isEmpty ? "Job Title is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: "Description", prefixIcon: Icon(Icons.description)),
                ),
              ],
            ),

            _sectionCard(
              title: "Customer Info",
              icon: Icons.person,
              children: [
                TextFormField(controller: custIdCtrl, decoration: const InputDecoration(labelText: "Customer ID", prefixIcon: Icon(Icons.badge))),
                const SizedBox(height: 10),
                TextFormField(
                  controller: custNameCtrl,
                  decoration: const InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v == null || v.isEmpty ? "Customer Name is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: custPhoneCtrl,
                  decoration: const InputDecoration(labelText: "Phone", prefixIcon: Icon(Icons.phone)),
                  validator: (v) => v == null || v.isEmpty ? "Phone is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(controller: custEmailCtrl, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
              ],
            ),

            _sectionCard(
              title: "Vehicle Info",
              icon: Icons.directions_car,
              children: [
                TextFormField(
                  controller: plateCtrl,
                  decoration: const InputDecoration(labelText: "Plate", prefixIcon: Icon(Icons.confirmation_number)),
                  validator: (v) => v == null || v.isEmpty ? "Plate is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: vinCtrl,
                  decoration: const InputDecoration(labelText: "VIN", prefixIcon: Icon(Icons.qr_code)),
                  validator: (v) => v == null || v.isEmpty ? "VIN is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: makeCtrl,
                  decoration: const InputDecoration(labelText: "Make", prefixIcon: Icon(Icons.build)),
                  validator: (v) => v == null || v.isEmpty ? "Make is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: modelCtrl,
                  decoration: const InputDecoration(labelText: "Model", prefixIcon: Icon(Icons.directions_car_filled)),
                  validator: (v) => v == null || v.isEmpty ? "Model is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: yearCtrl,
                  decoration: const InputDecoration(labelText: "Year", prefixIcon: Icon(Icons.calendar_today)),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? "Year is required" : null,
                ),
              ],
            ),

            _sectionCard(
              title: "Assigned Parts",
              icon: Icons.inventory,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Parts List", style: TextStyle(fontWeight: FontWeight.w600)),
                    IconButton(onPressed: _addPart, icon: const Icon(Icons.add_circle, color: Colors.blue)),
                  ],
                ),
                ...parts.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  return ListTile(
                    leading: const Icon(Icons.settings, color: Colors.grey),
                    title: Text(p.name),
                    subtitle: Text("No: ${p.number}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("x${p.qty}"),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => parts.removeAt(i)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),

            _sectionCard(
              title: "Service History",
              icon: Icons.history,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("History Records", style: TextStyle(fontWeight: FontWeight.w600)),
                    IconButton(onPressed: _addHistory, icon: const Icon(Icons.add_circle, color: Colors.blue)),
                  ],
                ),
                ...history.asMap().entries.map((entry) {
                  final i = entry.key;
                  final h = entry.value;
                  return ListTile(
                    leading: const Icon(Icons.article, color: Colors.grey),
                    title: Text(h.description),
                    subtitle: Text(h.formattedDate),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => history.removeAt(i)),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text("Save Job"),
            ),
          ],
        ),
      ),
    );
  }
}
