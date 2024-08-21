import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id; // Firestore document ID
  final String name;
  final String description;
  final String? assignedTo;
  final String? assignedBy;
  final String status;
  final DateTime deadline;

  Task({
    required this.id,
    required this.name,
    required this.description,
    this.assignedTo,
    this.assignedBy,
    required this.status,
    required this.deadline,
  });

  // Create a Task instance from Firestore document data
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id, // Use Firestore's document ID
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      assignedBy: data['assignedBy'] ?? '',
      status: data['status'] ?? 'Open',
      deadline: (data['deadline'] as Timestamp).toDate(),
    );
  }

  // Convert Task instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'status': status,
      'deadline': Timestamp.fromDate(deadline),
    };
  }
}
