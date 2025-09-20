import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum JobStatus { assigned, accepted, inProgress, onHold, completed, signedOff }

extension JobStatusX on JobStatus {
  String get label => switch (this) {
    JobStatus.assigned => 'Assigned',
    JobStatus.accepted => 'Accepted',
    JobStatus.inProgress => 'In Progress',
    JobStatus.onHold => 'On Hold',
    JobStatus.completed => 'Completed',
    JobStatus.signedOff => 'Signed-off',
  };

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
          (s) => s.name == value,
      orElse: () => JobStatus.assigned,
    );
  }
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "email": email,
    };
  }
}

class ServiceRecord {
  final DateTime date;
  final String description;

  const ServiceRecord({
    required this.date,
    required this.description,
  });

  String get formattedDate => DateFormat.yMMMd().format(date);

  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "date": date,
      "description": description,
    };
  }
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

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      vin: map['vin'] ?? '',
      plate: map['plate'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      history: (map['history'] as List<dynamic>? ?? [])
          .map((e) => ServiceRecord.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "vin": vin,
      "plate": plate,
      "make": make,
      "model": model,
      "year": year,
      "history": history.map((e) => e.toMap()).toList(),
    };
  }
}

class PartItem {
  final String id;
  final String name;
  final String number;
  final int qty;

  const PartItem({
    required this.id,
    required this.name,
    required this.number,
    required this.qty,
  });

  factory PartItem.fromMap(Map<String, dynamic> map) {
    return PartItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      number: map['number'] ?? '',
      qty: map['qty'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "number": number,
      "qty": qty,
    };
  }
}

class NoteItem {
  final String id;
  final DateTime timestamp;
  final String? text;
  final String? photoPath;

  const NoteItem({
    required this.id,
    required this.timestamp,
    this.text,
    this.photoPath,
  });

  factory NoteItem.fromMap(Map<String, dynamic> map) {
    return NoteItem(
      id: map['id'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      text: map['text'],
      photoPath: map['photoPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "timestamp": timestamp,
      "text": text,
      "photoPath": photoPath,
    };
  }
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

  /// Firestore → Model
  factory MechanicJob.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MechanicJob(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      customer: Customer.fromMap(Map<String, dynamic>.from(data['customer'])),
      vehicle: Vehicle.fromMap(Map<String, dynamic>.from(data['vehicle'])),
      parts: (data['parts'] as List<dynamic>? ?? [])
          .map((e) => PartItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      scheduledFor: (data['scheduledFor'] as Timestamp).toDate(),
      status: JobStatusX.fromString(data['status'] ?? 'assigned'),
      elapsedSeconds: data['elapsedSeconds'] ?? 0,
      notes: (data['notes'] as List<dynamic>? ?? [])
          .map((e) => NoteItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "customer": customer.toMap(),
      "vehicle": vehicle.toMap(),
      "parts": parts.map((e) => e.toMap()).toList(),
      "scheduledFor": scheduledFor,
      "status": status.name,
      "elapsedSeconds": elapsedSeconds,
      "notes": notes.map((e) => e.toMap()).toList(),
    };
  }
}
