import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';

class AddJobScreen extends StatefulWidget {
  static const routeName = '/add-job';
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final repo = JobRepository();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final customerNameCtrl = TextEditingController();
  final customerPhoneCtrl = TextEditingController();
  final customerEmailCtrl = TextEditingController();
  final vehiclePlateCtrl = TextEditingController();
  final vehicleMakeCtrl = TextEditingController();
  final vehicleModelCtrl = TextEditingController();
  final vehicleYearCtrl = TextEditingController();

  DateTime? scheduledFor;

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    customerNameCtrl.dispose();
    customerPhoneCtrl.dispose();
    customerEmailCtrl.dispose();
    vehiclePlateCtrl.dispose();
    vehicleMakeCtrl.dispose();
    vehicleModelCtrl.dispose();
    vehicleYearCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now,
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      scheduledFor = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (scheduledFor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a schedule time")),
      );
      return;
    }

    await repo.addJob(
      title: titleController.text,
      description: descController.text,
      customer: Customer(
        id: "C-${DateTime.now().millisecondsSinceEpoch}",
        name: customerNameCtrl.text,
        phone: customerPhoneCtrl.text,
        email: customerEmailCtrl.text,
      ),
      vehicle: Vehicle(
        vin: "VIN-${DateTime.now().millisecondsSinceEpoch}",
        plate: vehiclePlateCtrl.text,
        make: vehicleMakeCtrl.text,
        model: vehicleModelCtrl.text,
        year: int.tryParse(vehicleYearCtrl.text) ?? DateTime.now().year,
      ),
      parts: [],
      scheduledFor: scheduledFor!,
    );

    if (mounted) {
      Navigator.pop(context, true); // 返回 Dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Job")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Job Title"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const Divider(),
              TextFormField(
                controller: customerNameCtrl,
                decoration: const InputDecoration(labelText: "Customer Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: customerPhoneCtrl,
                decoration: const InputDecoration(labelText: "Customer Phone"),
              ),
              TextFormField(
                controller: customerEmailCtrl,
                decoration: const InputDecoration(labelText: "Customer Email"),
              ),
              const Divider(),
              TextFormField(
                controller: vehiclePlateCtrl,
                decoration: const InputDecoration(labelText: "Vehicle Plate"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: vehicleMakeCtrl,
                decoration: const InputDecoration(labelText: "Vehicle Make"),
              ),
              TextFormField(
                controller: vehicleModelCtrl,
                decoration: const InputDecoration(labelText: "Vehicle Model"),
              ),
              TextFormField(
                controller: vehicleYearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Vehicle Year"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      scheduledFor == null
                          ? "No schedule selected"
                          : "Scheduled: ${scheduledFor.toString()}",
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDateTime,
                    child: const Text("Pick Date & Time"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveJob,
                icon: const Icon(Icons.save),
                label: const Text("Save Job"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
