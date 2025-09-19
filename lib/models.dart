import 'package:intl/intl.dart';


enum JobStatus { assigned, accepted, inProgress, onHold, completed, signedOff }

extension JobStatusX on JobStatus {
  String get label => switch (this) {
    JobStatus.assigned   => 'Assigned',
    JobStatus.accepted   => 'Accepted',
    JobStatus.inProgress => 'In Progress',
    JobStatus.onHold     => 'On Hold',
    JobStatus.completed  => 'Completed',
    JobStatus.signedOff  => 'Signed-off',
  };
}


class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  const Customer({required this.id, required this.name, required this.phone, required this.email});
}

class ServiceRecord {
  final DateTime date;
  final String description;
  const ServiceRecord({required this.date, required this.description});
  String get formattedDate => DateFormat.yMMMd().format(date);
}

class Vehicle {
  final String vin;
  final String plate;
  final String make;
  final String model;
  final int year;
  final List<ServiceRecord> history;
  const Vehicle({
    required this.vin,
    required this.plate,
    required this.make,
    required this.model,
    required this.year,
    this.history = const [],
  });
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
  final String? photoPath;
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
  int elapsedSeconds;
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
