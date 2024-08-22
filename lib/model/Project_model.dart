import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  String projectid;
  String name;
  String description;
  String managerId;
  String developerId;
  DateTime deadline;
  String status_project;

  Project(
      {required this.projectid,
      required this.name,
      required this.description,
      required this.managerId,
      required this.developerId,
      required this.deadline,
      required this.status_project});

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Project(
      projectid: doc.id ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      managerId: data['manager_id'] ?? '',
      developerId: data['developer_Id'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      status_project: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectid,
      'name': name,
      'description': description,
      'manager_id': managerId,
      'developer_Id': developerId,
      'deadline': Timestamp.fromDate(deadline),
      'status': status_project
    };
  }
}
