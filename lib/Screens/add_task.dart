// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import 'Notification_Handle/Notification_Handle.dart';
//
// class AddTaskPage extends StatefulWidget {
//   const AddTaskPage({super.key});
//
//   @override
//   _AddTaskPageState createState() => _AddTaskPageState();
// }
//
// class _AddTaskPageState extends State<AddTaskPage> {
//   final nameController = TextEditingController();
//   final descriptionController = TextEditingController();
//   DateTime? selectedDeadline;
//   String? selectedDeveloper;
//   String? selectedStatus;
//   String? selectedProjectId;
//   final Map<String, String> projectMap = {};
//   final Map<String, String> developerMap = {};
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add New Task'),
//         backgroundColor: Colors.green.shade700,
//         elevation: 10,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTextField(nameController, 'Task Name'),
//               _buildTextField(descriptionController, 'Task Description'),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 'Select Status',
//                 ['Open', 'In Progress', 'Completed', 'Cancel'],
//                 (value) {
//                   setState(() {
//                     selectedStatus = value;
//                   });
//                 },
//                 selectedStatus,
//               ),
//               const SizedBox(height: 16),
//               const Text('Assigned To (Developer)'),
//               FutureBuilder<List<String>>(
//                 future: _fetchDeveloperDropdownItems(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Text('No developers available');
//                   }
//
//                   final developers = snapshot.data!;
//                   return _buildDropdown(
//                     'Select Developer',
//                     developers,
//                     (value) {
//                       setState(() {
//                         selectedDeveloper = value;
//                       });
//                     },
//                     selectedDeveloper,
//                     isDeveloperDropdown: true,
//                   );
//                 },
//               ),
//               const SizedBox(height: 16),
//               const Text('Select Project'),
//               FutureBuilder<List<String>>(
//                 future: _fetchProjectDropdownItems(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Text('No projects available');
//                   }
//
//                   final projects = snapshot.data!;
//                   return _buildDropdown(
//                     'Select Project',
//                     projects,
//                     (value) {
//                       setState(() {
//                         selectedProjectId = value;
//                       });
//                     },
//                     selectedProjectId,
//                   );
//                 },
//               ),
//               const SizedBox(height: 16),
//               _buildDeadlineField(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomAppBar(),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(labelText: label),
//     );
//   }
//
//   Widget _buildDropdown(
//     String hintText,
//     List<String> items,
//     ValueChanged<String?> onChanged,
//     String? selectedValue, {
//     bool isDeveloperDropdown = false,
//   }) {
//     return DropdownButton<String>(
//       value: selectedValue,
//       hint: Text(hintText),
//       items: items.map((item) {
//         return DropdownMenuItem<String>(
//           value: item,
//           child: Text(item),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }
//
//   Widget _buildDeadlineField() {
//     final deadlineController = TextEditingController(
//       text: selectedDeadline != null
//           ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDeadline!)
//           : '',
//     );
//
//     return TextField(
//       controller: deadlineController,
//       decoration: const InputDecoration(
//         labelText: 'Deadline (YYYY-MM-DD HH:mm)',
//         suffixIcon: Icon(Icons.calendar_today),
//       ),
//       readOnly: true,
//       onTap: () async {
//         FocusScope.of(context).requestFocus(FocusNode());
//         final selectedDate = await showDatePicker(
//           context: context,
//           initialDate: selectedDeadline ?? DateTime.now(),
//           firstDate: DateTime(2024),
//           lastDate: DateTime(2025),
//         );
//         if (selectedDate != null) {
//           final selectedTime = await showTimePicker(
//             context: context,
//             initialTime:
//                 TimeOfDay.fromDateTime(selectedDeadline ?? DateTime.now()),
//           );
//           if (selectedTime != null) {
//             setState(() {
//               selectedDeadline = DateTime(
//                 selectedDate.year,
//                 selectedDate.month,
//                 selectedDate.day,
//                 selectedTime.hour,
//                 selectedTime.minute,
//               );
//               deadlineController.text =
//                   DateFormat('yyyy-MM-dd HH:mm').format(selectedDeadline!);
//             });
//           }
//         }
//       },
//     );
//   }
//
//   Future<String?> getCurrentManagerUID() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       return user.uid;
//     }
//     return null;
//   }
//
//   Future<List<String>> _fetchDeveloperDropdownItems() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection(Com_string.Firebase_collection_users)
//           .where(Com_string.role, isEqualTo: Com_string.Role_developer)
//           .get();
//
//       final developers = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         final name =
//             data[Com_string.email] as String? ?? 'Unknown'; // Ensure name is a String
//         final id = doc.id;
//         developerMap[id] = id; // Store ID and name in the map
//         return name; // Return the name for the dropdown
//       }).toList();
//
//       return developers;
//     } catch (e) {
//       print('Error fetching developers: $e');
//       return []; // Return an empty list in case of error
//     }
//   }
//
//   Future<List<String>> _fetchProjectDropdownItems() async {
//     try {
//       final managerUID = await getCurrentManagerUID();
//       print("managerUid   $managerUID");
//       if (managerUID == null) {
//         return []; // Return an empty list if no manager UID is found
//       }
//
//       final snapshot = await FirebaseFirestore.instance
//           .collection('projects')
//           .where('manager_id',
//               isEqualTo: managerUID) // Filter projects by manager UID
//           .get();
//
//       final projects = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         final name =
//             data['name'] as String? ?? 'Unknown'; // Ensure name is a String
//         final id = doc.id;
//         projectMap[id] = name; // Store ID and name in the map
//         return name; // Return the project name for the dropdown
//       }).toList();
//
//       return projects;
//     } catch (e) {
//       print('Error fetching projects: $e');
//       return []; // Return an empty list in case of error
//     }
//   }
//
//   Widget _buildBottomAppBar() {
//     return BottomAppBar(
//       child: Row(
//         children: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black)),
//           ),
//           const Spacer(),
//           TextButton(
//             onPressed: () => _addTask(),
//             child: const Text('Add Task',
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _addTask() async {
//     if (nameController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Task name cannot be empty')));
//       return;
//     }
//
//     final uidDeveloper = await getDocumentIdByEmail(selectedDeveloper ?? '');
//     final newTask = {
//       'name': nameController.text,
//       'description': descriptionController.text,
//       'assignedBy': FirebaseAuth.instance.currentUser?.email,
//       'assignedTo': selectedDeveloper ?? 'Unassigned',
//       'status': selectedStatus ?? 'Open',
//       'deadline': selectedDeadline ?? Timestamp.now(),
//       'Project_id': selectedProjectId ?? '',
//     };
//
//     try {
//       await FirebaseFirestore.instance.collection('tasks').add(newTask);
//
//       if (uidDeveloper != null) {
//         await _sendNotification(uidDeveloper, Com_string.Role_developer);
//       }
//
//       Navigator.of(context).pop();
//     } catch (error) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to add task: $error')));
//     }
//   }
//
//   Future<void> _sendNotification(String userId, String role) async {
//     final snapshot =
//         await FirebaseFirestore.instance.collection(Com_string.Firebase_collection_users).doc(userId).get();
//     final fcmToken = snapshot.get(Com_string.Fcm_Token) as String?;
//     if (fcmToken != null) {
//       final title = "Task Updated: ${nameController.text}";
//       final body = role == Com_string.Role_manager
//           ? "Deadline: ${selectedDeadline.toString()}, Assigned By: ${snapshot.get(Com_string.email)}"
//           : role == 'admin'
//               ? "Deadline: ${selectedDeadline.toString()}, Assigned By: Admin"
//               : "Deadline: ${selectedDeadline.toString()}";
//       NotificationHandler.sendNotification(
//           FCM_token: fcmToken, title: title, body: body);
//     }
//   }
//
//   Future<String?> getDocumentIdByEmail(String email) async {
//     final collectionRef = FirebaseFirestore.instance.collection(Com_string.Firebase_collection_users);
//     final querySnapshot =
//         await collectionRef.where(Com_string.email, isEqualTo: email).get();
//     if (querySnapshot.docs.isNotEmpty) {
//       return querySnapshot.docs.first.id;
//     } else {
//       return null;
//     }
//   }
// }
