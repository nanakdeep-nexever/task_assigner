import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  String id;
  String name;
  String description;
  String managerId;
  DateTime deadline;
  String status_project;

  Project(
      {required this.id,
      required this.name,
      required this.description,
      required this.managerId,
      required this.deadline,
      required this.status_project});

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      managerId: data['manager_id'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      status_project: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'manager_id': managerId,
      'deadline': Timestamp.fromDate(deadline),
      'status': status_project
    };
  }

  void copyWith(Project project) {
    id = project.id;
  }
}
