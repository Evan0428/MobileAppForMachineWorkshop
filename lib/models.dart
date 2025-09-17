import 'package:intl/intl.dart';

enum JobStatus { assigned, accepted, inProgress, onHold, completed }

extension JobStatusX on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.assigned: return 'Assigned';
      case JobStatus.accepted: return 'Accepted';
      case JobStatus.inProgress: return 'In Progress';
      case JobStatus.onHold: return 'On Hold';
      case JobStatus.completed: return 'Completed';
    }
  }

  static JobStatus fromLabel(String s) {
    switch (s) {
      case 'Accepted': return JobStatus.accepted;
      case 'In Progress': return JobStatus.inProgress;
      case 'On Hold': return JobStatus.onHold;
      case 'Completed': return JobStatus.completed;
      default: return JobStatus.assigned;
    }
  }
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  const Customer({required this.id, required this.name, required this.phone, required this.email});
}

class Vehicle {
  final String vin;
  final String plate;
  final String make;
  final String model;
  final int year;
  final List<ServiceRecord> history;
  const Vehicle({required this.vin, required this.plate, required this.make, required this.model, required this.year, this.history = const []});
}

class ServiceRecord {
  final DateTime date;
  final String description;
  const ServiceRecord({required this.date, required this.description});
  String get formattedDate => DateFormat.yMMMd().format(date);
}

class PartItem {
  final String id;
  final String name;
  final String number;
  final int qty;
  const PartItem({required this.id, required this.name, required this.number, required this.qty});
}

class NoteItem {
  final String id;
  final DateTime timestamp;
  final String? text;
  final String? photoPath; // local path
  const NoteItem({required this.id, required this.timestamp, this.text, this.photoPath});
}

class MechanicJob {
  final String id;
  final String title;
  final String description;
  final Customer customer;
  final Vehicle vehicle;
  final List<PartItem> parts;
  final DateTime scheduledFor;
  JobStatus status;
  int elapsedSeconds; // time tracked
  final List<NoteItem> notes;

  MechanicJob({
    required this.id,
    required this.title,
    required this.description,
    required this.customer,
    required this.vehicle,
    required this.parts,
    required this.scheduledFor,
    this.status = JobStatus.assigned,
    this.elapsedSeconds = 0,
    List<NoteItem>? notes,
  }) : notes = notes ?? [];
}
